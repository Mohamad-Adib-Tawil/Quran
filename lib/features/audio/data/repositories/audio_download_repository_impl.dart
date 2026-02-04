import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;

import '../../domain/repositories/audio_download_repository.dart';
import '../datasources/audio_remote_data_source.dart';
import '../datasources/audio_storage_data_source.dart';
import '../datasources/audio_cache_data_source.dart';

class AudioDownloadRepositoryImpl implements AudioDownloadRepository {
  final AudioRemoteDataSource remote;
  final AudioStorageDataSource storage;
  final AudioCacheDataSource cache;

  AudioDownloadRepositoryImpl({required this.remote, required this.storage, required this.cache});

  final Map<int, StreamController<DownloadProgress>> _controllers = {};

  StreamController<DownloadProgress> _controllerFor(int surah) {
    return _controllers.putIfAbsent(
      surah,
      () => StreamController<DownloadProgress>.broadcast(),
    );
  }

  String _taskIdFor(int surah) => 'surah_${surah.toString().padLeft(3, '0')}';

  @override
  Future<void> downloadSurah(int surah) async {
    if (await storage.exists(surah)) return; // already downloaded

    final primaryUrl = await remote.getSurahUrl(surah: surah);
    final ctrl = _controllerFor(surah);
    ctrl.add(DownloadProgress(surah, 0, DownloadStatus.downloading));

    // First attempt: use original URL (likely https)
    bool success = await _downloadOnce(
      surah: surah,
      url: primaryUrl,
      taskId: _taskIdFor(surah),
    );

    // Fallback: if failed/canceled and URL was https, try http in non-release builds only
    if (!success && primaryUrl.startsWith('https://') && !kReleaseMode) {
      final httpUrl = primaryUrl.replaceFirst('https://', 'http://');
      await _downloadOnce(
        surah: surah,
        url: httpUrl,
        taskId: '${_taskIdFor(surah)}_http',
      );
      // re-check if download completed from http fallback
      if (await storage.exists(surah)) return;
    }

    // Fallback to alternate hosts (if configured): try https/http and padded/non-padded
    if (!await storage.exists(surah) && remote.fallbackBaseUrls.isNotEmpty) {
      final padded = surah.toString().padLeft(3, '0');
      final plain = surah.toString();
      for (int i = 0; i < remote.fallbackBaseUrls.length; i++) {
        final fb = remote.fallbackBaseUrls[i];
        final withSlash = fb.endsWith('/') ? fb : '$fb/';
        // build candidates preferring HTTPS; only use HTTP in non-release builds
        final List<String> candidates = [];
        if (withSlash.startsWith('https://') || withSlash.startsWith('http://')) {
          if (withSlash.startsWith('https://')) {
            final httpBase = withSlash.replaceFirst('https://', 'http://');
            candidates.add('$withSlash$padded.mp3');
            candidates.add('$withSlash$plain.mp3');
            if (!kReleaseMode) {
              candidates.add('$httpBase$padded.mp3');
              candidates.add('$httpBase$plain.mp3');
            }
          } else if (withSlash.startsWith('http://')) {
            if (!kReleaseMode) {
              candidates.add('$withSlash$padded.mp3');
              candidates.add('$withSlash$plain.mp3');
            }
            final httpsBase = withSlash.replaceFirst('http://', 'https://');
            candidates.add('$httpsBase$padded.mp3');
            candidates.add('$httpsBase$plain.mp3');
          }
        } else {
          candidates.add('https://$withSlash$padded.mp3');
          candidates.add('https://$withSlash$plain.mp3');
          if (!kReleaseMode) {
            candidates.add('http://$withSlash$padded.mp3');
            candidates.add('http://$withSlash$plain.mp3');
          }
        }

        for (int j = 0; j < candidates.length; j++) {
          await _downloadOnce(
            surah: surah,
            url: candidates[j],
            taskId: '${_taskIdFor(surah)}_fb${i}_$j',
          );
          if (await storage.exists(surah)) return;
        }
      }
    }

    // Final fallback: download via CacheManager (Dart HttpClient), then copy to storage, trying multiple candidates
    if (!await storage.exists(surah)) {
      try {
        final padded = surah.toString().padLeft(3, '0');
        final plain = surah.toString();
        final List<String> candidates = [];
        // primary from remote (baseUrl or assets mapping)
        try { candidates.add(await remote.getSurahUrl(surah: surah)); } catch (_) {}
        // baseUrl variants
        final b = remote.baseUrl;
        if (b != null) {
          final bs = b.endsWith('/') ? b : '$b/';
          candidates.add('$bs$padded.mp3');
          candidates.add('$bs$plain.mp3');
          if (bs.startsWith('https://') && !kReleaseMode) {
            final hb = bs.replaceFirst('https://', 'http://');
            candidates.add('$hb$padded.mp3');
            candidates.add('$hb$plain.mp3');
          }
        }
        // fallbacks
        for (final fb in remote.fallbackBaseUrls) {
          final withSlash = fb.endsWith('/') ? fb : '$fb/';
          if (withSlash.startsWith('http')) {
            if (withSlash.startsWith('https://')) {
              candidates.add('$withSlash$padded.mp3');
              candidates.add('$withSlash$plain.mp3');
              if (!kReleaseMode) {
                final hb = withSlash.replaceFirst('https://', 'http://');
                candidates.add('$hb$padded.mp3');
                candidates.add('$hb$plain.mp3');
              }
            } else if (withSlash.startsWith('http://')) {
              if (!kReleaseMode) {
                candidates.add('$withSlash$padded.mp3');
                candidates.add('$withSlash$plain.mp3');
              }
              final sb = withSlash.replaceFirst('http://', 'https://');
              candidates.add('$sb$padded.mp3');
              candidates.add('$sb$plain.mp3');
            }
          } else {
            candidates.add('https://$withSlash$padded.mp3');
            candidates.add('https://$withSlash$plain.mp3');
            if (!kReleaseMode) {
              candidates.add('http://$withSlash$padded.mp3');
              candidates.add('http://$withSlash$plain.mp3');
            }
          }
        }

        // try all candidates until one succeeds via CacheManager
        for (int k = 0; k < candidates.length; k++) {
          try {
            final cachedPath = await cache.getOrDownloadPath(candidates[k]);
            final dest = await storage.filePathForSurah(surah);
            await File(cachedPath).copy(dest);
            // verify MP3
            final file = File(dest);
            final okExists = await file.exists();
            final okSize = okExists ? (await file.length()) > 4096 : false;
            final okSig = okExists ? await _isLikelyMp3(file) : false;
            if (okExists && okSize && okSig) {
              final ctrl = _controllerFor(surah);
              ctrl.add(DownloadProgress(surah, 1, DownloadStatus.completed));
              return;
            } else {
              if (okExists) { try { await file.delete(); } catch (_) {} }
            }
          } catch (_) {}
        }
        // if none worked, mark failed
        final ctrl = _controllerFor(surah);
        ctrl.add(DownloadProgress(surah, 0, DownloadStatus.failed));
      } catch (_) {
        final ctrl = _controllerFor(surah);
        ctrl.add(DownloadProgress(surah, 0, DownloadStatus.failed));
      }
    }
  }

