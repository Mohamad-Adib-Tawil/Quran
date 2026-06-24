# QuranApp — Keywords Reference

All keywords are grounded in what was actually found in the codebase. None are invented.

---

## Core Flutter / Dart

| Keyword | Evidence in Codebase |
|---|---|
| Flutter | Framework used throughout |
| Dart | Language (Dart 3.x, null safety) |
| Flutter SDK 3.x | `environment: sdk: ^3.10.3` |
| Dart 3 | Null safety, pattern matching, records (AudioPhase switch expression) |
| MaterialApp | Used in `main.dart` |
| StatelessWidget / StatefulWidget | Used throughout all features |
| WidgetsBinding | `WidgetsFlutterBinding.ensureInitialized()` in main |
| StreamSubscription | Used in `AudioCubit._bind()` for reactive audio streams |
| runZonedGuarded | Used in `main()` for global error capture |
| BuildContext | Extension method (`context.tr`) and widget tree access |
| MediaQuery | Font scale override in `main.dart` |
| NestedScrollView | Used in HomeScreen for pinned tab bar |
| SliverPersistentHeader | Custom `_TabBarDelegate` in HomeScreen |
| DefaultTabController / TabBarView | Three-tab home layout |
| BottomNavigationBar / NavigationBar | `MainShell` bottom nav |
| Navigator.push / MaterialPageRoute | Imperative navigation throughout |

---

## Architecture

| Keyword | Evidence in Codebase |
|---|---|
| Clean Architecture | Three-layer feature structure (data/domain/presentation) |
| Feature-First Structure | `lib/features/audio/`, `lib/features/quran/`, etc. |
| Separation of Concerns | Domain has no Flutter imports; data has no presentation imports |
| Repository Pattern | `AudioRepository`, `AudioDownloadRepository`, `QuranRepository` abstract interfaces |
| Dependency Inversion | Cubits depend on abstract repository interfaces, not concrete implementations |
| Composition Root | `service_locator.dart` is the only place that knows concrete types |
| Service Layer | `lib/services/` — cross-feature stateful services |
| Domain Entities | `Surah`, `AyahTagEntry`, `AyahNoteEntry`, `GoalPlan` |
| Data Sources | `AudioPlayerDataSource`, `AudioRemoteDataSource`, `AudioCacheDataSource`, `AudioStorageDataSource`, `QuranLocalDataSource` |

---

## State Management

| Keyword | Evidence in Codebase |
|---|---|
| flutter_bloc | Package used (`^9.1.1`) |
| Cubit | All state management uses Cubit subclass |
| BlocBuilder | Used with `buildWhen` guards in `FullPlayerPage` |
| BlocListener | Used for side effects (dialogs, navigation) |
| BlocProvider | MultiBlocProvider at app root + feature-scoped providers |
| MultiBlocProvider | Used in `main.dart` for root Cubits |
| Equatable | All state classes extend Equatable for value equality |
| Unidirectional Data Flow | State → UI → Cubit method → new State |
| State Immutability | `copyWith()` pattern on all state classes |
| Reactive Programming | Audio driven entirely by `just_audio` stream subscriptions |
| Stream | `positionStream`, `durationStream`, `playerStateStream`, `progressStream` |

---

## Backend / APIs

| Keyword | Evidence in Codebase |
|---|---|
| RESTful / HTTPS | Audio files served from HTTPS CDN endpoint |
| JSON | URL catalog loaded from `assets/audio/audio_urls.json`; all local data serialized as JSON |
| URL Validation | HTTPS + prefix guard in `AudioCubit.playFromCatalog()` |
| CDN Integration | Audio from `quran.devmmnd.com` |
| Offline-First | App functional without internet after audio download |
| Asset Bundling | URL catalog bundled as a Flutter asset, not fetched at runtime |

> **Note:** There is no REST API client (no Dio, no http package). The "backend" is entirely CDN-served audio files. This is correct — do not claim REST API experience from this project.

---

## Authentication

| Keyword | Status |
|---|---|
| Authentication | **NOT implemented** — no user login, no sessions |
| Firebase Auth | **NOT used** |
| OAuth | **NOT used** |
| JWT | **NOT used** |

> **Important:** Do not list authentication technologies on your CV based on this project. This project has no auth layer.

---

## Firebase / Cloud

