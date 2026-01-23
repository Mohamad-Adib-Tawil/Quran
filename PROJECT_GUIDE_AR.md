# دليل المشروع (Quran App)

هذا الملف يشرح بنية المشروع، الاعتمادات، طريقة العمل، ونقاط التوسعة لتسهيل تطويرك مستقبلاً.

## نظرة عامة
- **الهدف**: تطبيق قرآن كريم بواجهة عربية، يعرض السور والآيات مع دعم تشغيل الصوت.
- **الحزمة الأساسية للعرض**: `quran_library` (تعطي واجهات جاهزة مثل `QuranLibraryScreen`).
- **إدارة الحالة**: `flutter_bloc` مع Cubits لكل من الإعدادات، القرآن، والصوت.
- **الاعتمادات**: `just_audio` للتشغيل، `get_it` للـDI، و`shared_preferences` لتخزين الإعدادات، و`quran_library` للواجهة. الصوت يُحمَّل من ملف أصول JSON.

## بنية المجلدات
- `lib/main.dart`: نقطة الدخول. يهيّئ `QuranLibrary.init()` و`setupLocator()` ويطلق `QuranApp`.
- `lib/core/di/service_locator.dart`: تسجيل الكيانات في `GetIt` (AudioPlayer/Prefs/DataSources/Repositories).
- `lib/core/theme/`
  - `app_colors.dart`: ألوان ثابتة.
  - `app_theme.dart`: ثيم فاتح/داكن.
- `lib/features/`
  - `quran/`
    - `domain/`: كيان `Surah` وتجريد `QuranRepository`.
    - `data/`: مصدر بيانات محلي Placeholder، ومستودع `QuranRepositoryImpl`.
    - `presentation/`: `QuranCubit` + `QuranState`، وصفحة `SurahListPage` التي تبني `QuranLibraryScreen`.
  - `audio/`
    - `domain/`: `AudioRepository` (واجهات التحكم والتدفق).
    - `data/`: `AudioRemoteDataSource` (منفّذ لتحميل روابط السور من الأصول)، `AudioPlayerDataSource`، `AudioRepositoryImpl`.
    - `presentation/`: `AudioCubit` + `AudioState`.
  - `settings/`
    - `SettingsCubit` + `SettingsState` لحفظ/قراءة الثيم، تكبير الخط، علامة نهاية الآية من `SharedPreferences`.
- `assets/`: يحتوي `assets/audio/audio_urls.json` لخريطة روابط الصوت لكل سورة.

## تدفق التهيئة والتشغيل
1. `main()`:
   - `WidgetsFlutterBinding.ensureInitialized()`.
   - `QuranLibrary.init()` لتهيئة الحزمة.
   - `setupLocator()` لتسجيل الـ DI.
   - تشغيل `QuranApp`.
2. `QuranApp`:
   - `MultiBlocProvider` يوفر: `SettingsCubit`, `QuranCubit`, `AudioCubit` باستخدام `sl()` من `GetIt`.
   - `MaterialApp` يستخدم `AppTheme.light/dark` و`themeMode` من `SettingsState`.
   - الشاشة الأساسية: `SurahListPage`.

## إدارة الاعتمادية (DI)
- موجودة في `core/di/service_locator.dart`:
  - تسجيل `AudioPlayer` كـ lazy singleton.
  - جلب `SharedPreferences` وتسجيله كـ singleton.
  - تسجيل DataSources:
    - `QuranLocalDataSource` (Placeholder).
    - `AudioRemoteDataSource`: يُحمِّل `assets/audio/audio_urls.json` في الإقلاع، مع `baseUrl` احتياطي.
    - `AudioPlayerDataSource` لتغليف `just_audio`.
  - تسجيل Repositories: `QuranRepositoryImpl`, `AudioRepositoryImpl`.
- استخدم `sl<T>()` للحصول على أي خدمة.

## الواجهة وعرض القرآن
- `SurahListPage` تبني `QuranLibraryScreen` مباشرة وتضبط الألوان والأنماط بناءً على الثيم.
- الخصائص المفعلة:
  - `withPageView`, `useDefaultAppBar`, تبويبات الفهرس/العلامات/البحث.
  - تخصيص نصوص عربية: مثل `القراء`، `الفهرس`، `العلامات`.
- صفحة `ReaderPage` Placeholder لتوسعة لاحقة (توجيه مخصص إن رغبت).

- تم إخفاء واجهة الصوت الخاصة بالحزمة لتجنب الالتباس: `showAudioButton=false`, `isShowAudioSlider=false`.
- تمت إضافة مشغل بسيط أسفل الشاشة: `MiniAudioPlayer` (تشغيل/إيقاف/شريط تقدم) يعتمد على `AudioCubit`.

## إدارة القرآن (QuranCubit)
- ملف: `features/quran/presentation/cubit/quran_cubit.dart`.
- يبدأ بتحميل الفهرس والسورة 1.
- يعتمد على `QuranRepository`:
  - `getAllSurahs()` و`getSurahVerses(surah, verseEndSymbol)`.
- ملاحظة: `QuranLocalDataSource` حالياً يعيد قوائم فارغة (Placeholder). الاعتماد الحقيقي على واجهة `quran_library` للعرض. لو احتجت بيانات برمجية (غير الواجهة الجاهزة)، قم بتنفيذ `QuranLocalDataSource`.

