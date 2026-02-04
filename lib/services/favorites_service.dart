import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favorites_surahs';
  final SharedPreferences _prefs;
  FavoritesService(this._prefs);

  List<int> getFavorites() {
    final list = _prefs.getStringList(_key) ?? const <String>[];
    final ints = list.map((e) => int.tryParse(e)).where((e) => e != null).cast<int>().toList();
    ints.sort();
    return ints;
  }

  Future<void> _save(List<int> values) async {
    final list = values.map((e) => e.toString()).toList();
    await _prefs.setStringList(_key, list);
  }

  Future<List<int>> toggle(int surah) async {
    final favs = getFavorites();
    if (favs.contains(surah)) {
      favs.remove(surah);
    } else {
      favs.add(surah);
      favs.sort();
    }
    await _save(favs);
    return favs;
  }

  bool isFavorite(int surah) => getFavorites().contains(surah);
}
