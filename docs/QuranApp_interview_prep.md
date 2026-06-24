# QuranApp — Interview Preparation Guide

---

## Architecture Questions

---

**Q: Walk me through the architecture of your Quran app. Why Clean Architecture?**

**A:**
The app uses Clean Architecture with a feature-first folder structure. Each feature — audio, quran, home, settings, favourites, study — is a self-contained vertical slice with three layers:

- **Domain layer:** Abstract repository interfaces and plain Dart entity classes. Zero Flutter imports. This is the contract layer.
- **Data layer:** Concrete repository implementations and data sources that talk to just_audio, SharedPreferences, the file system, and the HTTP CDN. They implement the domain interfaces.
- **Presentation layer:** Cubits, state classes, pages, and widgets. Cubits call domain repository methods — they never know about the data layer directly.

I chose Clean Architecture because this app's storage strategy could realistically evolve. The study tools currently use SharedPreferences, but if we ever add SQLite, Isar, or cloud sync, only the data layer changes. The Cubits and UI don't care. More practically, it forces a discipline that makes the codebase navigable — when a bug is in the audio download flow, I know exactly which file layer to go to.

---

**Q: What is the dependency rule in Clean Architecture, and did you actually enforce it here?**

**A:**
The dependency rule states that inner layers must not depend on outer layers. Domain must not import from data or presentation; data must not import from presentation.

In this project: the `AudioRepository` abstract class in `domain/repositories/` has no imports from `data/` or `presentation/`. The `AudioRepositoryImpl` in `data/repositories/` imports from `domain/` (to implement the interface) but never from `presentation/`. The `AudioCubit` in `presentation/cubit/` imports the `AudioRepository` abstract type from `domain/` — not the concrete implementation.

The concrete type is only known to the `service_locator.dart` in `core/di/`, which acts as the composition root. That's the only place where `AudioRepositoryImpl` and `AudioCubit` are wired together. This is the correct application of the rule.

---

**Q: Why feature-first instead of layer-first folder structure?**

**A:**
Layer-first means `lib/data/`, `lib/domain/`, `lib/presentation/` at the top level with all features mixed inside each. Feature-first means `lib/features/audio/`, `lib/features/quran/` — each with their own data/domain/presentation sub-layers.

For a single-developer project or a team where features are owned by individuals, feature-first is dramatically better. When I'm working on the audio feature, everything relevant is in `lib/features/audio/`. I don't have to jump between three top-level folders. When the audio feature grows or changes, the blast radius is contained. Feature-first also makes it easier to eventually extract a feature into a separate package if the app modularizes.

---

## State Management Questions

---

**Q: Why did you choose Cubit over full BLoC with Events?**

**A:**
BLoC's event-driven model adds value when you need to transform, debounce, or switch-map events — for example, a search field where you want `debounceTime(300ms)` before calling an API. In this app, none of the Cubits need that. Every user action has a direct 1:1 response: tap play → `AudioCubit.play()`, toggle favourite → `FavoritesService.toggle()`. Adding an event class and a handler for each of these would be pure boilerplate with no benefit. Cubit gives the same Bloc stream guarantees — the same `BlocBuilder`, `BlocListener`, `context.read` — with simpler call sites.

---

**Q: How does the AudioCubit state machine work? Walk me through the AudioPhase transitions.**

**A:**
`AudioPhase` is an enum with 8 values: `idle`, `preparing`, `playing`, `paused`, `buffering` (conceptually), `downloading`, `awaitingConfirmation`, and `error`.

The flow for playing a surah the user has not downloaded:

1. User taps a surah → `playSurah(surah)` is called
2. Cubit checks `_downloadRepo.isDownloaded(surah)` — returns false
3. Emits `phase: awaitingConfirmation` with the pending surah number
4. The UI detects this phase and shows a confirmation dialog via `MiniAudioPlayer`
5. User confirms → `confirmAndPlaySurah(surah)` is called
6. Emits `phase: preparing`, stops any previous engine source
7. Checks `autoDownload` preference:
   - If `true` → calls `_startDownloadFlow()`, emits `phase: downloading` with progress
   - If `false` → calls `playFromCatalog()` (streams directly from HTTPS URL)
