import 'package:shared_preferences/shared_preferences.dart';
import '../presentation/cubit/audio_state.dart';

class AudioSettingsService {
  static const _keySpeed = 'audio.settings.speed';
  static const _keyRepeat = 'audio.settings.repeat';
  static const _keyAutoDownload = 'audio.settings.autoDownload';

  final SharedPreferences _prefs;
  AudioSettingsService(this._prefs);

  double loadSpeed() => _prefs.getDouble(_keySpeed) ?? 1.0;
  Future<void> saveSpeed(double v) async => _prefs.setDouble(_keySpeed, v);

  RepeatMode loadRepeat() {
    final idx = _prefs.getInt(_keyRepeat) ?? 0;
    return RepeatMode.values[idx.clamp(0, RepeatMode.values.length - 1)];
  }

  Future<void> saveRepeat(RepeatMode mode) async => _prefs.setInt(_keyRepeat, mode.index);

  bool loadAutoDownload() => _prefs.getBool(_keyAutoDownload) ?? true;
  Future<void> saveAutoDownload(bool v) async => _prefs.setBool(_keyAutoDownload, v);
}
