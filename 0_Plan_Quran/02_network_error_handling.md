# 02 — معالجة مشاكل الشبكة (انقطاع / بطء الإنترنت)

## 🎯 الهدف
عندما يكون الإنترنت بطيئاً أو غير متوفر ويحاول المستخدم تشغيل/تحميل سورة:
- عرض رسالة واضحة: **"لا يوجد اتصال بالإنترنت حالياً، يرجى المحاولة لاحقاً"** أو **"الاتصال بطيء، تعذّر تحميل السورة"**.
- زر **"إعادة المحاولة"**.
- عدم ترك المستخدم في حالة تحميل/تقطيع لا نهائي.

---

## 🔍 الوضع الحالي

- ❌ لا يوجد `connectivity_plus` ولا أي فحص اتصال.
- ❌ لا يوجد timeout على التشغيل/التحميل → قد يبقى `phase = preparing/downloading/buffering` للأبد.
- ✅ يوجد بالفعل `AudioPhase.error` + `errorMessage` + `retry()` في `AudioCubit` → نبني عليها.
- ✅ التحميل عبر `background_downloader` يصدر `DownloadStatus.failed` → نعرض رسالة شبكة بدلاً من رسالة عامة.

---

## 📦 الخطوة 1 — الاعتماديات
```yaml
dependencies:
  connectivity_plus: ^6.1.0
```
> `connectivity_plus` يكشف **وجود** واجهة شبكة فقط (Wi-Fi/Mobile)، لا يضمن وجود إنترنت فعلي. لذا نجمعه مع **فحص فعلي خفيف (lookup)** + **timeout على التشغيل**.

---

## 🧩 الخطوة 2 — خدمة الاتصال

ملف جديد: `lib/services/connectivity_service.dart`
```dart
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _conn = Connectivity();

  /// هل توجد واجهة شبكة أصلاً؟
  Future<bool> hasInterface() async {
    final r = await _conn.checkConnectivity();
    return !r.contains(ConnectivityResult.none);
  }

  /// فحص فعلي للإنترنت عبر DNS lookup خفيف مع مهلة قصيرة.
  Future<bool> hasInternet({Duration timeout = const Duration(seconds: 3)}) async {
    if (!await hasInterface()) return false;
    try {
      final result = await InternetAddress.lookup('quran.devmmnd.com')
          .timeout(timeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
    }
  }

  Stream<bool> get onlineStream =>
      _conn.onConnectivityChanged.map((r) => !r.contains(ConnectivityResult.none));
}
```
سجّلها في `service_locator`:
```dart
sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
```

---

## 🧩 الخطوة 3 — توسعة حالة الصوت

في `audio_state.dart` أضف نوع خطأ للتمييز بين خطأ شبكة وغيره:
```dart
enum AudioErrorKind { none, network, source, unknown }
```
وأضف الحقل إلى `AudioState` + `copyWith` + `props`:
```dart
final AudioErrorKind errorKind;
```
هذا يسمح للواجهة بعرض أيقونة/رسالة مختلفة لخطأ الشبكة وزر "إعادة المحاولة".

---

## 🔁 الخطوة 4 — فحص الشبكة قبل التشغيل/التحميل

في `AudioCubit`، أضف `ConnectivityService _connectivity` وعدّل النقاط التي تتطلب الشبكة:

### 4.1 قبل البث المباشر `playFromCatalog` و قبل `_startDownloadFlow`
```dart
final online = await _connectivity.hasInternet();
if (!online) {
  emit(state.copyWith(
    phase: AudioPhase.error,
    errorKind: AudioErrorKind.network,
    errorMessage: 'لا يوجد اتصال بالإنترنت حالياً. يرجى المحاولة لاحقاً.',
  ));
  return;
}
```
> السور **المحمّلة مسبقاً** تُشغَّل بدون أي فحص شبكة (تعمل offline) — لا نضيف الفحص في مسار `prepareSurah` للملف المحلي.