  Future<bool> _downloadOnce({
    required int surah,
    required String url,
    required String taskId,
  }) async {
    final filename = '${surah.toString().padLeft(3, '0')}.mp3';
    final task = DownloadTask(
      url: url,
      filename: filename,
      baseDirectory: BaseDirectory.applicationDocuments,
      directory: AudioStorageDataSource.subDir,
      updates: Updates.statusAndProgress,
      taskId: taskId,
    );

    final ctrl = _controllerFor(surah);
    var completed = false;

    await FileDownloader().download(
      task,
      onProgress: (p) {
        ctrl.add(DownloadProgress(surah, p, DownloadStatus.downloading));
      },
      onStatus: (s) {
        switch (s) {
          case TaskStatus.complete:
            completed = true;
            ctrl.add(DownloadProgress(surah, 1, DownloadStatus.completed));
            break;
          case TaskStatus.failed:
            ctrl.add(DownloadProgress(surah, 0, DownloadStatus.failed));
            break;
          case TaskStatus.canceled:
            ctrl.add(DownloadProgress(surah, 0, DownloadStatus.canceled));
            break;
          default:
            // ignore other intermediary statuses
            break;
        }
      },
    );
    // Verify that the downloaded file exists and is a likely MP3 (guard against HTTP 404 HTML pages)
    try {
      final path = await storage.filePathForSurah(surah);
      final file = File(path);
      final okExists = await file.exists();
      final okSize = okExists ? (await file.length()) > 4096 : false; // >4KB heuristic
      final okSig = okExists ? await _isLikelyMp3(file) : false;
      final ok = okExists && okSize && okSig;
      if (!ok) {
        if (okExists) {
          // remove invalid artifact to allow next fallback attempt
          try { await file.delete(); } catch (_) {}
        }
        ctrl.add(DownloadProgress(surah, 0, DownloadStatus.failed));
        return false;
      }
    } catch (_) {
      ctrl.add(DownloadProgress(surah, 0, DownloadStatus.failed));
      return false;
    }

    return completed;
  }

  Future<bool> _isLikelyMp3(File f) async {
    try {
      final raf = await f.open();
      final len = await f.length();
      final n = len >= 10 ? 10 : len;
      final bytes = await raf.read(n);
      await raf.close();
      if (bytes.length >= 3 &&
          bytes[0] == 0x49 && // 'I'
          bytes[1] == 0x44 && // 'D'
          bytes[2] == 0x33) { // '3' => ID3 tag
        return true;
      }
      if (bytes.length >= 2 && bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0) {
        return true; // frame sync
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> deleteSurah(int surah) => storage.delete(surah);

  @override
  Future<bool> isDownloaded(int surah) => storage.exists(surah);

  @override
  Future<List<int>> listDownloadedSurahs() => storage.listDownloaded();

  @override
  Stream<DownloadProgress> progressStream(int surah) => _controllerFor(surah).stream;
}
