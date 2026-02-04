import 'package:flutter/widgets.dart';
import 'package:quran_app/l10n/app_localizations.dart';

/// LocalizationService centralizes access to generated localizations
/// and hides flutter_gen from the presentation widgets.
class LocalizationService {
  const LocalizationService._();

  static final supportedLocales = AppLocalizations.supportedLocales;
  static final localizationsDelegates = AppLocalizations.localizationsDelegates;

  /// Build a Locale from a persisted language code, or null for system.
  static Locale? localeFromCode(String? code) => code == null ? null : Locale(code);
}
