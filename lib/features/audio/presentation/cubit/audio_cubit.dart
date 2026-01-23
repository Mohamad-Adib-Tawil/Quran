import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' show ProcessingState; // for completion detection

import '../../domain/repositories/audio_repository.dart';
import '../../domain/repositories/audio_download_repository.dart';
import 'audio_state.dart';

/// Handles playback only. No network logic here.
class AudioCubit extends Cubit<AudioState> {
  final AudioRepository _repo;
  final AudioDownloadRepository _downloadRepo;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _dlSub;
  int? _lastRequestedSurah;

  AudioCubit(this._repo, this._downloadRepo) : super(AudioState.initial()) {
    _bind();
  }

  void _bind() {
    _posSub = _repo.positionStream.listen((pos) {
      emit(state.copyWith(position: pos));
    });
    _durSub = _repo.durationStream.listen((dur) {
      emit(state.copyWith(duration: dur));
    });
    _stateSub = _repo.playerStateStream.listen((playerState) async {
      final playing = playerState.playing;
      emit(state.copyWith(isPlaying: playing));
      // Handle completion
      if (playerState.processingState == ProcessingState.completed) {
        await _onCompleted();
      }
    });
  }

  Future<String> prepareSurah(int surah, {Duration? initialPosition, bool cache = true}) async {
    final url = await _repo.prepareSurah(surah: surah, initialPosition: initialPosition, cache: cache);
    emit(state.copyWith(url: url, currentSurah: surah, position: initialPosition ?? Duration.zero));
    return url;
  }

  Future<void> prepareAndPlaySurah(int surah, {Duration? from, bool cache = true}) async {
    // Keep legacy behavior for already-downloaded use cases
    await prepareSurah(surah, initialPosition: from, cache: cache);
    await play();
    emit(state.copyWith(phase: AudioPhase.playing));
  }

  Future<void> prefetchSurah(int surah) => _repo.prefetchSurah(surah: surah);

  Future<void> setUrl(String url) async {
    await _repo.setUrl(url);
    emit(state.copyWith(url: url));
  }

  Future<void> play() => _repo.play();
  Future<void> pause() => _repo.pause();
  Future<void> stop() => _repo.stop();
  Future<void> seek(Duration position) => _repo.seek(position);

  Future<void> toggle() async {
    if (state.isPlaying) {
      await pause();
      emit(state.copyWith(phase: AudioPhase.paused));
      return;
    }
    if (state.url == null && state.currentSurah != null) {
      // No source loaded yet: try to play current surah via unified flow (auto-download if needed)
      await playSurah(state.currentSurah!, from: state.position);
      return;
    }
    await play();
    emit(state.copyWith(phase: AudioPhase.playing));
  }

  // New API: unified play that auto-downloads if needed
  Future<void> playSurah(int surah, {Duration? from}) async {
    _lastRequestedSurah = surah;
    emit(state.copyWith(currentSurah: surah, errorMessage: null));
    try {
      final hasFile = await _downloadRepo.isDownloaded(surah);
      if (!hasFile) {
        // Start download with progress updates
        await _startDownloadFlow(surah);
        return; // progression continues via progress listener
      }
      emit(state.copyWith(phase: AudioPhase.preparing));
      await prepareSurah(surah, initialPosition: from, cache: true);
      await play();
      emit(state.copyWith(phase: AudioPhase.playing));
    } catch (e) {
      emit(state.copyWith(phase: AudioPhase.error, errorMessage: e.toString()));
    }
  }

  Future<void> retry() async {
    final s = _lastRequestedSurah ?? state.currentSurah;
    if (s != null) {
      await playSurah(s, from: Duration.zero);
    }
  }

  void setOnCompleteBehavior(OnCompleteBehavior behavior) {
    emit(state.copyWith(onComplete: behavior));
  }

  // Set current surah context without preparing or downloading
  void selectSurah(int surah) {
    if (surah < 1 || surah > 114) return;
    emit(state.copyWith(currentSurah: surah));
  }

  Future<void> _startDownloadFlow(int surah) async {
    // reset any previous download subscription
    await _dlSub?.cancel();
    emit(state.copyWith(phase: AudioPhase.downloading, downloadProgress: 0.0));
    _dlSub = _downloadRepo.progressStream(surah).listen((evt) async {
      emit(state.copyWith(downloadProgress: evt.progress, phase: AudioPhase.downloading));
      if (evt.status == DownloadStatus.completed) {
        await _dlSub?.cancel();
        emit(state.copyWith(phase: AudioPhase.preparing, downloadProgress: 1.0));
        await prepareSurah(surah, initialPosition: Duration.zero, cache: true);
        await play();
        emit(state.copyWith(phase: AudioPhase.playing));
      } else if (evt.status == DownloadStatus.failed || evt.status == DownloadStatus.canceled) {
        await _dlSub?.cancel();
        emit(state.copyWith(phase: AudioPhase.error, errorMessage: 'تعذر تحميل السورة. حاول مرة أخرى.'));
      }
    });
    // kick off the download (progress listener will drive the rest)
    try {
      await _downloadRepo.downloadSurah(surah);
    } catch (e) {
      await _dlSub?.cancel();
      emit(state.copyWith(phase: AudioPhase.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onCompleted() async {
    switch (state.onComplete) {
      case OnCompleteBehavior.repeatOne:
        await _repo.seek(Duration.zero);
        await _repo.play();
        emit(state.copyWith(phase: AudioPhase.playing, position: Duration.zero));
        break;
      case OnCompleteBehavior.stop:
        await _repo.stop();
        emit(state.copyWith(phase: AudioPhase.idle));
        break;
      case OnCompleteBehavior.next:
        final s = state.currentSurah;
        if (s != null && s < 114) {
          await playSurah(s + 1, from: Duration.zero);
        } else {
          await _repo.stop();
          emit(state.copyWith(phase: AudioPhase.idle));
        }
        break;
    }
  }

  @override
  Future<void> close() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _dlSub?.cancel();
    return super.close();
  }
}