### 4.2 إضافة Timeout على التشغيل المتدفّق
لمنع التعليق على نت بطيء، غلّف `setUrl/play` بمهلة:
```dart
try {
  await _repo.setUrl(url).timeout(const Duration(seconds: 15));
  await _repo.play();
} on TimeoutException {
  await _repo.stop();
  emit(state.copyWith(
    phase: AudioPhase.error,
    errorKind: AudioErrorKind.network,
    errorMessage: 'الاتصال بطيء، تعذّر تحميل السورة. حاول مرة أخرى.',
  ));
}
```

### 4.3 رسالة أدق عند فشل التحميل
في `_startDownloadFlow` عند `DownloadStatus.failed`، افحص الشبكة لتحديد السبب:
```dart
final online = await _connectivity.hasInternet();
emit(state.copyWith(
  phase: AudioPhase.error,
  errorKind: online ? AudioErrorKind.source : AudioErrorKind.network,
  errorMessage: online
      ? 'تعذّر تحميل السورة. حاول مرة أخرى لاحقاً.'
      : 'انقطع الاتصال أثناء التحميل. تحقّق من الإنترنت وحاول لاحقاً.',
));
```

---

## 🎨 الخطوة 5 — عرض الخطأ في الواجهة

### 5.1 في `full_player_page.dart` و `mini_player.dart`
استمع لـ `state.phase == AudioPhase.error` واعرض:
- أيقونة: `Icons.wifi_off` لخطأ الشبكة، `Icons.error_outline` لغيره.
- نص `state.errorMessage`.
- زر **"إعادة المحاولة"** → `context.read<AudioCubit>().retry()`.

### 5.2 SnackBar عام (اختياري)
`BlocListener<AudioCubit, AudioState>` في `main_shell.dart`:
```dart
listenWhen: (p, c) => c.phase == AudioPhase.error && p.phase != AudioPhase.error,
listener: (ctx, s) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(s.errorMessage ?? 'حدث خطأ'),
    action: SnackBarAction(
      label: 'إعادة المحاولة',
      onPressed: () => ctx.read<AudioCubit>().retry(),
    ),
  ));
},
```

### 5.3 شريط حالة "غير متصل" (اختياري لكن مفيد)
استخدم `ConnectivityService.onlineStream` لعرض شريط علوي رفيع "أنت غير متصل بالإنترنت" يختفي تلقائياً عند العودة.

---

## 🌐 الخطوة 6 — الترجمة (l10n)
أضف المفاتيح إلى `app_ar.arb` و `app_de.arb`:
```
"errorNoInternet": "لا يوجد اتصال بالإنترنت حالياً. يرجى المحاولة لاحقاً."
"errorSlowConnection": "الاتصال بطيء، تعذّر تحميل السورة. حاول مرة أخرى."
"errorDownloadFailed": "تعذّر تحميل السورة. حاول مرة أخرى لاحقاً."
"actionRetry": "إعادة المحاولة"
"offlineBanner": "أنت غير متصل بالإنترنت"
```
ثم `flutter gen-l10n`، واستبدل النصوص العربية الثابتة في الـ Cubit برسائل تأتي من الواجهة عبر `errorKind` (لإبقاء الـ Cubit مستقلاً عن النصوص — اختياري لكن أنظف).

---

## ✅ معايير القبول

- [ ] إيقاف الإنترنت ثم محاولة تشغيل سورة غير محمّلة → رسالة "لا يوجد اتصال... المحاولة لاحقاً" + زر إعادة محاولة.
- [ ] إنترنت بطيء جداً → بعد 15 ثانية رسالة "الاتصال بطيء" بدل تعليق دائم.
- [ ] فشل تحميل بسبب انقطاع → رسالة شبكة واضحة وليست رسالة عامة.
- [ ] السور المحمّلة مسبقاً تعمل بدون إنترنت ودون أي رسالة خطأ.
- [ ] زر "إعادة المحاولة" يعيد تشغيل آخر سورة مطلوبة بنجاح بعد عودة الإنترنت.
- [ ] عودة الإنترنت تُخفي شريط "غير متصل" تلقائياً.

---

## ⏱️ تقدير الجهد: ~1.5 يوم عمل.
