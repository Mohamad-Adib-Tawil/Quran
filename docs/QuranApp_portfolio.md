# QuranApp — Portfolio Case Study

---

## Overview

**Quran App** (القرآن الكريم) is an offline-capable mobile application built with Flutter for iOS and Android that allows users to read and listen to the Holy Quran. The app supports browsing the full Quran by Surah (chapter), Juz (part), and Hizb (quarter), plays audio recitations via streaming or downloaded files, and provides a personal study system for tagging ayahs, writing notes, and tracking daily and weekly reading goals.

**Problem it solves:** Most Quran apps are bloated, require continuous internet connectivity for audio, or lack meaningful study tools. This app is built around three focused pillars: reading, listening (including fully offline), and structured personal study — all in one product with no backend dependency.

---

## My Role

Sole Flutter developer responsible for the complete product lifecycle:

- Full system architecture design (Clean Architecture, feature-first structure)
- Audio engine design and implementation (state machine, download flow, streaming)
- Local persistence layer design (SharedPreferences JSON schema, study tracking)
- UI implementation from Figma specifications (design tokens, responsive scaling)
- Dependency injection setup and service registration
- Localization pipeline configuration (ARB, Arabic, German)
- Performance tuning and error handling strategy

---

## Main Features

| Feature | Description |
|---|---|
| Quran Reader | Full Quran reading with page-based display via the `quran_library` package, navigable by surah, juz, or hizb |
| Three-Tab Index | Home screen with Surah / Juz / Hizb tabs, real-time search filtering, and surah metadata (revelation type, verse count) |
| Audio Playback | Stream or play downloaded recitations; persistent mini player visible across all screens |
| Full Audio Player | Dedicated full-screen player with seek bar, repeat mode selector, speed control (0.5×–2×), sleep timer, and download-on-demand |
| Audio Download | Background per-surah download with real-time progress indicator; manage and delete downloads from a dedicated screen |
| Last Read Tracking | Automatically saves last opened surah + ayah and restores it on next launch with a "Continue Reading" card on the home screen |
| Favourites | Star any surah; favourites list persists locally and shows in a dedicated tab |
| Study Hub | Tag ayahs with colour-coded labels (review, hifz, tadabbur), write timestamped notes per ayah, track daily and weekly goals |
| Goal Tracking | Set targets for pages read, ayahs read, or listening minutes per day or week with a progress snapshot system |
| Settings | Light/dark theme switching, language selection (Arabic / German), all persisted locally |
| Feature Flags | Runtime-configurable feature toggles (mini player, downloads, analytics, crash reporting) stored in SharedPreferences |

---

## Technical Implementation

### Architecture

The project uses **Clean Architecture** with a **feature-first folder structure**. Each feature is a self-contained vertical slice:

```
features/
  audio/
    data/
      datasources/   ← AudioPlayerDataSource, AudioRemoteDataSource,
                        AudioCacheDataSource, AudioStorageDataSource
      repositories/  ← AudioRepositoryImpl, AudioDownloadRepositoryImpl
    domain/
      repositories/  ← AudioRepository (abstract), AudioDownloadRepository (abstract)
    presentation/
      cubit/         ← AudioCubit, AudioDownloadCubit, AudioSettingsCubit
      pages/         ← FullPlayerPage, AudioDownloadsPage
      widgets/       ← MiniAudioPlayer, AudioSettingsSheet, SurahAutoSync
```

Shared infrastructure lives in `lib/core/` (DI, theme, localization, logging, feature flags) and `lib/services/` (cross-feature stateful services: LastReadService, FavoritesService, StudyToolsService, AudioSessionManager, AudioUrlCatalogService).

The dependency rule is strictly observed: domain layer has zero Flutter/platform imports; data layer implements domain contracts; presentation layer only calls Cubit methods and reads states.

### State Management