8. On completion of download (or immediately for streaming) → calls `prepareSurah()` which sets the source in just_audio, then `play()`
9. The `playerStateStream` listener drives the final `phase: playing` / `phase: paused` / `phase: idle` transitions

The key design decision: `playerStateStream` is the single source of truth for `isPlaying` and `phase`. I never optimistically set `isPlaying: true` when calling `play()` — I wait for the stream to confirm. This prevents the UI from showing "playing" while the engine is still buffering.

---

**Q: How do you prevent unnecessary widget rebuilds in the audio player?**

**A:**
The `AudioState` is a large state object — it includes position (updated many times per second), duration, phase, surah, URL, playback speed, repeat mode, sleep timer, download progress, and error message. If a `BlocBuilder` rebuilds every time position changes, the entire player UI redraws hundreds of times per minute.

I used `buildWhen` in `FullPlayerPage`:
```dart
BlocBuilder<AudioCubit, AudioState>(
  buildWhen: (prev, curr) =>
    prev.currentSurah != curr.currentSurah ||
    prev.isPlaying != curr.isPlaying ||
    prev.phase != curr.phase ||
    prev.isBuffering != curr.isBuffering ||
    prev.repeatMode != curr.repeatMode ||
    prev.speed != curr.speed,
  builder: (context, state) { ... }
)
```

Position and duration fields are explicitly excluded. Widgets that need them (the seek bar, the time display) subscribe independently with their own `BlocSelector` or inner `BlocBuilder` that only watches those fields. This means a position tick rebuilds only the seek bar, not the whole page.

---

## Audio Engine Questions

---

**Q: How does just_audio differ from audioplayers? Why did you choose it?**

**A:**
`audioplayers` is simpler but more limited — it wraps native platform players without fine-grained stream access. `just_audio` provides fully typed Dart streams (`positionStream`, `durationStream`, `playerStateStream` with `ProcessingState`), which is what makes the reactive Cubit state machine possible. I can subscribe to `playerStateStream` and get reliable `ProcessingState.completed` events to trigger repeat-next logic. `just_audio` also integrates natively with `audio_session` for OS audio focus, handles network URLs and local files with the same API, and is actively maintained by the Flutter community with strong multi-platform coverage.

---

**Q: How do you handle the case where the user receives a phone call while audio is playing?**

**A:**
`audio_session` handles this. In `main()`:
```dart
final session = await AudioSession.instance;
await session.configure(const AudioSessionConfiguration.music());
```

This tells the OS that this app is playing music-category audio. When an interruption occurs (phone call, another music app, Siri), the OS sends an interruption event to `audio_session`. By default with `.music()` configuration, `just_audio` respects these interruptions — it pauses on interruption begin and can optionally resume on interruption end. The `playerStateStream` reflects these changes, so `AudioCubit` naturally transitions to `AudioPhase.paused` without any extra code.

---

**Q: Explain the download flow. What happens if the download fails halfway?**

**A:**
`_startDownloadFlow(surah)` subscribes to `_downloadRepo.progressStream(surah)`. This stream emits `DownloadProgressEvent` objects with a `progress` (0.0–1.0) and a `DownloadStatus`. The Cubit:

1. Emits `phase: downloading, downloadProgress: 0.0` immediately
2. On each progress event, emits updated `downloadProgress`
3. On `DownloadStatus.completed` → cancels the subscription, calls `prepareSurah()` and `play()`
4. On `DownloadStatus.failed` or `DownloadStatus.canceled` → cancels the subscription, emits `phase: error` with a user-facing message

If the user taps "Retry" from the error state, `retry()` replays `confirmAndPlaySurah()` for the last requested surah, which restarts the download flow from scratch. There is no partial-download resume in the current implementation — the whole surah is re-downloaded. That is a known limitation.

---

## Local Storage Questions

---

**Q: Why SharedPreferences instead of SQLite or Isar for the study tools?**

