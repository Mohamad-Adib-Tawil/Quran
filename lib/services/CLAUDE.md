# Services Layer

## What it does
طبقة الخدمات المشتركة عبر كل الـ features — لا تعتمد على أي feature محدد.

## File Map
```
lib/services/
├── audio_url_catalog_service.dart   — يقرأ assets/audio/audio_urls.json → Map<surah, url>
│                                      يُحمَّل في setupLocator() قبل runApp
├── quran_audio_handler.dart         — BaseAudioHandler (audio_service) — Lock Screen + Notification
│                                      يستخدم نفس AudioPlayer من GetIt
├── audio_session_manager.dart       — يحفظ/يُعيد آخر جلسة تشغيل (surah + position)
├── connectivity_service.dart        — hasInternet() عبر connectivity_plus
├── favorites_service.dart           — SharedPreferences: قائمة السور المفضّلة
├── last_read_service.dart           — SharedPreferences: آخر سورة + آية + صفحة قُرئت
└── study_tools_service.dart         — تبويب + ملاحظات + أهداف يومية/أسبوعية لكل آية
```

## Key Classes & Methods
| Class | Key Method(s) | Storage |
|-------|--------------|---------|
| `AudioUrlCatalogService` | `load()`, `urlForSurah(int)` | Asset JSON (read-only) |
| `QuranAudioHandler` | `updateNowPlaying()`, `updateDuration()` | — (in-memory) |
| `AudioSessionManager` | `attach(cubit)`, `restoreIfNeeded(cubit)`, `save()` | SharedPreferences |
| `ConnectivityService` | `hasInternet()` → Future\<bool\> | — (live check) |
| `FavoritesService` | `addFavorite(surah)`, `removeFavorite()`, `getFavorites()` | `favorites_surahs` |
| `LastReadService` | `saveLastRead(surah, ayah, page)`, `getLastRead()` | `last_read_*` keys |
| `StudyToolsService` | `addTag()`, `addNote()`, `setGoal()`, `recordProgress()` | JSON in SharedPrefs |

## StudyToolsService — Data Model
| Feature | Key | Type |
|---------|-----|------|
| Tags | `study_tags_v1` | `Map<ayahUq, AyahTagEntry>` JSON |
| Notes | `study_notes_v1` | `Map<id, AyahNoteEntry>` JSON |
| Goals | `study_goals_v1` | `List<GoalEntry>` JSON |
| Daily stats | `study_daily_stats_v1` | `Map<"2024-01-15", {pages,ayahs,listenSec}>` |
| Weekly stats | `study_weekly_stats_v1` | `Map<"2024-W03", {...}>` |

- `AyahTagType`: `review | hifz | tadabbur`
- `GoalMetric`: `ayahs | pages | listeningMinutes`
- `GoalPeriod`: `daily | weekly`

## Known Issues
- لا يوجد migration strategy لـ SharedPreferences keys — تغيير الـ schema يكسر البيانات القديمة
- `StudyToolsService` ضخم (~400 سطر) — مرشّح للتقسيم مستقبلاً

## Dependencies
- **كل الخدمات مُسجَّلة** في `lib/core/di/service_locator.dart` كـ `LazySingleton`
- `AudioUrlCatalogService` و `AudioSessionManager` يحتاجان `await` قبل التسجيل
- `QuranAudioHandler` يُسجَّل في `main.dart` بعد `AudioService.init()`

## Last Updated
2026-06-27 — initial memory generation
