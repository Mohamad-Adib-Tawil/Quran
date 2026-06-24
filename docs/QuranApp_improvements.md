# QuranApp — Improvements Plan

---

## Priority: HIGH — Fix Before Sharing the Repository

These issues will cause a recruiter or senior developer to question code quality or professionalism if left unaddressed.

---

### H1: ReaderPage is an Empty Stub

**Problem:**
`lib/features/quran/presentation/pages/reader_page.dart` renders `SizedBox.shrink()` — a blank screen. If a recruiter runs the app and navigates to this route, they see nothing. The comment says "Placeholder screen kept for routing extensibility" but this is still a dead end.

**Fix:**
Either remove the route entirely or redirect to `QuranSurahPage` which is the actual reader. If the file must exist for routing:
```dart
class ReaderPage extends StatelessWidget {
  final int surahNumber;
  const ReaderPage({super.key, required this.surahNumber});

  @override
  Widget build(BuildContext context) {
    // Immediately delegate to the real reader
    return QuranSurahPage(
      openTarget: QuranOpenTarget.surah(surahNumber),
    );
  }
}
```

**Why it matters:**
A blank screen in a demo immediately signals "unfinished work". Recruiters demo apps — this is a first-impression killer.

---

### H2: Zero Test Coverage

**Problem:**
No test files exist anywhere in the project. The business logic — particularly `AudioCubit`'s state machine with 8 phases and `StudyToolsService`'s bucketed stats tracking — is completely untested. Any refactor risks silent regression.

**Fix:**
Add at minimum these test files:

```
test/
  features/
    audio/
      audio_cubit_test.dart    ← test all AudioPhase transitions
    quran/
      quran_cubit_test.dart
  services/
    study_tools_service_test.dart  ← test stat bucketing, uniqueness
    favorites_service_test.dart
```

Minimal `audio_cubit_test.dart`:
```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAudioRepository extends Mock implements AudioRepository {}
class MockAudioDownloadRepository extends Mock implements AudioDownloadRepository {}
class MockAudioUrlCatalogService extends Mock implements AudioUrlCatalogService {}

void main() {
  group('AudioCubit', () {
    late MockAudioRepository repo;
    late MockAudioDownloadRepository dlRepo;
    late MockAudioUrlCatalogService catalog;

    setUp(() {
      repo = MockAudioRepository();
      dlRepo = MockAudioDownloadRepository();
      catalog = MockAudioUrlCatalogService();
      // Stub streams to return empty streams
      when(() => repo.positionStream).thenAnswer((_) => const Stream.empty());
      when(() => repo.durationStream).thenAnswer((_) => const Stream.empty());
      when(() => repo.playerStateStream).thenAnswer((_) => const Stream.empty());
    });

    blocTest<AudioCubit, AudioState>(
      'playSurah emits awaitingConfirmation when not downloaded',
      build: () => AudioCubit(repo, dlRepo, catalog),
      setUp: () {
        when(() => dlRepo.isDownloaded(36)).thenAnswer((_) async => false);
      },
      act: (cubit) => cubit.playSurah(36),
      expect: () => [
        isA<AudioState>().having((s) => s.phase, 'phase', AudioPhase.awaitingConfirmation)
            .having((s) => s.pendingSurah, 'pendingSurah', 36),
      ],
    );

    blocTest<AudioCubit, AudioState>(
      'playSurah with invalid surah number emits error',
      build: () => AudioCubit(repo, dlRepo, catalog),
      act: (cubit) => cubit.playSurah(0),
      expect: () => [
        isA<AudioState>().having((s) => s.phase, 'phase', AudioPhase.error),
      ],
    );
  });
}
```

Add `bloc_test` and `mocktail` to `dev_dependencies` in `pubspec.yaml`.

**Why it matters:**
No tests is the single most common reason senior developers push back on portfolio projects. Even 5 meaningful tests signal that you understand testability, dependency injection, and separation of concerns.

---

### H3: Rename `audio_repository_impl_fixed.dart`

**Problem:**
The file `lib/features/audio/data/repositories/audio_repository_impl_fixed.dart` has `_fixed` in its name. This is a dead giveaway of an emergency patch. It reads as "the original implementation was broken and this is the band-aid version". This raises immediate questions from a code reviewer.

**Fix:**
```bash
# Rename the file
mv lib/features/audio/data/repositories/audio_repository_impl_fixed.dart \
   lib/features/audio/data/repositories/audio_repository_impl.dart
```

Update all imports and the service locator registration. If there was a specific bug that was fixed, document it in a code comment or the git commit message — but not in the filename.

