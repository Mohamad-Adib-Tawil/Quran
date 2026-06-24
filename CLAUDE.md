# Quran App — Project Memory

## App Identity
- **Name:** Quran App (القرآن الكريم)
- **Package:** `quran_app`
- **Version:** 1.0.3+3
- **Platform:** Android + iOS
- **Type:** Quran reading + audio recitation app — no backend, no auth, fully local

## Architecture
- **Pattern:** Clean Architecture — feature-first folder structure
- **Layers per feature:** `data/` (datasources + repo impls) → `domain/` (abstract repos + entities) → `presentation/` (Cubit + Pages + Widgets)
- **Composition root:** `lib/core/di/service_locator.dart` — only file that knows concrete types
- **DI:** GetIt (`sl<T>()` pattern), all registered in `setupLocator()` before `runApp()`
- **Shared infrastructure:** `lib/core/` (theme, DI, localization, logging, feature flags) + `lib/services/` (cross-feature services)

## State Management
- **Package:** `flutter_bloc ^9.1.1` — **Cubit only** (no BLoC Events)
- **Root Cubits (MultiBlocProvider in main.dart):** `SettingsCubit`, `QuranCubit`, `AudioCubit`, `AudioSettingsCubit`
- **Feature-scoped:** `HomeCubit` (provided inside HomeScreen subtree only)
- **State equality:** All states extend `Equatable`
- **Pattern:** `copyWith()` immutable state updates

## Features & Key Files

### Audio (most complex feature)
- **State machine:** `AudioPhase` enum — 8 values: `idle | preparing | playing | paused | downloading | awaitingConfirmation | error`
- **Cubit:** `lib/features/audio/presentation/cubit/audio_cubit.dart`
- **Play flow:** `playSurah()` → check downloaded → if yes: play directly; if no: emit `awaitingConfirmation` → user confirms → check `autoDownload` → download or stream from catalog
- **Audio source:** `AudioUrlCatalogService` loads `assets/audio/audio_urls.json` at startup
- **Allowed CDN prefix:** `https://quran.devmmnd.com/quran-audio/` (validated before playback)
- **Streams:** `positionStream`, `durationStream`, `playerStateStream` — all subscribed in `_bind()`, cancelled in `close()`
- **Mini player:** `lib/features/audio/presentation/widgets/mini_player.dart` — tracks listening time every 15s when playing
- **Full player:** `lib/features/audio/presentation/pages/full_player_page.dart` — uses `buildWhen` to skip position-tick rebuilds

### Quran Reader
- Powered by `quran_library ^2.3.3` + `quran ^1.4.1` packages
- Navigation target: `QuranOpenTarget` (surah / juz / hizb)
- Reader page: `lib/features/quran/presentation/pages/quran_surah_page.dart`
- **Note:** `reader_page.dart` is a stub (empty body) — not a real screen

### Home
- 3-tab layout: Surahs / Juz / Hizb
- Search via `HomeCubit.setQuery()`
- Last Read card always visible (defaults to Al-Fatiha)

### Study Tools (`lib/services/study_tools_service.dart`)
- Per-ayah tagging: `AyahTagType` (review / hifz / tadabbur) with colour codes
- Per-ayah notes: `AyahNoteEntry` with timestamp
- Daily/weekly goals: `GoalMetric` (pages / ayahs / listeningMinutes) × `GoalPeriod` (daily / weekly)
- Stats: bucket-keyed JSON in SharedPreferences (e.g. `"2024-01-15"` → `{pages: [1,2,3], ayahs: [...], listenSec: 300}`)
- Unique counting via integer sets; accumulation via counters

### Settings
- Theme: `ThemeMode` (light/dark/system) — stored in SharedPreferences
- Locale: `localeCode` string — switched dynamically via `SettingsCubit`
- Languages: Arabic (`ar`), German (`de`)

