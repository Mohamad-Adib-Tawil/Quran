import 'dart:async';

enum DownloadStatus { idle, downloading, completed, failed, canceled }

class DownloadProgress {
  final int surah;
  final double progress; // 0.0 .. 1.0
  final DownloadStatus status;
  const DownloadProgress(this.surah, this.progress, this.status);
}

abstract class AudioDownloadRepository {
  Future<void> downloadSurah(int surah);
  Future<void> deleteSurah(int surah);
  Future<bool> isDownloaded(int surah);
  Future<List<int>> listDownloadedSurahs();
  Stream<DownloadProgress> progressStream(int surah);
}
