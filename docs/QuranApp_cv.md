# QuranApp — CV Description (ATS Optimized)

---

**Project Name:** Quran App — القرآن الكريم  
**Role:** Flutter Developer (Solo)  
**Platform:** Android & iOS  
**Technologies:** Flutter, Dart, flutter_bloc (Cubit), GetIt, just_audio, audio_session, background_downloader, SharedPreferences, quran_library, flutter_screenutil, flutter_localizations, Clean Architecture

---

## CV Bullet Points

- Architected a cross-platform Quran mobile application using **Clean Architecture** with a feature-first folder structure (data / domain / presentation layers per feature), **flutter_bloc Cubit** for predictable unidirectional state management, and **GetIt** as a service locator for compile-safe dependency injection across 6+ registered services and repositories.

- Built a multi-phase audio engine using **just_audio** and **audio_session**, implementing an explicit `AudioPhase` state machine (idle → preparing → buffering → playing → paused → downloading → awaitingConfirmation → error) with OS-level audio focus management, repeat modes (off / single / auto-next), configurable playback speed, and a sleep timer — all driven by reactive stream subscriptions with proper cancellation on dispose.

- Implemented offline audio support using **background_downloader** for per-surah background downloads with real-time progress via `Stream<DownloadProgressEvent>`, local file storage validation, and a smart play-flow that automatically selects between local playback, auto-download, and direct HTTPS streaming based on download status and user preferences.

- Designed a local **Study Tools system** backed by **SharedPreferences** with JSON serialization: per-ayah colour-coded tagging (review / hifz / tadabbur), timestamped notes with surah grouping, and a daily/weekly goal tracker (pages read, ayahs read, listening minutes) using bucket-keyed stat snapshots — without any external database dependency.

- Delivered a fully **multi-language UI** (Arabic / German) using Flutter's ARB localization pipeline with a custom `BuildContext` extension (`context.tr`) for ergonomic, type-safe string access across the widget tree; supported dynamic locale switching persisted to SharedPreferences.

- Applied **UI performance optimizations** including `BlocBuilder` `buildWhen` guards on the full audio player to suppress unnecessary rebuilds on position tick updates, `flutter_screenutil` responsive scaling at a `390×844` Figma baseline, frozen font scale via `MediaQuery` override, and Figma-derived design token constants (palette, typography, spacing) for consistency across light and dark themes.