**A:**
The study tools data — tags, notes, and goal stats — is relatively small in absolute terms (hundreds of entries at most for most users), has simple access patterns (read all tags on page load, write one on ayah tap), and does not need complex querying. SharedPreferences with JSON serialization handles this perfectly and adds zero native dependencies or schema migration concerns.

The trade-off is clear: if the note count grows into the thousands, JSON deserialization of the entire list for every read becomes slow. If we needed to query "all notes for surahs 1–10" efficiently, we'd need SQLite. I acknowledged this in the design — it's a conscious starting point with a clear migration path to `sqflite` or `isar`, not a permanent constraint.

---

**Q: How do you count unique pages read today without a database?**

**A:**
`StudyToolsService` uses an integer set stored as a JSON array inside a date-bucketed structure. When a page is read:

```dart
await _trackIntSet(
  key: _kDailyStats,
  bucketId: _dayId(DateTime.now()),  // e.g. "2024-01-15"
  field: 'pages',
  value: pageNumber,
);
```

`_trackIntSet` reads the current JSON map, finds the day bucket, reads the `pages` field as a `List<int>`, converts it to a `Set<int>` (deduplication), adds the new page number, converts back to a list, and writes it back. When building goal progress, counting is `set.length`. This guarantees uniqueness without a database and works well for the expected data volumes.

---

## Performance Questions

---

**Q: Why did you freeze the font scale at 1.0?**

**A:**
The UI was designed and tested at system font scale 1.0 with specific Figma-derived text sizes. When users set a large text size in OS accessibility settings, Flutter scales all text by `textScaler`, which can cause overflow in fixed-height containers (like list tiles, the mini player, badges). Rather than engineering every widget to handle arbitrary font scales — which would require testing at 6+ scale values — I froze the scale for this version:

```dart
return MediaQuery(
  data: mq.copyWith(textScaler: TextScaler.linear(1.0)),
  child: child!,
);
```

This is a documented temporary decision (`// Freeze font scale feature temporarily`). The correct long-term fix is to audit every layout for overflow safety and remove the freeze. It is a trade-off between development speed and accessibility compliance.

---

## Error Handling Questions

---

**Q: How do you handle uncaught exceptions in Flutter?**

**A:**
At app startup, `main()` wraps `runApp` in `runZonedGuarded`:

```dart
await runZonedGuarded(() async {
  // ... init
  FlutterError.onError = (FlutterErrorDetails details) async {
    FlutterError.presentError(details);      // shows error in debug mode
    await crash.recordFlutterError(details); // logs via CrashReporter
  };
  runApp(const QuranApp());
}, (Object error, StackTrace stack) async {
  // catches async errors that escape the zone
  await crash.recordError(error, stack);
});
```

`FlutterError.onError` catches widget-layer build errors (layout overflow, null dereference in build methods). `runZonedGuarded`'s second argument catches Dart async errors that escape the zone, including unhandled Future rejections. Both routes forward to `CrashReporter`, which uses `AppLogger` for structured output. In the current implementation, `CrashReporter` logs locally — it does not yet send to a remote crash service like Firebase Crashlytics or Sentry.

---

## Scenario-Based Questions

---

**Q: How would you add a second reciter to this app?**

**A:**
The audio URL catalog is loaded from `assets/audio/audio_urls.json` by `AudioUrlCatalogService`. Currently it has one entry per surah. To add a second reciter:

1. Extend `audio_urls.json` to a map of reciter → surah → URL: `{ "mishary": { "1": "https://...", ... }, "sudais": { ... } }`
2. Update `AudioUrlCatalogService.urlForSurah()` to accept a reciter parameter
3. Add a `selectedReciter` field to `AudioSettingsState` and `AudioSettingsCubit`
4. Update `AudioCubit.playFromCatalog()` to pass the reciter from settings
5. Add reciter selection UI to `AudioSettingsSheet`

The download repository would need a reciter-aware file naming scheme. The domain `AudioDownloadRepository` interface would need a `reciter` parameter on `downloadSurah()` and `isDownloaded()`. Because of Clean Architecture, the Cubit and UI changes are minimal — most changes are in the data and service layers.

---

**Q: What would you change if you had to rebuild this project from scratch?**

**A:**
Three things:

1. **Replace SharedPreferences with Isar for StudyToolsService.** The JSON-in-SharedPreferences approach works but is fragile for complex data. Isar gives typed objects, indexes, and queries while staying fully local and fast.

2. **Write tests from the start.** The absence of tests is the biggest gap. I would start with unit tests for `AudioCubit` (mocking `AudioRepository` and `AudioDownloadRepository`), `StudyToolsService`, and `FavoritesService`. Then widget tests for `MiniAudioPlayer` state transitions. Getting to even 60% coverage on the business logic would make refactoring much safer.

3. **Use GoRouter instead of imperative Navigator.push.** The current navigation is entirely `Navigator.of(context).push(MaterialPageRoute(...))`. This makes deep linking (e.g., "open surah 36 from a notification") impossible without significant refactoring. GoRouter's declarative routes with path parameters would solve this.

---

**Q: How would you add cloud sync for bookmarks and notes?**

**A:**
Since there is no authentication today, I would first add auth (Firebase Auth with Google Sign-In would be the fastest path). Then:

1. Create a `CloudStudyRepository` that mirrors `StudyToolsService`'s interface but writes to Firestore
2. Implement a sync strategy: local-first writes to SharedPreferences immediately (for offline support), then background-sync to Firestore on connectivity
3. Use a `lastModifiedAt` timestamp on each note and tag entry (the model already has `createdAt`) for conflict resolution — "last write wins" is acceptable for personal study data
4. Because the storage interface is already abstracted behind `StudyToolsService`, most of the Cubit and UI code needs no changes

---

**Q: How would you add unit tests to AudioCubit?**

**A:**
```dart
// test/features/audio/audio_cubit_test.dart
void main() {
  late MockAudioRepository mockAudioRepo;
  late MockAudioDownloadRepository mockDownloadRepo;
  late MockAudioUrlCatalogService mockCatalog;
  late AudioCubit cubit;

  setUp(() {
    mockAudioRepo = MockAudioRepository();
    mockDownloadRepo = MockAudioDownloadRepository();
    mockCatalog = MockAudioUrlCatalogService();
    cubit = AudioCubit(mockAudioRepo, mockDownloadRepo, mockCatalog);
  });

  tearDown(() => cubit.close());

  test('playSurah emits awaitingConfirmation when surah not downloaded', () async {
    when(mockDownloadRepo.isDownloaded(36)).thenAnswer((_) async => false);

    await cubit.playSurah(36);

    expect(cubit.state.phase, AudioPhase.awaitingConfirmation);
    expect(cubit.state.pendingSurah, 36);
  });

  test('playSurah plays immediately when surah is downloaded', () async {
    when(mockDownloadRepo.isDownloaded(1)).thenAnswer((_) async => true);
    when(mockAudioRepo.prepareSurah(surah: 1, initialPosition: null, cache: true))
        .thenAnswer((_) async => 'file://path/to/001.mp3');
    when(mockAudioRepo.play()).thenAnswer((_) async {});

    await cubit.playSurah(1);

    verify(mockAudioRepo.play()).called(1);
  });
}
```

Use `mocktail` or `mockito` with code generation for the mock classes. Wrap state-emitting tests in `blocTest` from `bloc_test` package for declarative `act`/`expect` patterns.

---

## Questions to Ask the Interviewer

These questions signal senior-level thinking and genuine interest in the role:

1. "How does your team currently structure Flutter feature development — feature-first, layer-first, or package-per-feature?"

2. "What is the expected scale of the app? How many active users, and does that affect your state management or caching strategy?"

3. "Is offline-first a hard requirement, or do you rely on connectivity? How do you handle sync conflicts?"

4. "How mature is your test coverage? What's the current ratio of unit/widget/integration tests, and where are the gaps?"

5. "Do you use CI/CD for Flutter? What does the pipeline look like — lint, test, build, deployment to stores?"

6. "How do you manage design-to-code handoff? Is Figma used, and does the team have a shared design token system?"

7. "What are the biggest technical challenges the Flutter team is dealing with right now?"

8. "How do code reviews work — PR-based, mob sessions, or pair programming?"