**Why it matters:**
File names are the first signal of code quality. `_fixed` is a red flag in any code review.

---

### H4: Replace the Personal Photo App Icon

**Problem:**
`pubspec.yaml` sets the app icon to `assets/home/صورة الشيخ احمد كراسي الشخصية.png` — a personal photo. For a public GitHub repository or portfolio demo, this is inappropriate and may have intellectual property concerns. It also makes the app look unfinished.

**Fix:**
1. Design or source a proper app icon (a stylized Quran book, geometric Islamic pattern, or a simple letter "ق" on a solid background)
2. Place it at `assets/icons/app_icon.png` (1024×1024 minimum)
3. Update `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#1B5E20"  # dark green, thematic
```
4. Run: `dart run flutter_launcher_icons`

**Why it matters:**
The app icon is visible in the GitHub repository preview and every device demo. It is the app's visual identity. A personal photo as an icon signals that the app is a personal or unfinished project, not a professional portfolio piece.

---

### H5: Add a Basic CI/CD Pipeline

**Problem:**
There is no automated quality gate. Lint errors and broken builds can exist in the repository without detection until someone manually runs the app.

**Fix:**
Create `.github/workflows/flutter_ci.yml`:
```yaml
name: Flutter CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk --release --no-pub
```

**Why it matters:**
A CI badge on the README (✅ build passing) is a strong signal to technical recruiters. It also demonstrates DevOps awareness beyond just Flutter code.

---

## Priority: MEDIUM — Fix Before Interviews

These improvements make the project more impressive in a code walkthrough or technical discussion, but are not immediately visible in a quick demo.

---

### M1: Replace Imperative Navigation with GoRouter

**Problem:**
All navigation uses `Navigator.of(context).push(MaterialPageRoute(...))`. This means:
- No deep linking (cannot open "surah 36" from a notification or URL)
- Bottom navigation state is manually managed with an `_index` int in `MainShell`
- Back stack is fragile when navigating across tabs

**Fix:**
```dart
// lib/core/navigation/app_router.dart
final router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/favourites', builder: (_, __) => const FavoritesPage()),
        GoRoute(path: '/downloads', builder: (_, __) => const AudioDownloadsPage()),
        GoRoute(path: '/study', builder: (_, __) => const StudyHubPage()),
      ],
    ),
    GoRoute(
      path: '/surah/:number',
      builder: (context, state) {
        final n = int.parse(state.pathParameters['number']!);
        return QuranSurahPage(openTarget: QuranOpenTarget.surah(n));
      },
    ),
    GoRoute(path: '/player', builder: (_, __) => const FullPlayerPage()),
  ],
);
```

**Why it matters:**
GoRouter is Flutter's recommended navigation solution. Interviewers frequently ask "how would you add deep linking?" — having GoRouter already in place answers that question with working code.

---

### M2: Add Accessibility Support

**Problem:**
The font scale is frozen at 1.0 via `MediaQuery` override, breaking OS-level text accessibility for users who rely on large text. There are no `Semantics` widgets or `tooltip` labels on icon-only buttons.

**Fix:**
1. Remove the `textScaler` override from `main.dart`
2. Audit fixed-height containers for overflow:
```dart
// Instead of fixed height containers:
Container(height: 48, child: Text(...))
// Use:
IntrinsicHeight(child: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text(...)))
```
3. Add `Semantics` labels to icon buttons:
```dart
IconButton(
  icon: SvgPicture.asset(AppAssets.icSearch),
  tooltip: t.searchSurahHint,  // already present — good
  onPressed: ...,
)
```

**Why it matters:**
Accessibility is increasingly a baseline expectation in production apps. Freezing font scale is explicitly an anti-pattern in Flutter documentation. Senior reviewers will flag it immediately.

---

### M3: Migrate StudyToolsService to Isar

**Problem:**
JSON deserialization of the notes list (`_readJsonList`) deserializes the entire list every time `getNotesForAyah()` is called. For a user with 500+ notes, this becomes slow. There is no index — filtering by `ayahUq` is O(n).

**Fix:**
Replace the SharedPreferences backing with `isar`:
```dart
// Domain model stays the same
// Only StudyToolsService changes internally

final isar = await Isar.open([
  AyahTagEntrySchema,
  AyahNoteEntrySchema,
  GoalPlanSchema,
], directory: dir.path);

// Get notes for ayah — O(log n) with index
final notes = await isar.ayahNoteEntrys
    .filter()
    .ayahUqEqualTo(ayahUq)
    .sortByCreatedAtDesc()
    .findAll();
```

The service interface stays identical — no changes to Cubits or UI.

