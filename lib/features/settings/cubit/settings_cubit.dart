import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  static const _keyTheme = 'themeMode';
  static const _keyFontScale = 'fontScale';
  static const _keyVerseEnd = 'verseEndSymbol';
  static const _keyLocale = 'localeCode';

  final SharedPreferences _prefs;
  SettingsCubit(this._prefs) : super(SettingsState.initial()) {
    _hydrate();
  }

  void _hydrate() {
    final themeStr = _prefs.getString(_keyTheme);
    final fontScale = _prefs.getDouble(_keyFontScale) ?? state.fontScale;
    final verseEnd = _prefs.getBool(_keyVerseEnd) ?? state.verseEndSymbol;
    final locale = _prefs.getString(_keyLocale);

    emit(state.copyWith(
      themeMode: _parseTheme(themeStr) ?? state.themeMode,
      fontScale: fontScale,
      verseEndSymbol: verseEnd,
      localeCode: locale,
    ));
  }

  ThemeMode? _parseTheme(String? v) {
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  String _themeToString(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  void setTheme(ThemeMode mode) {
    _prefs.setString(_keyTheme, _themeToString(mode));
    emit(state.copyWith(themeMode: mode));
  }

  void setFontScale(double scale) {
    _prefs.setDouble(_keyFontScale, scale);
    emit(state.copyWith(fontScale: scale));
  }

  void toggleVerseEndSymbol(bool value) {
    _prefs.setBool(_keyVerseEnd, value);
    emit(state.copyWith(verseEndSymbol: value));
  }

  void setLocale(String code) {
    _prefs.setString(_keyLocale, code);
    emit(state.copyWith(localeCode: code));
  }
}