**flutter_bloc Cubit** is used throughout. Cubit was chosen over full BLoC to eliminate `Event` boilerplate for methods that have no need for event transformation or debouncing.

Key Cubits and their states:

| Cubit | State | Responsibility |
|---|---|---|
| `AudioCubit` | `AudioState` (phase, isPlaying, isBuffering, position, duration, surah, url, repeatMode, speed, sleepTimer, downloadProgress, errorMessage) | Complete audio playback state machine |
| `AudioDownloadCubit` | `AudioDownloadState` | Per-surah download status |
| `AudioSettingsCubit` | `AudioSettingsState` | User audio preferences (speed, repeat, autoDownload) |
| `SettingsCubit` | `SettingsState` | App theme + locale |
| `QuranCubit` | `QuranState` | Surah metadata list |
| `HomeCubit` | `HomeState` | Search query + filtered surah list |

Global Cubits (`AudioCubit`, `QuranCubit`, `SettingsCubit`, `AudioSettingsCubit`) are registered at the root `MultiBlocProvider` in `main.dart`. Feature-scoped Cubits (`HomeCubit`) are provided within their feature subtree.

### Data Flow

```
Widget
  └─ BlocBuilder<Cubit, State> (reads state for display)
  └─ User gesture → Cubit.method()
       └─ Cubit calls Repository (abstract interface from domain layer)
            └─ RepositoryImpl delegates to DataSource(s)
                 └─ DataSource interacts with:
                      AudioPlayer (just_audio)
                      FileSystem (path_provider + dart:io)
                      SharedPreferences
                      HTTP/HTTPS (just_audio streaming)
                      background_downloader
```

Audio state is driven by reactive streams (`positionStream`, `durationStream`, `playerStateStream`) from `just_audio`, subscribed in `AudioCubit._bind()`, so the UI always reflects real engine state rather than optimistic local state.

### API Integration

There is **no traditional REST API or GraphQL backend**. Audio files are served from a fixed HTTPS CDN:

```
https://quran.devmmnd.com/quran-audio/<filename>
```

The URL catalog for all 114 surahs is loaded from a **bundled JSON asset** (`assets/audio/audio_urls.json`) at app startup by `AudioUrlCatalogService`. This avoids a network call for catalog lookup and makes the app functional even with limited connectivity.

All audio URLs are validated before use:
1. Must start with `https://`
2. Must match the allowed prefix `https://quran.devmmnd.com/quran-audio/`

Any violation throws a `StateError` and emits `AudioPhase.error` — preventing playback from unauthorized sources.

### Local Storage

All persistence uses **SharedPreferences** with structured JSON encoding. No SQLite or external database is used.

| Service | Key Strategy | Data Shape |
|---|---|---|
| `FavoritesService` | Single string list key | `List<String>` of surah numbers |
| `LastReadService` | Individual keys per field | `surah`, `ayah`, `page` as integers |
| `AudioSettingsService` | Individual keys | speed (double), repeatMode (string), autoDownload (bool) |
| `FeatureFlagsService` | Single JSON map key | `Map<String, bool>` of flag names |
| `StudyToolsService` | 5 structured keys | Tags: JSON map keyed by `ayahUq`; Notes: JSON list; Goals: JSON map; Daily/weekly stats: nested JSON with date-bucket keys |

The `StudyToolsService` uses integer sets (serialized as JSON arrays) for unique counting (e.g., unique pages read today) and simple counters for accumulation (e.g., total listening seconds).

### Authentication

**This application has no authentication.** There is no user login, registration, or session management. All data is stored locally on the device and is not associated with any user account. This is by design — the app is fully self-contained.

### Reusable Components

