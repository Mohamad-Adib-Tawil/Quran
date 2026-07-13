# Feature: Audio

## What it does
تشغيل تلاوات القرآن الكريم — دعم تحميل السور محلياً، بث مباشر، تحكم بشاشة القفل/الإشعارات، مؤقت نوم، تكرار، وسرعة تشغيل.

## File Map
```
lib/features/audio/
├── data/
│   ├── datasources/
│   │   ├── audio_player_data_source.dart    — wrapper على just_audio (play/pause/seek/speed)
│   │   ├── audio_remote_data_source.dart    — يقرأ JSON assets ويوفّر روابط السور
│   │   ├── audio_cache_data_source.dart     — فحص وجود ملف مُخزَّن مؤقتاً
│   │   └── audio_storage_data_source.dart   — مسارات التخزين الدائم للملفات المحمَّلة
│   └── repositories/
│       ├── audio_repository_impl_fixed.dart — impl لـ AudioRepository (⚠️ اسم خاطئ، يحتاج rename)
│       └── audio_download_repository_impl.dart — تحميل السور + progress stream
├── domain/
│   └── repositories/
│       ├── audio_repository.dart            — abstract: play/pause/seek/streams
│       └── audio_download_repository.dart   — abstract: download/isDownloaded/progress
├── presentation/
│   ├── cubit/
│   │   ├── audio_cubit.dart                 — 🔥 كل منطق التشغيل (400+ سطر)
│   │   ├── audio_state.dart                 — AudioState + AudioPhase + RepeatMode + AudioErrorKind
│   │   ├── audio_download_cubit.dart        — Cubit منفصل لصفحة إدارة التحميلات
│   │   └── audio_download_state.dart        — حالات صفحة التحميلات
│   ├── pages/
│   │   ├── full_player_page.dart            — صفحة المشغّل الكامل
│   │   └── audio_downloads_page.dart        — إدارة السور المحمَّلة
│   └── widgets/
│       ├── mini_player.dart                 — شريط التشغيل السريع (يتابع وقت الاستماع كل 15ث)
│       ├── audio_settings_sheet.dart        — إعدادات السرعة والتكرار والتحميل
│       └── surah_auto_sync.dart             — مزامنة السورة الحالية مع ويدجت آخر قراءة
├── settings/
│   ├── audio_settings_cubit.dart            — Cubit لإعدادات الصوت (speed/repeat/autoDownload)
│   ├── audio_settings_service.dart          — SharedPreferences للإعدادات
│   └── audio_settings_state.dart            — حالة الإعدادات
└── CLAUDE.md
```

## Key Classes
| Class | File | Responsibility |
|-------|------|----------------|
| `AudioCubit` | cubit/audio_cubit.dart | آلة الحالة المركزية — كل تشغيل/تحميل/تحكم |
| `AudioState` | cubit/audio_state.dart | حالة immutable كاملة مع `copyWith` sentinel |
| `AudioPhase` | cubit/audio_state.dart | `idle\|preparing\|playing\|paused\|downloading\|awaitingConfirmation\|error` |
| `AudioRepositoryImpl` | repositories/audio_repository_impl_fixed.dart | يُغلّف `AudioPlayerDataSource` |
| `AudioDownloadRepositoryImpl` | repositories/audio_download_repository_impl.dart | تحميل + `progressStream` |
| `QuranAudioHandler` | services/quran_audio_handler.dart | ربط just_audio بـ audio_service (Lock Screen) |

## Play Flow (أهم تسلسل)
```
playSurah(surah)
  ├── isDownloaded? → YES → confirmAndPlaySurah() → prepareSurah() → play()
  └── NO → emit(awaitingConfirmation)
             ↓ user confirms
         confirmAndPlaySurah()
           ├── autoDownload=true → _startDownloadFlow() → [progress stream] → prepareSurah() → play()
           └── autoDownload=false → playFromCatalog()  ← بث مباشر من CDN
```

## AudioState Key Fields
| Field | Type | Notes |
|-------|------|-------|
| `currentSurah` | int? | السورة المُختارة في الـ UI |
| `loadedSurah` | int? | السورة المحمَّلة فعلاً في المحرّك |
| `pendingSurah` | int? | تنتظر موافقة المستخدم |
| `phase` | AudioPhase | حالة المشغّل الرئيسية |
| `isBuffering` | bool | منفصل عن phase لتجنب وميض الـ UI |
| `errorKind` | AudioErrorKind | `none\|network\|source\|unknown` |

## Known Issues
- [ ] `audio_repository_impl_fixed.dart` — اسم الملف خاطئ، يحتاج rename إلى `audio_repository_impl.dart`
- [ ] `AudioSettingsCubit` يُنشأ في `main.dart` ولكن يحتاج `ctx.read<AudioCubit>()` — ترتيب حساس

## Dependencies
- **يستخدم:** `ConnectivityService`, `AudioUrlCatalogService`, `QuranAudioHandler`, `AudioSessionManager`
- **يُستخدَم من:** `HomeScreen`, `MainShell`, `MiniPlayer`, `FullPlayerPage`, `SurahDetailsPage`
- **CDN المسموح به:** `https://quran.devmmnd.com/quran-audio/` فقط (مُتحقَّق في `playFromCatalog`)

## Last Updated
2026-06-27 — initial memory generation
