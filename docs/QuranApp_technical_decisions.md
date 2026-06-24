# QuranApp — Technical Decisions Log

---

## 1. Framework: Flutter

**What was chosen:** Flutter 3.x with Dart 3.x

**Alternatives considered:**
- React Native — JavaScript ecosystem, large community, but requires bridging for audio and Quran rendering; less consistent styling across platforms
- Native Android (Kotlin) + Native iOS (Swift) — maximum performance and platform fidelity, but doubles development effort; single developer rules this out

**Why Flutter:**
Single codebase for iOS and Android with near-native performance. Dart's strong typing and null safety reduce runtime errors. The `just_audio`, `quran_library`, and `flutter_localizations` packages — all critical to this app — have mature Flutter implementations. Flutter's widget model makes complex layouts (mini player above nav bar, pinned tab bar in nested scroll) straightforward.

---

## 2. Architecture: Clean Architecture (Feature-First)

**What was chosen:** Clean Architecture with feature-first folder structure; domain / data / presentation layers per feature

**Alternatives considered:**
- MVVM with no explicit layer separation — simpler for small apps, but mixes concerns and makes the data layer hard to swap
- MVC — not a Flutter-native pattern; doesn't map well to reactive state
- Feature-first with full package separation (Flutter package per feature) — strongest isolation, but significant tooling overhead for a solo project

**Why Clean Architecture:**
The storage strategy was expected to evolve (SharedPreferences → possibly SQLite or cloud). Clean Architecture's repository abstraction allows swapping the data layer without touching Cubits or UI. The feature-first variant was chosen over layer-first because it keeps all files for one feature navigable without jumping between top-level folders — which is more productive for solo development.

---

## 3. State Management: flutter_bloc (Cubit)

**What was chosen:** `flutter_bloc` package using the Cubit subclass (not full BLoC with Events)

**Alternatives considered:**
- Full BLoC with Events — adds `Event` classes and `on<Event>` handlers; provides debounce/switchMap transformers; suitable when event transformation is needed
- Riverpod — more composable, no BuildContext dependency, excellent for complex dependency graphs; has a steeper learning curve
- Provider — simpler but no built-in state history, harder to test, no devtools integration
- GetX — combines routing, DI, and state; very compact but opinionated and couples concerns that should be separate

**Why Cubit:**
No event transformation, debouncing, or event replay is needed in this app. Every user interaction has a direct 1:1 method call. Cubit provides the same stream infrastructure as BLoC (BlocBuilder, BlocListener, context.read, devtools integration) with simpler call sites. Using Equatable on states ensures value equality and prevents redundant widget rebuilds. If a search-with-debounce feature is added later, the individual HomeCubit can be upgraded to full BLoC without affecting other Cubits.

---

## 4. Dependency Injection: GetIt

**What was chosen:** `get_it` as a service locator

**Alternatives considered:**
- `provider` at root — couples DI and state management; works but makes the widget tree noisy with non-state dependencies
- `riverpod` providers — excellent DI mechanism, but adds Riverpod as a state management dependency on top of flutter_bloc
- Injectable + GetIt (code generation) — would add compile-time safety and eliminate manual registration boilerplate; reasonable upgrade

**Why GetIt:**
Simple, well-understood, zero Flutter dependency in the core DI code. The `sl<T>()` pattern is readable. Registration happens in `setupLocator()` before `runApp()`, so all services are available synchronously from the first frame. The composition root is a single file (`service_locator.dart`), making the dependency graph easy to audit. The trade-off is that it's a service locator (not true DI), which makes dependencies implicit — but for a single-developer project this is an acceptable cost.

---

## 5. Audio Engine: just_audio + audio_session

**What was chosen:** `just_audio ^0.10.5` for playback, `audio_session ^0.2.2` for OS audio focus

**Alternatives considered:**
- `audioplayers` — simpler API, but less granular stream access; no built-in `ProcessingState` for buffering detection; fewer native format options
- `flutter_sound` — more recording-oriented, overkill for playback-only use case
- Platform channels + native AVAudioPlayer / ExoPlayer — maximum control, but double the implementation effort