| Keyword | Status |
|---|---|
| Firebase | **NOT used** |
| Firestore | **NOT used** |
| Firebase Storage | **NOT used** |
| Firebase Crashlytics | **NOT used** (local CrashReporter logs only) |
| Cloud Functions | **NOT used** |

> **Important:** Do not list Firebase on your CV from this project. A `CrashReporter` class exists but logs locally — it is not connected to any remote crash service.

---

## Data / Models

| Keyword | Evidence in Codebase |
|---|---|
| JSON Serialization | Manual `toJson()` / `fromJson()` on all model classes |
| Data Modeling | `AyahTagEntry`, `AyahNoteEntry`, `GoalPlan`, `GoalProgressSnapshot`, `LastRead` |
| Equatable | State and entity equality |
| Enum-driven Domain | `AudioPhase`, `RepeatMode`, `AyahTagType`, `GoalMetric`, `GoalPeriod`, `DownloadStatus` |
| Value Objects | `LastRead(surah, ayah, page)` |

---

## Local Storage

| Keyword | Evidence in Codebase |
|---|---|
| SharedPreferences | `shared_preferences ^2.5.4` — all local data |
| Local Persistence | All user data persisted locally: favourites, last read, study tags, notes, goals, audio settings |
| JSON Storage | Complex data serialized to JSON strings in SharedPreferences |
| Key-Value Store | Simple settings stored as individual SharedPreferences keys |
| Offline Storage | Audio files stored locally via `background_downloader` + `path_provider` |
| File System | `path_provider` for download directory access |
| Cache Management | `flutter_cache_manager ^3.3.1` |

---

## Navigation

| Keyword | Evidence in Codebase |
|---|---|
| Navigator | `Navigator.of(context).push()` / `maybePop()` throughout |
| MaterialPageRoute | All route transitions |
| BottomNavigationBar | `MainShell` with 4 tabs |
| Named Routes | **NOT used** — only `Navigator.push` with direct widget construction |
| Deep Linking | **NOT implemented** — no GoRouter or AutoRoute |

---

## Dependency Injection

| Keyword | Evidence in Codebase |
|---|---|
| GetIt | `get_it ^9.2.0` — service locator |
| Service Locator | `sl<T>()` pattern via `GetIt.instance` |
| Singleton Registration | `registerSingleton`, `registerLazySingleton` |
| Composition Root | `setupLocator()` in `core/di/service_locator.dart` |
| Lazy Initialization | `registerLazySingleton` for deferred instantiation |

---

## Performance

| Keyword | Evidence in Codebase |
|---|---|
| buildWhen | Used in `FullPlayerPage` to suppress position-tick rebuilds |
| Selective Rebuilds | BlocBuilder with field-level comparison guards |
| Responsive UI | `flutter_screenutil ^5.9.3` with 390×844 baseline |
| Font Scale Control | `TextScaler.linear(1.0)` via MediaQuery override |
| Stream Subscription Lifecycle | Cancel on reassignment + full cancel in `close()` |
| Lazy DI | `registerLazySingleton` for deferred service creation |
| State Emit Guards | Pre-emit equality check in `playerStateStream` listener |
| Memory Management | `_cancelSubscriptions()` pattern; Timer disposed in `close()` |

---

## ML / AI

> **NOT used.** This project has no machine learning or AI components. Do not list ML/AI keywords from this project.

---

## UI / UX

| Keyword | Evidence in Codebase |
|---|---|
| Material Design 3 | `uses-material-design: true`; `NavigationBar`, `ColorScheme` |
| Dark Mode | `AppTheme.dark()` + `ThemeMode` switching via `SettingsCubit` |
| Light Mode | `AppTheme.light()` |
| Figma Design Tokens | `FigmaPalette`, `FigmaTypography`, `DesignTokens` in `core/theme/` |
| Google Fonts | `google_fonts ^6.2.1` |
| SVG Icons | `flutter_svg ^2.0.10+1` |
| Responsive Layout | `flutter_screenutil` |
| Persistent Mini Player | `MiniAudioPlayer` above bottom nav bar |
| Bottom Sheet | `AudioSettingsSheet` with sliding_up_panel |
| Pinned Tab Bar | `SliverPersistentHeader` delegate pattern |
| Custom Splash Screen | `flutter_native_splash` |
| App Icon Generation | `flutter_launcher_icons` |
| Animated Transitions | Platform-aware back icon (iOS vs Android) in `FullPlayerPage` |

