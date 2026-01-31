import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// نموذج عنصر خريطة الصوت: رقم السورة -> رابط الصوت
class AudioUrlEntry {
  final int surah;
  final String url;
  const AudioUrlEntry(this.surah, this.url);

  factory AudioUrlEntry.fromJson(Map<String, dynamic> json) {
    return AudioUrlEntry(json['surah'] as int, json['url'] as String);
  }
}

/// خدمة لقراءة ملف JSON المحلي وربط كل سورة برابط الصوت الخاص بها.
/// لا تعتمد على أي مصدر خارجي، وتُستخدم ككتالوج ثابت.
class AudioUrlCatalogService {
  Map<int, String> _map = const {};

  Future<void> load({String assetPath = 'assets/audio/audio_urls.json'}) async {
    final jsonStr = await rootBundle.loadString(assetPath);
    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    final map = <int, String>{};
    for (final e in list) {
      if (e is Map<String, dynamic>) {
        final entry = AudioUrlEntry.fromJson(e);
        map[entry.surah] = entry.url;
      }
    }
    _map = map;
  }

  String? urlForSurah(int surah) => _map[surah];

  bool contains(int surah) => _map.containsKey(surah);
}
