import 'package:shared_preferences/shared_preferences.dart';

class LastRead {
  final int surah; // 1..114
  final int ayah; // >=1
  final int? page; // 1..604
  const LastRead({required this.surah, required this.ayah, this.page});
}

class LastReadService {
  static const _kSurah = 'last_read_surah';
  static const _kAyah = 'last_read_ayah';
  static const _kPage = 'last_read_page';

  final SharedPreferences _prefs;
  LastReadService(this._prefs);

  Future<void> setLastRead({required int surah, required int ayah, int? page}) async {
    await _prefs.setInt(_kSurah, surah);
    await _prefs.setInt(_kAyah, ayah);
    if (page != null && page >= 1) {
      await _prefs.setInt(_kPage, page);
    } else {
      await _prefs.remove(_kPage);
    }
  }

  LastRead getLastRead() {
    final s = _prefs.getInt(_kSurah);
    final a = _prefs.getInt(_kAyah);
    final p = _prefs.getInt(_kPage);
    // ✅ Default to Al-Fatiha (Surah 1, Ayah 1) if no last read exists
    if (s == null || a == null) {
      return const LastRead(surah: 1, ayah: 1, page: 1);
    }
    return LastRead(surah: s, ayah: a, page: p);
  }

  Future<void> clear() async {
    await _prefs.remove(_kSurah);
    await _prefs.remove(_kAyah);
    await _prefs.remove(_kPage);
  }
}