---

## Localization

| Keyword | Evidence in Codebase |
|---|---|
| flutter_localizations | Official Flutter localization SDK |
| ARB Files | `lib/l10n/` — `.arb` format translation files |
| intl | `^0.20.2` |
| Multi-language | Arabic (ar) + German (de) |
| RTL Support | Arabic is the primary language; RTL layout via locale |
| Dynamic Locale Switching | `SettingsCubit.setLocale()` + `LocalizationService` |
| BuildContext Extension | `context.tr` → `AppLocalizations.of(context)` shorthand |
| Generated Localizations | `flutter gen-l10n` via `generate: true` in pubspec |

---

## Testing

| Keyword | Status |
|---|---|
| Unit Tests | **NOT present** — zero test files found |
| Widget Tests | **NOT present** |
| Integration Tests | **NOT present** |
| bloc_test | **NOT used** (but recommended for addition — see improvements doc) |
| mocktail / mockito | **NOT used** |
| flutter_test | Listed as dev dependency but no test files exist |

> **Important:** Do not list testing technologies on your CV from this project unless you add them. The honest answer in an interview is "No tests exist — this is a known gap I plan to address."

---

## DevOps

| Keyword | Status |
|---|---|
| CI/CD | **NOT implemented** |
| GitHub Actions | **NOT configured** |
| Flutter Build Pipeline | Manual (`flutter build apk`, `flutter build ipa`) |
| build_runner | Used for code generation (`flutter_gen`) |
| Version Management | `version: 1.0.3+3` in pubspec (manual) |

---

## Domain-Specific (Islamic / Quran App)

| Keyword | Relevance |
|---|---|
| Quran | Core domain |
| Surah | Chapter-level navigation |
| Ayah | Verse-level tagging, notes, tracking |
| Juz | Part-level navigation (30 parts) |
| Hizb | Quarter-level navigation |
| Hifz | Quran memorization — AyahTagType |
| Tadabbur | Contemplation/reflection — AyahTagType |
| Makki / Madani | Revelation type metadata displayed in surah list |
| Reciter / Qari | Audio reciter (single reciter, expandable) |
| Offline Quran | Audio available without internet after download |
| Arabic Typography | Google Fonts + Figma typography for proper Arabic text rendering |

---

## Recommended LinkedIn Skills

Add these to your LinkedIn profile's Skills section after completing this project. Only add what you can confidently discuss in an interview.

**Definitely add (100% supported by this project):**
- Flutter
- Dart
- Mobile Application Development
- Clean Architecture
- State Management
- flutter_bloc
- Dependency Injection
- RESTful APIs (audio CDN integration)
- UI/UX Design Implementation
- Responsive Design
- Localization (i18n)
- JSON
- Cross-Platform Development
- GetIt
- Audio/Media Integration

**Add with qualification (partially demonstrated):**
- Software Architecture (Clean Architecture demonstrated; add GoRouter and tests first)
- Performance Optimization (demonstrated via buildWhen; add more examples)
- Offline-First Development (demonstrated via audio downloads)

**Do NOT add yet (not in codebase):**
- Firebase
- Backend Development
- Authentication
- Unit Testing / TDD
- CI/CD
- Deep Linking
- SQLite / Isar

---

## Keywords for ATS Scanning

Paste these into the "Skills" and project description sections of your CV/resume. ATS systems scan for exact keyword matches.

```
Flutter
Dart
flutter_bloc
BLoC Pattern
Cubit
State Management
Clean Architecture
GetIt
Dependency Injection
just_audio
Audio Session
Background Downloads
SharedPreferences
Local Storage
JSON Serialization
ARB Localization
flutter_localizations
Internationalization
i18n
Multi-language
Responsive UI
flutter_screenutil
Material Design
Dark Mode
Light Mode
Feature-First Architecture
Repository Pattern
Reactive Programming
Stream
StreamSubscription
Singleton
Lazy Initialization
Android
iOS
Cross-Platform
Mobile Development
Offline-First
Figma
Design Tokens
SVG Icons
flutter_svg
Google Fonts
Code Generation
build_runner
flutter_gen
share_plus
path_provider
Equatable
```