## Local Storage (All SharedPreferences, no SQLite/Firebase)
| Service | Key | Data |
|---|---|---|
| FavoritesService | `favorites_surahs` | `List<String>` surah numbers |
| LastReadService | `last_read_surah` etc | individual int keys |
| AudioSettingsService | individual keys | speed, repeatMode, autoDownload |
| StudyToolsService | `study_tags_v1`, `study_notes_v1`, `study_goals_v1`, `study_daily_stats_v1`, `study_weekly_stats_v1` | JSON maps/lists |
| FeatureFlagsService | `app.feature_flags` | JSON `Map<String, bool>` |

## No Backend / No Auth
- No Firebase, no Supabase, no REST client (no Dio/http)
- No authentication — purely local app
- Audio from HTTPS CDN; URL map bundled as asset

## UI / Theme
- Responsive: `flutter_screenutil ^5.9.3` at `390×844` baseline
- Font scale frozen at `1.0` in `main.dart` (known issue — temporary)
- Design tokens: `lib/core/theme/` — `FigmaPalette`, `FigmaTypography`, `DesignTokens`, `AppColors`
- Assets: typed constants via `flutter_gen` → `AppAssets`
- Icons: SVG via `flutter_svg`; fonts via `google_fonts`

## Localization
- Pipeline: ARB → `flutter gen-l10n` → typed `AppLocalizations`
- Extension: `context.tr` → shorthand for `AppLocalizations.of(context)`
- Files: `lib/l10n/app_localizations_ar.dart`, `app_localizations_de.dart`

## Navigation (Current — Imperative)
- All navigation: `Navigator.of(context).push(MaterialPageRoute(...))`
- Main shell: `lib/features/root/presentation/pages/main_shell.dart` — `_index` int for bottom nav
- **Known gap:** no GoRouter, no deep linking

## Error Handling
- Startup: `runZonedGuarded` + `FlutterError.onError` → `CrashReporter` (logs locally)
- Audio: every Cubit method emits `AudioPhase.error` + Arabic message on catch
- Retry: `AudioCubit.retry()` replays `_lastRequestedSurah`

## Feature Flags (Runtime)
- Flags: `mini_player`, `audio_downloads`, `in_app_review`, `update_checker`, `analytics` (false), `crash_reporting` (false)
- Read via: `sl<FeatureFlagsService>().isEnabled('mini_player')`

## Known Gaps (Do Not Forget)
1. **Zero tests** — no unit/widget/integration tests
2. **`reader_page.dart`** — empty stub, should redirect to `QuranSurahPage`
3. **`audio_repository_impl_fixed.dart`** — bad filename, needs rename
4. **Font scale frozen** — breaks accessibility
5. **No CI/CD** — no GitHub Actions
6. **App icon** — personal photo, not a proper icon
7. **Navigation** — imperative only, no deep linking

## Key Packages (summary)
```
flutter_bloc: ^9.1.1      # state management
get_it: ^9.2.0            # DI
just_audio: ^0.10.5       # audio playback
audio_session: ^0.2.2     # OS audio focus
background_downloader: ^8.7.2  # background file download
shared_preferences: ^2.5.4     # all local storage
quran_library: ^2.3.3     # Quran reader widget
quran: ^1.4.1             # Quran utilities
flutter_screenutil: ^5.9.3    # responsive UI
flutter_svg: ^2.0.10+1   # SVG icons
google_fonts: ^6.2.1      # typography
share_plus: ^11.0.0       # content sharing
flutter_gen_runner: ^5.7.0    # typed asset generation
equatable: ^2.0.7         # value equality on states
intl: ^0.20.2             # localization
```

## Docs Location
All documentation in `docs/`:
- `QuranApp_cv.md` — ATS CV bullet points
- `QuranApp_portfolio.md` — full portfolio case study
- `QuranApp_interview_prep.md` — Q&A interview prep
- `QuranApp_technical_decisions.md` — decisions log with alternatives
- `QuranApp_improvements.md` — prioritized improvement plan (High/Medium/Low)
- `QuranApp_linkedin_post.md` — 3 LinkedIn post templates (AR/EN/Technical)
- `QuranApp_keywords.md` — full keyword map for CV/ATS/LinkedIn
