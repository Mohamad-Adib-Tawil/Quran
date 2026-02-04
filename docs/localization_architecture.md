# Localization Architecture

This document explains how localization is implemented in the Quran Flutter app, how to add a new language, and the dos and don'ts to keep the system production‑ready.

## Goals
- Strong typing for all localized strings.
- Zero direct usage of `AppLocalizations.of(context)` in UI.
- Encapsulate `flutter_gen` inside a single layer.
- No localization in Domain layer. Strings live only in Presentation.
- Minimize rebuilds and avoid calling localization in tight loops.

## Files and Structure

- ARB files: `lib/l10n/`
  - `app_ar.arb`
  - `app_de.arb`
- Generator configuration: `l10n.yaml`
- Localization layer: `lib/core/localization/`
  - `app_localization_ext.dart`
    - Provides `LocalizationX` extension:
      ```dart
      extension LocalizationX on BuildContext {
        AppLocalizations get tr => ...;
      }
      ```
  - `localization_service.dart`
    - Centralizes delegates, supportedLocales, and locale mapping.

## App wiring

Configured in `lib/main.dart`:
- Use `LocalizationService.localizationsDelegates` and `LocalizationService.supportedLocales`.
- Set `locale: LocalizationService.localeFromCode(settings.localeCode)`.
- Set app title via `onGenerateTitle: (ctx) => ctx.tr.appTitle`.

Ensure `pubspec.yaml` has:
```yaml
flutter:
  generate: true
```

And `l10n.yaml`:
```yaml
a rb-dir: lib/l10n
template-arb-file: app_ar.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
synthetic-package: true
nullable-getter: false
preferred-supported-locales:
  - ar
  - de
```

## Usage in UI

- Import the extension once:
```dart
import 'package:quran/core/localization/app_localization_ext.dart';
```
- Cache per‑build access and use across widgets:
```dart
final t = context.tr; // at top of build
Text(t.appTitle)
```
- Do not call `context.tr` inside list builders for every row; get it once per build and pass down via constructor if needed.

## Clean Architecture Rules

- Domain and UseCases: must not depend on localization. No strings from `AppLocalizations`.
- Presentation (Widgets only): access strings via `context.tr`.
- No passing `BuildContext` into Cubits/Services.

## Performance Guidelines

- Cache `final t = context.tr;` once per build.
- Avoid localization calls inside hot loops (e.g., inside `ListView.builder` closures, use the cached `t`).
- Do not allocate new `String`s repeatedly when a stable key exists. Interpolate only when needed.

## Adding a Language

1. Create a new ARB file in `lib/l10n/`, e.g., `app_tr.arb`.
2. Copy all keys from `app_ar.arb` and translate values.
3. Update `l10n.yaml` `preferred-supported-locales` to add the language code.
4. Run:
   ```bash
   flutter pub get
   flutter gen-l10n
   ```
5. Ensure the app compiles. The new locale becomes available automatically via `LocalizationService.supportedLocales`.

## Where to put keys

- UI labels, messages, and tooltips: ARB files.
- Do not put business/domain strings or logs in ARB; domain should be language‑agnostic. Format messages at presentation boundaries.

## Where not to put them

- Not in Cubits/Repositories/UseCases.
- Not in constants in code; prefer ARB keys.
- Not in `enum` names; map enums to display strings in the UI layer.

## Build and Generation

Run these to ensure generated localizations are available:
```bash
flutter pub get
flutter gen-l10n
```

If the IDE shows "Target of URI doesn't exist: package:flutter_gen/gen_l10n/app_localizations.dart", run the commands above from the project root and rebuild.
