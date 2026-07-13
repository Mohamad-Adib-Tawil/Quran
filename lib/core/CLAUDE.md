# Core Layer

## What it does
البنية التحتية المشتركة — DI، الثيم، اللوكاليزيشن، السجلّ، Feature Flags، الأصول.

## File Map
```
lib/core/
├── di/
│   └── service_locator.dart    — 🔥 setupLocator() — نقطة تجميع كل التبعيات
│                                  الترتيب مهم: externals → async → lazy → repos
├── theme/
│   ├── app_theme.dart          — AppTheme.light() / AppTheme.dark()
│   ├── app_colors.dart         — ألوان دلالية (primary, surface, error…)
│   ├── design_tokens.dart      — مسافات + radii + shadows
│   ├── figma_palette.dart      — ألوان خام من Figma (لا تستخدمها مباشرة)
│   └── figma_typography.dart   — TextStyles مُعرَّفة
├── config/
│   └── feature_flags.dart      — FeatureFlagsService: isEnabled(key) + toggle
├── localization/
│   ├── app_localization_ext.dart  — extension: context.tr → AppLocalizations
│   └── localization_service.dart  — قائمة اللغات + delegates + localeFromCode()
├── logging/
│   └── logging.dart            — AppLogger + CrashReporter (محلي فقط)
├── analytics/
│   └── analytics.dart          — stub فارغ (analytics مُعطَّل افتراضياً)
├── assets/
│   └── app_assets.dart         — ثوابت مسارات الأصول (flutter_gen generated)
└── quran/
    └── surah_name_resolver.dart — مساعد لاسم السورة عربي/لاتيني
```

## Feature Flags
| Flag | Default | Notes |
|------|---------|-------|
| `mini_player` | true | إظهار/إخفاء MiniPlayer |
| `audio_downloads` | true | السماح بتحميل السور |
| `in_app_review` | true | طلب تقييم التطبيق |
| `update_checker` | true | فحص التحديثات |
| `analytics` | **false** | معطَّل |
| `crash_reporting` | **false** | معطَّل |

استخدام: `sl<FeatureFlagsService>().isEnabled('mini_player')`

## DI Registration Order (setupLocator)
```
1. AudioPlayer (LazySingleton)
2. SharedPreferences (Singleton — await)
3. FeatureFlagsService, AppLogger, CrashReporter, AudioSessionManager, ConnectivityService
4. AudioSettingsService, LastReadService, FavoritesService, StudyToolsService
5. AudioUrlCatalogService (Singleton — await load())
6. DataSources (QuranLocal, AudioRemote[await], AudioPlayer, AudioCache, AudioStorage)
7. Repositories (QuranRepo, AudioDownloadRepo, AudioRepo)
8. [main.dart] QuranAudioHandler via AudioService.init()
```

## Known Issues
- Font scale مجمَّد على `1.0` في `main.dart` — يكسر accessibility
- `analytics.dart` stub فارغ — لا تُضف كود حقيقي قبل تفعيل الـ flag
- لا يوجد environment config (dev/prod URLs مُضمَّنة في الكود)

## Dependencies
- **يُستخدَم من:** كل الـ features
- **لا يعتمد على** أي feature

## Last Updated
2026-06-27 — initial memory generation
