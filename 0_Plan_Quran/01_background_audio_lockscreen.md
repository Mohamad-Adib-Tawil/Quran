# 01 — التشغيل في الخلفية + ويدجت شاشة القفل والإشعارات

## 🎯 الهدف
عند تشغيل سورة:
1. تستمر السورة بالعمل في الخلفية وحتى مع إغلاق شاشة الجوال.
2. يظهر ويدجت تحكّم كامل (تشغيل/إيقاف/التالي/السابق/شريط التقدّم) في:
   - شاشة القفل (Lock Screen).
   - شريط الإشعارات (Notification Drawer / System Notification Shade).
3. يتكامل مع أزرار السماعات والسيارة (Bluetooth/Headset) ومركز التحكم على iOS.

---

## 🔍 تشخيص الوضع الحالي

| العنصر | الحالة |
|--------|--------|
| مشغّل الصوت | `just_audio` `AudioPlayer` (singleton في GetIt) |
| طبقة الوصول | `AudioPlayerDataSource` → `AudioRepository` → `AudioCubit` |
| جلسة الصوت | `AudioSession.music()` في `main.dart` |
| عناصر تحكم النظام | ❌ **غير موجودة** — لا `audio_service` ولا `just_audio_background` |
| Foreground Service (Android) | ❌ غير معرّف في `AndroidManifest.xml` |
| iOS background mode | ❌ غير مفعّل في `Info.plist` |

**النتيجة:** يجب إدخال طبقة وسيطة تربط `just_audio` بنظام التشغيل لإظهار عناصر التحكم. الخيار الموصى به: **`audio_service`** (يكاملها رسمياً مع `just_audio`).

---

## 🧱 القرار المعماري

نختار **`audio_service ^0.18.x`** (وليس `just_audio_background`) للأسباب:
- يدعم أزرار مخصّصة (السابق/التالي للسور) وعناصر تحكم كاملة.
- يدير Foreground Service تلقائياً على Android.
- يبقى متوافقاً مع Clean Architecture: نُنشئ `QuranAudioHandler extends BaseAudioHandler` يغلّف نفس `AudioPlayer` الموجود.

> مبدأ مهم: **نُبقي `AudioPlayer` نفسه** المُسجّل في `service_locator`، ونمرّره إلى `AudioHandler` بدل إنشاء مشغّل جديد، حتى لا نكسر `AudioCubit` و `AudioRepository`.

### المخطط بعد التنفيذ
```
AudioCubit  ─────────────┐
                         ▼
AudioRepositoryImpl ─► AudioPlayerDataSource ─► AudioPlayer (just_audio)
                                                      ▲
                         QuranAudioHandler ───────────┘  (نفس المشغّل)
                                │
                         audio_service  ──► Android Foreground Service / iOS Now Playing
                                │
                         شاشة القفل + الإشعارات + أزرار السماعة
```

---

## 📦 الخطوة 1 — الاعتماديات

في `pubspec.yaml`:
```yaml
dependencies:
  audio_service: ^0.18.15
  # just_audio و audio_session موجودان مسبقاً
```
ثم: `flutter pub get`.

---

## 🤖 الخطوة 2 — إعداد Android

### 2.1 `android/app/src/main/AndroidManifest.xml`
أضف الأذونات (قبل `<application>`):
```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<!-- INTERNET و POST_NOTIFICATIONS موجودان مسبقاً -->
```

داخل `<application>` أضف الخدمة والـ receiver:
```xml
<service android:name="com.ryanheise.audioservice.AudioService"
    android:foregroundServiceType="mediaPlayback"
    android:exported="true">
  <intent-filter>
    <action android:name="android.media.browse.MediaBrowserService"/>
  </intent-filter>
</service>

<receiver android:name="com.ryanheise.audioservice.MediaButtonReceiver"
    android:exported="true">
  <intent-filter>
    <action android:name="android.intent.action.MEDIA_BUTTON"/>
  </intent-filter>
</receiver>
```

### 2.2 `MainActivity`
يجب أن يكون `AudioServiceActivity` بدل `FlutterActivity`:
```kotlin
import com.ryanheise.audioservice.AudioServiceActivity
class MainActivity : AudioServiceActivity()
```

---

## 🍎 الخطوة 3 — إعداد iOS

### 3.1 `ios/Runner/Info.plist`
```xml
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
```
(جلسة `AudioSession.music()` موجودة مسبقاً في `main.dart` — جيد.)

---

## 🧩 الخطوة 4 — إنشاء `QuranAudioHandler`