**Why just_audio:**
Provides typed reactive streams (`positionStream`, `durationStream`, `playerStateStream`) that map directly to the Cubit's reactive state model. `ProcessingState` enum enables precise buffering detection. `audio_session` integration handles OS audio focus (phone call interruption, headphone unplug events) transparently. Both packages are maintained by the same author (ryanheise) with consistent API design.

---

## 6. Background Downloads: background_downloader

**What was chosen:** `background_downloader ^8.7.2`

**Alternatives considered:**
- `dio` with manual file writing — works for foreground downloads, but cannot survive app backgrounding; no built-in progress stream
- `flutter_downloader` — older package, less active maintenance, SQLite-backed queue (overkill for 114 files)
- Native platform channels — maximum control, but significant platform code

**Why background_downloader:**
Provides a `progressStream(surah)` that fits directly into the reactive Cubit pattern. Survives app backgrounding, allowing users to minimize the app while a surah downloads. Active maintenance and clean API.

---

## 7. Local Storage: SharedPreferences

**What was chosen:** `shared_preferences ^2.5.4` with JSON serialization for all local data

**Alternatives considered:**
- `sqflite` — relational database; appropriate for structured queries; requires schema migration management
- `isar` — embedded NoSQL Dart-native database; typed objects, indexes, fast reads
- `hive` — key-value store like SharedPreferences but supports complex typed objects natively; faster than SharedPreferences for large data
- Firebase Firestore (local cache) — would require authentication and Firebase setup

**Why SharedPreferences:**
For the data volumes expected at launch (tens of notes, 114 favourites, a few goals), JSON-in-SharedPreferences has negligible read performance. It adds zero native dependencies, has no schema migration concerns, and is immediately familiar to any Flutter developer reviewing the code. The trade-off is explicitly documented: if `StudyToolsService` grows beyond a few hundred entries or needs complex queries, migration to Isar is the planned path.

---

## 8. Quran Content: quran_library + quran packages

**What was chosen:** `quran_library ^2.3.3` and `quran ^1.4.1`

**Alternatives considered:**
- Custom Quran JSON bundled in assets — full control over data format, no external package dependency, but requires building the reader UI from scratch
- Remote Quran API (e.g., api.alquran.cloud) — always up-to-date, but requires internet; adds network failure surface; slower load time

**Why these packages:**
`quran_library` provides a complete page-based Quran reader widget with surah/juz/hizb navigation, bookmark support, and Arabic text rendering — eliminating weeks of text rendering work. `quran` provides utility functions (surah names, verse counts, page lookups). The combination handles the entire reading experience without a custom renderer. The main risk is external package maintenance dependency, which is an accepted trade-off.

---

## 9. Localization: ARB Pipeline (flutter_localizations + intl)

**What was chosen:** Flutter's official ARB-based localization with code generation, wrapped in a `BuildContext` extension (`context.tr`)

**Alternatives considered:**
- `easy_localization` — simpler setup, JSON-based, runtime key lookup; but loses compile-time safety (typos in keys compile fine and crash at runtime)
- `get` translations — couples localization to GetX state management, which conflicts with flutter_bloc
- Manual string constants — no runtime switching, no translation tooling support

**Why ARB:**
The ARB pipeline generates typed Dart classes from `.arb` files, making all translation keys compile-time safe. A missing translation is a compile error, not a runtime blank. The `BuildContext` extension (`context.tr`) provides ergonomic access (`t.appTitle` instead of `AppLocalizations.of(context)!.appTitle`). The pipeline is the Flutter team's official recommendation and integrates with translation tools that read ARB format.

---

## 10. Responsive Scaling: flutter_screenutil

**What was chosen:** `flutter_screenutil ^5.9.3` with a `390×844` design baseline

**Alternatives considered:**
- `MediaQuery.of(context).size` manual calculations — verbose, no `.r` / `.sp` / `.w` shorthand
- Fixed pixel values — breaks on tablets and unusual aspect ratios
- `LayoutBuilder` — appropriate for individual adaptive components, not for global scaling

