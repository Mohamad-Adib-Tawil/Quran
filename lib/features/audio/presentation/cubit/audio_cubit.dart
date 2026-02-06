import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' show ProcessingState; // for completion detection

import '../../domain/repositories/audio_repository.dart';
import '../../domain/repositories/audio_download_repository.dart';
import 'audio_state.dart';
import '../../../../services/audio_url_catalog_service.dart';

/// Handles playback only. No network logic here.
class AudioCubit extends Cubit<AudioState> {
  final AudioRepository _repo;
  final AudioDownloadRepository _downloadRepo;
  final AudioUrlCatalogService _catalog;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _dlSub;
  int? _lastRequestedSurah;
  Timer? _sleepTimerHandle;

  AudioCubit(this._repo, this._downloadRepo, this._catalog) : super(AudioState.initial()) {
    _bind();
  }

  void _bind() {
    // ✅ Cancel any existing subscriptions before creating new ones
    // Note: Not awaiting here to avoid making _bind async (called from constructor)
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _dlSub?.cancel();
    
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

  /// ✅ Cancel all active subscriptions to prevent memory leaks
  Future<void> _cancelSubscriptions() async {
    await _posSub?.cancel();
    await _durSub?.cancel();
    await _stateSub?.cancel();
    await _dlSub?.cancel();
    _posSub = null;
    _durSub = null;
    _stateSub = null;
    _dlSub = null;
  }

  Future<String> prepareSurah(int surah, {Duration? initialPosition, bool cache = true}) async {
    // ✅ Cancel download subscription when preparing a new surah
    await _dlSub?.cancel();
    _dlSub = null;
    
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

  Future<void> play() async {
    try {
      await _repo.play();
    } catch (e) {
      emit(state.copyWith(
        phase: AudioPhase.error,
        isPlaying: false,
        errorMessage: 'فشل تشغيل الصوت: ${e.toString()}',
      ));
      rethrow;
    }
  }
  Future<void> pause() => _repo.pause();
  Future<void> stop() => _repo.stop();
  Future<void> seek(Duration position) => _repo.seek(position);

  Future<void> toggle() async {
    try {
      if (state.isPlaying) {
        await pause();
        emit(state.copyWith(phase: AudioPhase.paused));
        return;
      }
      if (state.url == null && state.currentSurah != null) {
        // لا يوجد مصدر مُحمّل: شغّل مباشرة من كتالوج JSON (بث)
        await playFromCatalog(state.currentSurah!);
        return;
      }
      await play();
      emit(state.copyWith(phase: AudioPhase.playing));
    } catch (e) {
      emit(state.copyWith(
        phase: AudioPhase.error,
        isPlaying: false,
        errorMessage: 'خطأ في التبديل: ${e.toString()}',
      ));
    }
  }

  // New API: unified play that auto-downloads if needed
  Future<void> playSurah(int surah, {Duration? from}) async {
    _lastRequestedSurah = surah;
    emit(state.copyWith(currentSurah: surah, errorMessage: null));
    
    try {
      // ✅ Validate input
      if (surah < 1 || surah > 114) {
        throw ArgumentError('رقم السورة غير صحيح: $surah');
      }
      
      final hasFile = await _downloadRepo.isDownloaded(surah);
      
      // Honor autoDownload preference
      if (!hasFile) {
        if (state.autoDownload) {
          await _startDownloadFlow(surah);
          return; // flow continues via progress listener
        } else {
          // Stream directly if available
          await playFromCatalog(surah);
          return;
        }
      }
      
      emit(state.copyWith(phase: AudioPhase.preparing));
      await prepareSurah(surah, initialPosition: from, cache: true);
      await play();
      emit(state.copyWith(phase: AudioPhase.playing));
      
    } on ArgumentError catch (e) {
      emit(state.copyWith(
        phase: AudioPhase.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        phase: AudioPhase.error,
        errorMessage: 'فشل تشغيل السورة: ${e.toString()}',
      ));
    }
  }

  Future<void> retry() async {
    final s = _lastRequestedSurah ?? state.currentSurah;
    if (s != null) {
      await playSurah(s, from: Duration.zero);
    }
  }

  // Repeat mode control
  void setRepeatMode(RepeatMode mode) {
    emit(state.copyWith(repeatMode: mode));
  }

  // Playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    await _repo.setSpeed(speed);
    emit(state.copyWith(speed: speed));
  }

  // Auto download preference (affects playSurah flow)
  void setAutoDownload(bool value) {
    emit(state.copyWith(autoDownload: value));
  }

  // Sleep timer: stop after [duration] from now; null to cancel
  void setSleepTimer(Duration? duration) {
    _sleepTimerHandle?.cancel();
    if (duration == null) {
      emit(state.copyWith(sleepTimer: null));
      return;
    }
    _sleepTimerHandle = Timer(duration, () async {
      await stop();
      emit(state.copyWith(phase: AudioPhase.idle, isPlaying: false, sleepTimer: null));
    });
    emit(state.copyWith(sleepTimer: duration));
  }

  // Set current surah context without preparing or downloading
  void selectSurah(int surah) {
    if (surah < 1 || surah > 114) return;
    emit(state.copyWith(currentSurah: surah));
  }

  // Play directly from catalog JSON URL (no download). Used by Home screen.
  Future<void> playFromCatalog(int surah) async {
    try {
      // ✅ Validate input
      if (surah < 1 || surah > 114) {
        throw ArgumentError('رقم السورة غير صحيح: $surah');
      }
      
      final url = _catalog.urlForSurah(surah);
      if (url == null) {
        throw StateError('لا يوجد رابط صوت لهذه السورة في الكتالوج');
      }
      
      // ✅ Validate HTTPS
      if (!url.startsWith('https://')) {
        throw StateError('مصدر الصوت يجب أن يكون HTTPS');
      }
      
      // منع أي مصدر آخر غير المسموح به
      const allowedPrefix = 'https://quran.devmmnd.com/quran-audio/';
      if (!url.startsWith(allowedPrefix)) {
        throw StateError('مصدر الصوت غير مسموح. يجب أن يبدأ بـ $allowedPrefix');
      }
      
      emit(state.copyWith(phase: AudioPhase.preparing, errorMessage: null));
      await _repo.setUrl(url);
      emit(state.copyWith(url: url, currentSurah: surah));
      await _repo.play();
      emit(state.copyWith(phase: AudioPhase.playing));
      
    } on ArgumentError catch (e) {
      emit(state.copyWith(
        phase: AudioPhase.error,
        errorMessage: e.message,
      ));
    } on StateError catch (e) {
      emit(state.copyWith(
        phase: AudioPhase.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        phase: AudioPhase.error,
        errorMessage: 'فشل تشغيل الصوت من الكتالوج: ${e.toString()}',
      ));
    }
  }

  Future<void> playNextFromCatalog() async {
    final s = state.currentSurah ?? 1;
    if (s < 114) {
      await playFromCatalog(s + 1);
    }
  }

  Future<void> playPrevFromCatalog() async {
    final s = state.currentSurah ?? 1;
    if (s > 1) {
      await playFromCatalog(s - 1);
    }
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
    switch (state.repeatMode) {
      case RepeatMode.one:
        await _repo.seek(Duration.zero);
        await _repo.play();
        emit(state.copyWith(phase: AudioPhase.playing, position: Duration.zero));
        break;
      case RepeatMode.off:
        await _repo.stop();
        emit(state.copyWith(phase: AudioPhase.idle));
        break;
      case RepeatMode.next:
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
  Future<void> close() async {
    // ✅ Properly dispose all resources
    await _cancelSubscriptions();
    _sleepTimerHandle?.cancel();
    _sleepTimerHandle = null;
    // Note: AudioRepository doesn't have dispose method, player is managed by just_audio
    return super.close();
  }
}