| Component | Location | Reuse |
|---|---|---|
| `MiniAudioPlayer` | `features/audio/presentation/widgets/` | Used in `MainShell` and `QuranSurahPage`; doubles as a listening-time tracker (fires `trackListeningSeconds(15)` every 15s when playing) |
| `SurahListItem` | `features/quran/presentation/widgets/list/` | Used in Home (surah tab) and Favourites |
| `JuzListItem`, `HizbListItem` | same | Used in Home juz/hizb tabs |
| `ListDivider` | same | Used across all list views |
| `NumberStarBadge` | same | Surah number badge with optional star indicator |
| `AudioSettingsSheet` | `features/audio/presentation/widgets/` | Bottom sheet for speed/repeat/sleep-timer settings, opened from both mini and full player |
| `SurahNameResolver` | `core/quran/` | Centralised surah name lookup utility shared across features |
| `AppAssets` | `core/assets/` | flutter_gen-generated typed asset path constants — eliminates stringly-typed asset paths |
| Design tokens | `core/theme/` | `FigmaPalette`, `FigmaTypography`, `DesignTokens`, `AppColors` — Figma-sourced constants consumed by `AppTheme.light()` and `AppTheme.dark()` |

### Error Handling

**Application startup:**
```dart
await runZonedGuarded(() async {
  // ...
  FlutterError.onError = (details) async {
    FlutterError.presentError(details);
    await crash.recordFlutterError(details);
  };
  runApp(const QuranApp());
}, (error, stack) async {
  await crash.recordError(error, stack);
});
```
The `CrashReporter` is wired after DI is ready so it can use the registered `AppLogger` singleton.

**Audio errors:**
Every `AudioCubit` method wraps its async logic in try-catch and emits `AudioPhase.error` with a human-readable Arabic error message. The UI renders a dedicated error widget with a retry button that calls `AudioCubit.retry()`, which replays the last requested surah.

**Audio URL validation:**
HTTPS and prefix checks are explicit guards inside `playFromCatalog()` — invalid sources throw `StateError` before touching `just_audio`, preventing any unintended external URL playback.

**Download failures:**
`_startDownloadFlow()` listens to the progress stream and detects `DownloadStatus.failed` or `DownloadStatus.canceled`, cancelling the subscription and emitting `AudioPhase.error` with an actionable message.

### Performance Considerations

| Optimization | Implementation |
|---|---|
| Selective BlocBuilder rebuilds | `FullPlayerPage` uses `buildWhen` to skip rebuilds on position/duration/buffering changes — only rebuilds on structural state changes (surah change, phase change, error) |
| Responsive scaling | `flutter_screenutil` with `390×844` Figma baseline and `minTextAdapt: true` |
| Font scale freeze | `MediaQuery` override at app level fixes `textScaler` to `1.0`, preventing layout overflow from OS-level text size settings |
| Stream subscription lifecycle | `AudioCubit._bind()` cancels existing subscriptions before attaching new ones; `close()` cancels all before super call |
| Lazy DI registration | GetIt `registerLazySingleton` for services — only instantiated on first use |
| State emit guards | `AudioCubit` checks `if (state.isPlaying != playing || state.phase != nextPhase || state.isBuffering != buffering)` before emitting on `playerStateStream` to prevent redundant state transitions |

---

## Challenges & Solutions

### Challenge 1: Audio state machine complexity

