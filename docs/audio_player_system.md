# Audio Player System

This document describes the architecture, repeat logic, settings, and data flow for the audio player feature.

## Architecture

- UI (presentation)
  - `features/audio/presentation/pages/full_player_page.dart`
  - `features/audio/presentation/widgets/audio_settings_sheet.dart`
- State Management (Cubit)
  - `features/audio/presentation/cubit/audio_cubit.dart`
  - `features/audio/presentation/cubit/audio_state.dart`
  - `features/audio/settings/audio_settings_cubit.dart`
- Domain
  - `features/audio/domain/repositories/audio_repository.dart`
- Data
  - `features/audio/data/datasources/audio_player_data_source.dart`
  - `features/audio/data/datasources/audio_storage_data_source.dart`
  - `features/audio/data/datasources/audio_remote_data_source.dart`
  - `features/audio/data/repositories/audio_repository_impl_fixed.dart`
- Services
  - `features/audio/settings/audio_settings_service.dart`
  - `services/audio_session_manager.dart`

Clean layering:
- Presentation depends on Cubits only.
- Cubits depend on Repository interfaces (domain) and Services.
- Repositories depend on DataSources.

## Repeat logic

Repeat is modeled by `RepeatMode { one, off, next }` in `AudioState`.
- one: restart the current surah from 0 on completion
- off: stop on completion
- next: play the next surah if available, otherwise stop

The visual state of the Repeat button:
- one: base color with a small "1" badge in the top-right (overlay Stack)
- off: icon tinted using onSurface with reduced opacity
- next: base color, no badge

## Settings

- Playback speed (0.5x..2.0x) via `AudioRepository.setSpeed` -> `AudioPlayerDataSource.setSpeed`.
- Repeat mode.
- Auto-download toggle (if enabled: downloads before play when not present; if disabled: tries to stream via catalog).
- Sleep timer (optional): stops playback after the selected duration.

Persisted using `AudioSettingsService` (SharedPreferences keys):
- `audio.settings.speed`
- `audio.settings.repeat`
- `audio.settings.autoDownload`

`AudioSettingsCubit` loads values on init and applies them to `AudioCubit`.

## Data flow

1. UI triggers an intent (`playSurah`, `toggle`, `seek`, settings changes).
2. `AudioCubit` calls into `AudioRepository` (`setUrl`, `prepareSurah`, `play`, `pause`, `stop`, `seek`, `setSpeed`).
3. `AudioRepositoryImpl` uses `AudioPlayerDataSource` + storage.
4. Position/duration/playerState streams update `AudioCubit` which emits new `AudioState` for the UI.
5. On completion, `AudioCubit._onCompleted()` switches behavior based on `RepeatMode`.

## Edge cases

- End of Surah: handled in `_onCompleted()`.
- Network failure: download flow emits `AudioPhase.error` and an error banner is displayed with Retry.
- Surah not downloaded: if `autoDownload=true`, download flow starts; otherwise streams from catalog.
- Change surah while playing: `playSurah` updates state and prepares new source.
- App close: `AudioSessionManager` persists last surah, playing state, and last position; `AudioSettingsService` persists player settings.

## Packages

- `just_audio` for playback.
- `audio_session` for session configuration.
- Optional future additions (not required for current scope):
  - `just_audio_background` for notification controls.
  - `audio_service` for background playback service.
  - `modal_bottom_sheet` for advanced bottom sheets.

## UI notes

The Full Player header is responsive via `LayoutBuilder` and a rounded card with an overlay. Slider theming and a circular main play button match the design, while keeping accessibility and responsiveness in mind.
