import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/audio_download_repository.dart';
import 'audio_download_state.dart';

class AudioDownloadCubit extends Cubit<AudioDownloadState> {
  final AudioDownloadRepository repo;
  final List<int> _allSurahs = List<int>.generate(114, (i) => i + 1);
  final Map<int, StreamSubscription> _subs = {};

  AudioDownloadCubit(this.repo) : super(AudioDownloadState.initial()) {
    loadIndexes();
  }

  Future<void> loadIndexes() async {
    emit(state.copyWith(loading: true));
    final downloaded = await repo.listDownloadedSurahs();
    final setD = downloaded.toSet();
    final notDownloaded = _allSurahs.where((s) => !setD.contains(s)).toList();
    emit(state.copyWith(downloaded: downloaded, notDownloaded: notDownloaded, loading: false));
  }

  Future<void> download(int surah) async {
    if (_subs.containsKey(surah)) return; // already tracking
    // subscribe to progress
    final sub = repo.progressStream(surah).listen((event) {
      final map = Map<int, double>.from(state.progressBySurah);
      map[event.surah] = event.progress;
      final status = Map<int, DownloadStatus>.from(state.statusBySurah);
      status[event.surah] = _mapStatus(event.status);
      emit(state.copyWith(progressBySurah: map, statusBySurah: status));
      if (event.status == DownloadStatus.completed) {
        // refresh lists
        loadIndexes();
        _disposeSub(surah);
      }
    });
    _subs[surah] = sub;
    try {
      await repo.downloadSurah(surah);
    } catch (_) {
      // mark as failed on immediate error (e.g., URL resolution)
      final map = Map<int, double>.from(state.progressBySurah);
      map[surah] = 0.0;
      final status = Map<int, DownloadStatus>.from(state.statusBySurah);
      status[surah] = DownloadStatus.failed;
      emit(state.copyWith(progressBySurah: map, statusBySurah: status));
      _disposeSub(surah);
    }
  }

  Future<void> delete(int surah) async {
    await repo.deleteSurah(surah);
    await loadIndexes();
  }

  void _disposeSub(int surah) {
    final sub = _subs.remove(surah);
    if (sub != null) {
      // Not awaited intentionally to avoid blocking the listener.
      sub.cancel();
    }
  }

  bool isDownloaded(int surah) => state.downloaded.contains(surah);

  DownloadStatus _mapStatus(DownloadStatus s) => s;

  @override
  Future<void> close() async {
    for (final s in _subs.values) {
      await s.cancel();
    }
    _subs.clear();
    return super.close();
  }
}