**Problem:** Audio playback has many overlapping async states — the player can be buffering while also being "playing" (from the user's perspective), or "completed" while still having a loaded source. Mixing these in a flat boolean set led to inconsistent UI.

**Solution:** Introduced an explicit `AudioPhase` enum with 8 distinct values. The `playerStateStream` listener maps `(processingState, playing)` pairs to `AudioPhase` values with a stable-phase rule: during `loading`/`buffering`, if a surah is already selected, the phase stays as `playing` or `paused` rather than flipping to `preparing`. This keeps the UI stable while the engine buffers.

### Challenge 2: Preventing UI jitter from position streams

**Problem:** `just_audio`'s `positionStream` fires multiple times per second. Subscribing a `BlocBuilder` to the full `AudioState` means the entire player UI rebuilds hundreds of times per minute, causing visible jitter on lower-end devices.

**Solution:** Applied `buildWhen` in `FullPlayerPage` to filter out position, duration, and buffering updates from the main rebuild path. Progress/seek UI uses dedicated inner widgets with their own state or `BlocSelector` that subscribe only to the specific fields they need.

### Challenge 3: Study stats without a relational database

**Problem:** Daily/weekly tracking required: (a) counting unique items (e.g., unique pages read today — reading the same page twice should not count twice), and (b) accumulating counters (e.g., total listening seconds). Both needed to be scoped to calendar days and weeks.

**Solution:** Each time bucket (day or week) is stored as a JSON sub-map keyed by an ISO date string (e.g., `"2024-01-15"`). Unique items use integer sets stored as JSON arrays with deduplication on read. Counters use simple integer increment. The entire structure serializes to a single `SharedPreferences` string, making reads O(1) with no query overhead.

### Challenge 4: Audio URL security

**Problem:** `just_audio` can play any URL. If the URL catalog or any other code path passed an unvalidated URL (e.g., `http://`, a different domain, or a local attacker-controlled path), it could result in playing unintended content.

**Solution:** `playFromCatalog()` validates every URL against two guards before touching the player: (1) must start with `https://`, and (2) must start with the specific allowed prefix `https://quran.devmmnd.com/quran-audio/`. Both guards throw `StateError` with descriptive messages that are surfaced to the user through the error state.

### Challenge 5: Audio session restoration on app restart

**Problem:** `just_audio` does not persist playback state across process restarts. Users expected to return to the app and see their last-played surah, even without audio actively playing.

**Solution:** `AudioSessionManager` reads the last-played surah from `SharedPreferences` on startup and calls `session.restoreIfNeeded(cubit)` in a non-blocking `addPostFrameCallback`, restoring the UI state (surah name, selected surah) without auto-starting playback.

---

## Technologies Used

| Category | Technology | Version |
|---|---|---|
| Framework | Flutter | 3.x |
| Language | Dart | 3.x |
| State Management | flutter_bloc (Cubit) | ^9.1.1 |
| Dependency Injection | GetIt | ^9.2.0 |
| Audio Engine | just_audio | ^0.10.5 |
| Audio Focus | audio_session | ^0.2.2 |
| Background Downloads | background_downloader | ^8.7.2 |
| Local Storage | shared_preferences | ^2.5.4 |
| Quran Content | quran_library | ^2.3.3 |
| Quran Utilities | quran | ^1.4.1 |
| Responsive UI | flutter_screenutil | ^5.9.3 |
| SVG Rendering | flutter_svg | ^2.0.10+1 |
| Fonts | google_fonts | ^6.2.1 |
| Localization | flutter_localizations + intl | ^0.20.2 |
| File Caching | flutter_cache_manager | ^3.3.1 |
| File Paths | path_provider | ^2.1.4 |
| Content Sharing | share_plus | ^11.0.0 |
| Bottom Sheet | sliding_up_panel | ^2.0.0+1 |
| Code Generation | flutter_gen + build_runner | ^5.7.0 / ^2.4.8 |
| App Icons | flutter_launcher_icons | ^0.13.1 |
| Splash Screen | flutter_native_splash | ^2.4.0 |
| State Equality | equatable | ^2.0.7 |

---

## Results / Impact

- Fully **offline-capable** after initial audio download — no backend infrastructure, no ongoing server costs, no authentication surface
- Clean Architecture enables adding new features (Tafsir, search, cloud sync, additional reciters) **without modifying existing layers**
- The study tools system provides genuine engagement tracking entirely client-side, with no privacy concerns from cloud data collection
- Feature flags infrastructure allows shipping new features to production hidden behind a flag, enabling controlled rollout without separate builds
- The audio download + streaming hybrid means users get full offline use on low-connectivity networks with no mandatory pre-download step
