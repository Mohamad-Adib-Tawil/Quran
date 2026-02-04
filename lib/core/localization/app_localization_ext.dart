import 'package:flutter/widgets.dart';
import 'package:quran_app/l10n/app_localizations.dart';

extension LocalizationX on BuildContext {
  /// Strongly-typed localizations accessor.
  /// Ensures we never deal with nullable lookups at call sites.
  AppLocalizations get tr => AppLocalizations.of(this);
}
