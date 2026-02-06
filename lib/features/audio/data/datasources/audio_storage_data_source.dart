import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AudioStorageDataSource {
  static const String subDir = 'audio';
  
  // Cache size limit: 500MB (adjust as needed)
  static const int maxCacheSizeBytes = 500 * 1024 * 1024;

  Future<Directory> _audioDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$subDir');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _pad(int surah) => surah.toString().padLeft(3, '0');

  Future<String> filePathForSurah(int surah) async {
    final dir = await _audioDir();
    return '${dir.path}/${_pad(surah)}.mp3';
    }

  Future<bool> exists(int surah) async {
    final path = await filePathForSurah(surah);
    return File(path).exists();
  }

  Future<void> delete(int surah) async {
    final path = await filePathForSurah(surah);
    final f = File(path);
    if (await f.exists()) {
      await f.delete();
    }
  }

  Future<List<int>> listDownloaded() async {
    final dir = await _audioDir();
    if (!await dir.exists()) return [];
    final entries = await dir.list().toList();
    final result = <int>[];
    for (final e in entries) {
      if (e is File && e.path.endsWith('.mp3')) {
        final name = e.uri.pathSegments.last;
        final numStr = name.replaceAll('.mp3', '');
        final n = int.tryParse(numStr);
        if (n != null) result.add(n);
      }
    }
    result.sort();
    return result;
  }

  /// Get total cache size in bytes
  Future<int> getCacheSize() async {
    final dir = await _audioDir();
    if (!await dir.exists()) return 0;
    int totalSize = 0;
    final entries = await dir.list().toList();
    for (final e in entries) {
      if (e is File) {
        try {
          final stat = await e.stat();
          totalSize += stat.size;
        } catch (_) {
          // ignore files we can't stat
        }
      }
    }
    return totalSize;
  }

  /// Clean old cache if exceeds limit (LRU: delete oldest accessed files)
  Future<void> cleanupIfNeeded() async {
    final size = await getCacheSize();
    if (size <= maxCacheSizeBytes) return;

    final dir = await _audioDir();
    if (!await dir.exists()) return;

    // Get all files with their last accessed time
    final files = <File>[];
    final entries = await dir.list().toList();
    for (final e in entries) {
      if (e is File && e.path.endsWith('.mp3')) {
        files.add(e);
      }
    }

    // Sort by last accessed time (oldest first)
    files.sort((a, b) {
      try {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return aStat.accessed.compareTo(bStat.accessed);
      } catch (_) {
        return 0;
      }
    });

    // Delete oldest files until under limit
    int currentSize = size;
    for (final file in files) {
      if (currentSize <= maxCacheSizeBytes) break;
      try {
        final stat = await file.stat();
        await file.delete();
        currentSize -= stat.size;
      } catch (_) {
        // ignore deletion errors
      }
    }
  }

  /// Clear all cached audio files
  Future<void> clearAllCache() async {
    final dir = await _audioDir();
    if (!await dir.exists()) return;
    try {
      await dir.delete(recursive: true);
    } catch (_) {
      // ignore errors
    }
  }
}
