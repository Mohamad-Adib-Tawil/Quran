import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeatureFlagsService {
  static const _prefsKey = 'app.feature_flags';

  final SharedPreferences _prefs;
  Map<String, bool> _flags;

  FeatureFlagsService(this._prefs, {Map<String, bool>? defaults}) : _flags = {
          // defaults
          'mini_player': true,
          'audio_downloads': true,
          'in_app_review': true,
          'update_checker': true,
          'analytics': false,
          'crash_reporting': false,
          ...?defaults,
        } {
    _load();
  }

  void _load() {
    final raw = _prefs.getString(_prefsKey);
    if (raw == null) return;
    try {
      final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      _flags.addAll(map.map((k, v) => MapEntry(k, v == true)));
    } catch (e) {
      if (kDebugMode) {
        // ignore parsing errors in debug
      }
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(_prefsKey, jsonEncode(_flags));
  }

  bool isEnabled(String key) => _flags[key] ?? false;

  Map<String, bool> get all => Map.unmodifiable(_flags);

  Future<void> setFlag(String key, bool enabled) async {
    _flags[key] = enabled;
    await _persist();
  }

  Future<void> setAll(Map<String, bool> values) async {
    _flags.addAll(values);
    await _persist();
  }
}