## الصوت (Audio)
- `AudioRemoteDataSource`: مُنفّذ الآن لقراءة الروابط من `assets/audio/audio_urls.json`، مع fallback إلى `baseUrl` بصيغة صفرية (001.mp3...114.mp3).
- `AudioPlayerDataSource`: تغليف لـ `just_audio`.
- `AudioRepositoryImpl`: يوفر `prepareSurah(surah)` لضبط رابط السورة على المشغل. دالة `prepareAyah` تفوّض مؤقتاً إلى `prepareSurah`.
- `AudioCubit`: يربط Streams (`position`, `duration`, `playerState`) ويحدث `AudioState`، ويعرض `prepareSurah` و`prepareAndPlaySurah`.

- القارئ ثابت: محمد كراسي. الروابط في `audio_urls.json` تخص هذا القارئ.

## الإعدادات (Settings)
- المفاتيح المخزنة في `SharedPreferences`:
  - `themeMode`: `light`/`dark`/`system`.
  - `fontScale`: قيمة مضاعِف.
  - `verseEndSymbol`: إظهار/إخفاء علامة نهاية الآية.
- استخدم دوال `SettingsCubit`: `setTheme`, `setFontScale`, `toggleVerseEndSymbol`.

## الاعتمادات (pubspec.yaml)
- Flutter SDK: `^3.10.3`.
- الحزم:
  - `flutter_bloc`, `equatable`.
  - `just_audio`.
  - `get_it`.
  - `shared_preferences`.
  - `quran_library`.
- الأصول:
  - `assets/audio/audio_urls.json` مفعّل تحت `flutter/assets`.

## خطوات التشغيل محلياً
1. تثبيت الاعتمادات:
   ```bash
   flutter pub get
   ```
2. التشغيل:
   ```bash
   flutter run
   ```
3. المنصات: Android, iOS, Web, Desktop بحسب تفعيلك في مشروع Flutter.

## نقاط توسعة سريعة
- الواجهة:
  - تخصيص أنماط `QuranLibraryScreen` أكثر (الألوان، الرموز، أحجام الخطوط) وربط `fontScale`.
  - إضافة BottomNavigation/Drawer وصفحات إضافية (أذكار، مواقيت...)
- القرآن والبيانات:
  - تنفيذ `QuranLocalDataSource` لإرجاع `List<Surah>` و`List<String>` (من ملفات JSON محلية أو من الحزمة إن كانت توفر API للبيانات الخام).
- الصوت:
  - تخصيص `AudioRemoteDataSource` (تغيير `baseUrl` أو تحميل ملف JSON آخر) وإضافة إعداد اختيار القارئ.
  - إضافة واجهة Player بسيطة (أزرار تشغيل/إيقاف، شريط تقدم) والاستهلاك من `AudioCubit`.
- الإعدادات:
  - شاشة إعدادات تضبط الثيم، حجم الخط، علامة نهاية الآية، والقارئ.

## مهام شائعة (كيف أفعل؟)
- إضافة زر لتبديل الثيم:
  - استدعِ `context.read<SettingsCubit>().setTheme(ThemeMode.dark)` أو `light`.
- تغيير حجم الخط:
  - `context.read<SettingsCubit>().setFontScale(1.2)`.
- إظهار/إخفاء علامة نهاية الآية:
  - `context.read<SettingsCubit>().toggleVerseEndSymbol(false)` ثم إعادة تحميل الآيات عبر `QuranCubit.reloadCurrent(verseEndSymbol: false)` إذا كنت تعرض آيات برمجياً.
- تشغيل سورة:
  - عبر `AudioCubit`: `await context.read<AudioCubit>().prepareAndPlaySurah(1);`
  - أو: `final url = await context.read<AudioRepository>().prepareSurah(surah: 1); await context.read<AudioCubit>().setUrl(url); await context.read<AudioCubit>().play();`

## استكشاف الأخطاء
- الشاشة فارغة/لا تظهر قائمة السور:
  - هذا متوقع إن اعتمدت على `QuranCubit` فقط لأن `QuranLocalDataSource` فارغ. حالياً العرض يتم عبر `quran_library` داخل `SurahListPage`.
- الصوت لا يعمل:
  - تأكد من وجود `assets/audio/audio_urls.json` ومساره مطابق في `pubspec.yaml`.
  - تحقق من اتصال الشبكة وصلاحيات الإنترنت على Android/iOS لأن الروابط خارجية.
- الثيم لا يتغير:
  - تأكد من استدعاء `SettingsCubit.setTheme` وأن `MaterialApp.themeMode` يرتبط بـ `SettingsState` (مربوط بالفعل في `main.dart`).

## معايير وتنظيم
- حافظ على الفصل بين: presentation / domain / data.
- استخدم `Equatable` للحالات والنماذج.
- سجّل كل خدمة في `service_locator.dart` واستخدم `sl<T>()` للحقن.
- التزم بتسمية عربية واضحة في الواجهة، والإنجليزية في الكود.

## خريطة سريعة للملفات الهامة
- `lib/main.dart`
- `lib/core/di/service_locator.dart`
- `lib/core/theme/app_theme.dart`, `lib/core/theme/app_colors.dart`
- `lib/features/quran/...`
- `lib/features/audio/...`
- `lib/features/settings/...`

انتهى. أي إضافة تريدها (شاشة إعدادات، تنفيذ مصدر بيانات القرآن، أو ربط الصوت بمشغل واضح)، اخبرني لأضبط الملفات اللازمة مباشرة.