**Why it matters:**
Demonstrates you understand database trade-offs and can design for scale, not just for the happy path.

---

### M4: Add Error Boundary Widget

**Problem:**
If a widget throws during `build()`, the entire screen goes red with a Flutter error widget. There is no graceful degradation for individual widget failures.

**Fix:**
```dart
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error)? fallback;
  const ErrorBoundary({required this.child, this.fallback, super.key});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallback?.call(_error!) ?? const SizedBox.shrink();
    }
    return widget.child;
  }
}
```

Wrap major feature sections with this widget.

**Why it matters:**
Shows production-readiness thinking. Error boundaries are a standard pattern in React and increasingly expected in Flutter apps.

---

### M5: Document the Audio URL Security Model

**Problem:**
The HTTPS prefix validation in `AudioCubit.playFromCatalog()` is a meaningful security decision, but it exists only as inline code with no documentation. A code reviewer unfamiliar with the context might remove it thinking it's over-engineering.

**Fix:**
Add a brief comment above the validation:
```dart
// Audio source security: only allow URLs from the approved CDN.
// Prevents playback from attacker-controlled URLs if the catalog is compromised.
const allowedPrefix = 'https://quran.devmmnd.com/quran-audio/';
if (!url.startsWith(allowedPrefix)) {
  throw StateError('Unauthorized audio source. Must begin with $allowedPrefix');
}
```

**Why it matters:**
Security decisions must be documented to survive code reviews and team changes. A "why" comment here signals security awareness, not paranoia.

---

## Priority: LOW — Nice to Have

These are feature enhancements and polish improvements. Do after the high and medium items.

---

### L1: Add GoalProgress Widget to Study Hub

**Problem:**
`StudyToolsService.buildGoalProgress()` computes daily/weekly progress snapshots, but the Study Hub page (`study_hub_page.dart`) does not display them visually. The goal infrastructure is complete but the UI surface is limited.

**Fix:**
Add a `GoalProgressCard` widget with circular progress indicators or progress bars to `StudyHubPage`, driven by `StudyToolsService.buildGoalProgress()`.

---

### L2: Add Full-Text Quran Search

**Problem:**
The current search (in `HomeCubit`) only filters surah names. Users cannot search for specific ayah text. The `quran` package provides utilities that could support text search.

**Fix:**
Extend `HomeCubit` with an ayah-level search mode. Display results as a flat list of `(surah, ayah, text)` items. Tap navigates to `QuranSurahPage` with that ayah highlighted.

---

### L3: Add Multiple Reciter Support

**Problem:**
The app is hardcoded to a single reciter. The JSON catalog supports only one URL per surah.

**Fix:**
Extend `audio_urls.json` to a nested reciter → surah map. Add a reciter picker to `AudioSettingsSheet`. Update `AudioUrlCatalogService.urlForSurah()` to accept a reciter ID.

---

### L4: Add Prayer Times Widget to Home

**Problem:**
Many Quran app users also want prayer times. This is a commonly requested feature in this domain.

**Fix:**
Integrate a `prayer_times` Dart package. Add a `PrayerTimesCard` to the Home screen header using device location (with permission). This is a separate feature and does not touch existing architecture.

---

### L5: Add Onboarding Flow

**Problem:**
The app goes directly from splash to the home screen with no introduction. First-time users have no context for the Study Hub or goal-tracking features.

**Fix:**
Add a simple 3-screen onboarding flow (shown only once, gated by a SharedPreferences flag). Screen 1: app overview. Screen 2: how to use study tools. Screen 3: set your first goal. After completion, navigate to `MainShell` and set `onboarded: true` in preferences.

---

### L6: Add Share Ayah as Image Feature

**Problem:**
The code already imports `share_plus` and captures `_shareOriginRect` in `QuranSurahPage`, suggesting sharing was partially implemented. The feature is not fully surfaced in the UI.

**Fix:**
Complete the "share ayah as image" flow: render the ayah in a `RepaintBoundary`, capture with `toImage()`, save to a temp file, and share via `share_plus`. This is a high-value social feature for Quran apps.

---

### L7: Verify German Translation Completeness

**Problem:**
`app_localizations_de.dart` exists, but it is unclear if all string keys defined in `app_localizations.dart` have German translations. Missing keys cause a runtime fallback to the default locale — or in some configurations, a blank string.

**Fix:**
```bash
# List all keys in the base class
grep "@override" lib/l10n/app_localizations_ar.dart | wc -l
grep "@override" lib/l10n/app_localizations_de.dart | wc -l
```
If the counts differ, add the missing keys to the German file. Add a CI check or ARB validation step.
