import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

/// Remote APIs provider for audio URLs.
/// Note: actual endpoint and parameters will be provided later.
/// Keep this class flexible to change reciter/server without touching UI.
class AudioRemoteDataSource {
  String? baseUrl; // optional fallback base URL like https://.../quran-audio/
  Map<int, String>? _surahUrls; // loaded from assets
  List<String> fallbackBaseUrls = const [];

  AudioRemoteDataSource();

  void configure({String? baseUrl, List<String>? fallbackBaseUrls, String? reciterId}) {
    this.baseUrl = baseUrl ?? this.baseUrl;
    if (fallbackBaseUrls != null) {
      this.fallbackBaseUrls = List<String>.from(fallbackBaseUrls);
    }
  }

  /// Load per-surah URLs from an asset JSON file and cache them.
  /// Expected JSON shape: [{"surah": 1, "url": "https://.../001.mp3"}, ...]
  Future<void> loadFromAssets({String assetPath = 'assets/audio/audio_urls.json'}) async {
    final jsonStr = await rootBundle.loadString(assetPath);
    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    final Map<int, String> map = {};
    for (final e in list) {
      if (e is Map<String, dynamic>) {
        final s = e['surah'];
        final u = e['url'];
        if (s is int && u is String) {
          map[s] = u;
        }
      }
    }
    _surahUrls = map;
  }

  /// Returns a candidate audio URL (no preflight).
  /// Preference: baseUrl -> assets mapping -> first fallback.
  /// ✅ Added validation and error handling
  Future<String> getSurahUrl({required int surah}) async {
    // ✅ Validate surah number
    if (surah < 1 || surah > 114) {
      throw ArgumentError('رقم السورة غير صحيح: $surah. يجب أن يكون بين 1 و 114');
    }

    final padded = surah.toString().padLeft(3, '0');
    
    try {
      // Prefer baseUrl if configured (allows overriding broken asset links)
      if (baseUrl != null) {
        final url = '${baseUrl!}$padded.mp3';
        // ✅ Validate HTTPS
        if (!url.startsWith('https://')) {
          throw StateError('رابط الصوت يجب أن يكون HTTPS: $url');
        }
        return url;
      }
      
      // Then assets mapping
      final cached = _surahUrls;
      if (cached != null && cached.containsKey(surah)) {
        final url = cached[surah]!;
        // ✅ Validate HTTPS
        if (!url.startsWith('https://')) {
          throw StateError('رابط الصوت من الأصول يجب أن يكون HTTPS: $url');
        }
        return url;
      }
      
      // Use first configured fallback host if any
      if (fallbackBaseUrls.isNotEmpty) {
        final fb = fallbackBaseUrls.first;
        final url = fb.endsWith('/') ? '$fb$padded.mp3' : '$fb/$padded.mp3';
        // ✅ Validate HTTPS
        if (!url.startsWith('https://')) {
          throw StateError('رابط الاحتياطي يجب أن يكون HTTPS: $url');
        }
        return url;
      }
      
      throw StateError('رابط الصوت للسورة $surah غير متوفر. قم بتحميل الأصول أو تعيين baseUrl.');
    } catch (e) {
      // ✅ Wrap exceptions with context
      throw Exception('فشل الحصول على رابط السورة $surah: $e');
    }
  }

  /// Legacy API compatibility: returns surah-level URL ignoring ayah parameter.
  Future<String> getAyahUrl({required int surah, required int ayah}) async => getSurahUrl(surah: surah);
}