**Why flutter_screenutil:**
The UI was designed in Figma at `390×844` (iPhone 12 baseline). `flutter_screenutil` provides a `.r` / `.w` / `.h` / `.sp` extension syntax that scales values relative to the design baseline, making the Figma-to-Flutter translation direct and consistent. `minTextAdapt: true` prevents text from scaling so large it overflows fixed containers.

---

## 11. Navigation: Imperative Navigator.push

**What was chosen:** Imperative `Navigator.of(context).push(MaterialPageRoute(...))` throughout

**Alternatives considered:**
- GoRouter — declarative, URL-based, deep-link-ready, works with bottom navigation state; the Flutter team's current recommendation
- AutoRoute — code-generated typed route classes; excellent for large apps with many routes
- Beamer — another declarative router; less common

**Why imperative Navigator:**
At the time of development, the app had a small number of screens with simple linear navigation flows. Imperative push/pop was the fastest implementation path. **This is the biggest architecture decision I would change** — see the "Decisions I Would Change" section below.

---

## 12. Code Generation: flutter_gen

**What was chosen:** `flutter_gen_runner ^5.7.0` for typed asset constants

**Alternatives considered:**
- Manual string constants (e.g., `static const icSearch = 'assets/icons/ic_search.svg'`) — works but typos cause runtime errors, no IDE autocomplete for asset names
- No constants — direct string literals in widget code — unmaintainable

**Why flutter_gen:**
Generates a typed `AppAssets` class (or whatever namespace is configured) from `pubspec.yaml`'s asset declarations. Using `AppAssets.icSearch` instead of `'assets/icons/ic_search.svg'` makes asset references refactor-safe and IDE-navigable. The generator runs as part of `build_runner` alongside other generators.

---

## 13. Feature Flags: SharedPreferences-backed FeatureFlagsService

**What was chosen:** A custom `FeatureFlagsService` that reads/writes a JSON flag map to SharedPreferences

**Alternatives considered:**
- Firebase Remote Config — remote flag updates without app release; but requires Firebase setup and internet for updates
- Hardcoded `const bool kFeatureX = true` — compile-time only; cannot be toggled at runtime or per-device
- No feature flags — ship all features always

**Why custom local flags:**
For a solo developer shipping a v1 app, Firebase Remote Config adds operational overhead (Firebase project, console access, network dependency). The local approach allows: (a) testing features independently during development, (b) disabling crash reporting or analytics in debug builds, (c) a future upgrade path to Remote Config by simply changing `FeatureFlagsService`'s backing store. The flag keys are defined as constants in the service class to prevent typo-based silent failures.

---

## Decisions I Would Change in Hindsight

| Decision | Problem | What I Would Do Instead |
|---|---|---|
| Imperative `Navigator.push` | No deep linking, no URL-based navigation, back stack is fragile with bottom nav | Replace with GoRouter; define typed route classes for every screen; add deep link support for "open surah X" |
| SharedPreferences for StudyToolsService | JSON deserialization of large note/tag lists is O(n) on every read; no query support | Migrate to Isar for typed, indexed, queryable local storage while keeping the same service interface |
| No tests | Cannot safely refactor without fear of regression; undetectable AudioCubit state machine bugs | Start with unit tests for all Cubits and services using `bloc_test` and `mocktail` from day one |
| Font scale frozen at 1.0 | Breaks accessibility for users who rely on large text | Audit all fixed-height containers, use `FittedBox` and flexible layouts, then remove the scale override |
| `audio_repository_impl_fixed.dart` filename | The `_fixed` suffix signals a patch rather than a clean design; confusing for reviewers | Rename to `audio_repository_impl.dart`; document the fix reason in a code comment or git commit message |
| No CI/CD | No automated lint/test/build gate; regressions ship to production | Add GitHub Actions: `flutter analyze`, `flutter test`, `flutter build apk --release` on every PR |
| App icon is a personal photo | Inappropriate for an open-source portfolio project; may have licensing issues | Create a proper branded icon (a stylized Quran book or geometric Islamic pattern) |
