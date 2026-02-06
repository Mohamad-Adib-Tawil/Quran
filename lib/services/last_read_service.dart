import 'package:shared_preferences/shared_preferences.dart';

class LastRead {
  final int surah; // 1..114
  final int ayah; // >=1
  const LastRead({required this.surah, required this.ayah});
}

class LastReadService {
  static const _kSurah = 'last_read_surah';
  static const _kAyah = 'last_read_ayah';

  final SharedPreferences _prefs;
  LastReadService(this._prefs);

  Future<void> setLastRead({required int surah, required int ayah}) async {
    await _prefs.setInt(_kSurah, surah);
    await _prefs.setInt(_kAyah, ayah);
  }

  LastRead getLastRead() {
    final s = _prefs.getInt(_kSurah);
    final a = _prefs.getInt(_kAyah);
    // ✅ Default to Al-Fatiha (Surah 1, Ayah 1) if no last read exists
    if (s == null || a == null) {
      return const LastRead(surah: 1, ayah: 1);
    }
    return LastRead(surah: s, ayah: a);
  }

  Future<void> clear() async {
    await _prefs.remove(_kSurah);
    await _prefs.remove(_kAyah);
  }
}