ملف جديد: `lib/services/audio/quran_audio_handler.dart`
```dart
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player;

  QuranAudioHandler(this._player) {
    _player.playbackEventStream.map(_transform).pipe(playbackState);
    // عند اكتمال السورة أو تغيّر المسار حدّث mediaItem من الـ Cubit
  }

  PlaybackState _transform(PlaybackEvent event) {
    final playing = _player.playing;
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
  }

  // ربط أزرار النظام بالـ Cubit عبر callbacks تُسجّل من الخارج
  Future<void> Function()? onPlay;
  Future<void> Function()? onPause;
  Future<void> Function()? onNext;
  Future<void> Function()? onPrevious;
  Future<void> Function()? onStopRequested;

  @override Future<void> play() async { await (onPlay?.call() ?? _player.play()); }
  @override Future<void> pause() async { await (onPause?.call() ?? _player.pause()); }
  @override Future<void> skipToNext() async { await onNext?.call(); }
  @override Future<void> skipToPrevious() async { await onPrevious?.call(); }
  @override Future<void> seek(Duration position) => _player.seek(position);
  @override Future<void> stop() async { await (onStopRequested?.call() ?? _player.stop()); }

  /// يُستدعى من الـ Cubit عند تشغيل سورة جديدة لتحديث معلومات الويدجت.
  void setNowPlaying({required int surah, required String arabicName, Duration? duration}) {
    mediaItem.add(MediaItem(
      id: 'surah_$surah',
      album: 'القرآن الكريم',
      title: arabicName,
      artist: 'تلاوة',
      duration: duration,
      artUri: Uri.parse('asset:///assets/icons/app_icon.png'), // صورة الغلاف
    ));
  }
}
```

> ملاحظة: `MediaItem.duration` و `playbackState.updatePosition` هما ما يرسم **شريط التقدّم** في شاشة القفل.

---

## 🔌 الخطوة 5 — التهيئة في `main.dart` و `service_locator`

### 5.1 `main.dart` — قبل `runApp` وبعد `setupLocator`
```dart
final handler = await AudioService.init(
  builder: () => QuranAudioHandler(sl<AudioPlayer>()),
  config: const AudioServiceConfig(
    androidNotificationChannelId: 'com.example.quran_app.audio',
    androidNotificationChannelName: 'تشغيل التلاوة',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
    notificationColor: Color(0xFF... ), // لون من FigmaPalette
  ),
);
sl.registerSingleton<QuranAudioHandler>(handler);
```

### 5.2 ربط الـ Handler بالـ Cubit
في إنشاء `AudioCubit` (في `main.dart` MultiBlocProvider) مرّر `QuranAudioHandler` وسجّل الـ callbacks:
```dart
final cubit = AudioCubit(..., sl<QuranAudioHandler>());
final h = sl<QuranAudioHandler>();
h.onPlay = cubit.play;
h.onPause = cubit.pause;
h.onNext = cubit.playNextFromCatalog;
h.onPrevious = cubit.playPrevFromCatalog;
h.onStopRequested = cubit.clearAudio;
```

---

## 🔁 الخطوة 6 — تعديلات `AudioCubit`

أضف حقل `QuranAudioHandler _handler` واستدعِ `setNowPlaying` في كل نقطة يبدأ فيها تشغيل سورة:
- داخل `prepareSurah` بعد معرفة السورة.
- داخل `playFromCatalog` بعد `setUrl`.
- داخل `_startDownloadFlow` بعد اكتمال التحميل.

مثال:
```dart
_handler.setNowPlaying(
  surah: surah,
  arabicName: surahArabicName(surah), // من package quran
  duration: state.duration,
);
```
حدّث `duration` لاحقاً عبر `durationStream` (موجود في `_bind`) باستدعاء `setNowPlaying` مرة أخرى أو تحديث `mediaItem`.

> لا حاجة لتغيير منطق التشغيل الأساسي — فقط حقن تحديث `mediaItem`/`playbackState`، لأن `audio_service` يلتقط حالة نفس `AudioPlayer` تلقائياً.

---

## ✅ الخطوة 7 — معايير القبول (Acceptance Criteria)

- [ ] تشغيل سورة ثم الخروج من التطبيق (Home button) → الصوت يستمر.
- [ ] إقفال الشاشة → الصوت يستمر، ويظهر ويدجت في شاشة القفل باسم السورة وصورة الغلاف.
- [ ] شريط الإشعارات يعرض: اسم السورة + تشغيل/إيقاف + التالي/السابق + شريط تقدّم.
- [ ] أزرار الإشعار تتحكم فعلياً بالتشغيل وتتزامن مع الـ Mini Player داخل التطبيق.
- [ ] زر السماعة (Headset play/pause) يعمل.
- [ ] إغلاق الإشعار يوقف التشغيل ويُنظّف الحالة (`clearAudio`).
- [ ] iOS: يظهر في Control Center و Lock Screen مع شريط تقدّم.
- [ ] لا يُنشأ أكثر من مشغّل واحد (نفس `AudioPlayer` المُسجّل).

---

## ⚠️ مخاطر وملاحظات

1. **MainActivity** يجب أن يرث `AudioServiceActivity` وإلا لن يعمل على Android.
2. **`androidNotificationOngoing: true`** يمنع المستخدم من مسح الإشعار أثناء التشغيل (سلوك مشغلات الموسيقى).
3. صورة الغلاف (`artUri`) — استخدم أيقونة لائقة (راجع "App icon" في Known Gaps).
4. عند تغيير السورة عبر التحميل، تأكد من استدعاء `setNowPlaying` **بعد** معرفة المدة.
5. اختبار على جهاز حقيقي ضروري (المحاكي قد لا يظهر الإشعار بدقة على iOS).

---

## ⏱️ تقدير الجهد
- إعداد المنصات + الاعتماديات: نصف يوم.
- `QuranAudioHandler` + الربط: يوم.
- التكامل مع الـ Cubit + شريط التقدّم: نصف يوم.
- اختبار على Android + iOS: يوم.
- **الإجمالي: ~3 أيام عمل.**
