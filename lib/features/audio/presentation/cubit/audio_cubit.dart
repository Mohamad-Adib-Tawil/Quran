import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart'
    show ProcessingState; // for completion detection

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

  AudioCubit(this._repo, this._downloadRepo, this._catalog)
    : super(AudioState.initial()) {
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
      final processing = playerState.processingState;

      // ✅ Single source of truth for playback state
      // We keep [phase] stable (playing/paused) during buffering and expose buffering separately.
      final bool buffering =
          processing == ProcessingState.loading ||
          processing == ProcessingState.buffering;

      AudioPhase nextPhase;
      if (processing == ProcessingState.completed ||
          processing == ProcessingState.idle) {
        nextPhase = AudioPhase.idle;
      } else if (processing == ProcessingState.ready) {
        nextPhase = playing ? AudioPhase.playing : AudioPhase.paused;
      } else {
        // loading/buffering
        // If we already have a selected track (url/surah), keep stable phase.
        if (state.url != null || state.currentSurah != null) {
          nextPhase = playing ? AudioPhase.playing : AudioPhase.paused;
        } else {
          nextPhase = AudioPhase.preparing;
        }
      }

      // ✅ Emit only if changed to avoid UI jitter
      if (state.isPlaying != playing ||
          state.phase != nextPhase ||
          state.isBuffering != buffering) {
        emit(
          state.copyWith(
            isPlaying: playing,
            phase: nextPhase,
            isBuffering: buffering,
          ),
        );
      }

      // Handle completion
      if (processing == ProcessingState.completed) {
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

  Future<String> prepareSurah(
    int surah, {
    Duration? initialPosition,
    bool cache = true,
  }) async {
    // ✅ Cancel download subscription when preparing a new surah
    await _dlSub?.cancel();
    _dlSub = null;

    final url = await _repo.prepareSurah(
      surah: surah,
      initialPosition: initialPosition,
      cache: cache,
    );

    // ✅ Mark which surah is actually loaded in the engine
    emit(
      state.copyWith(
        url: url,
        currentSurah: surah,
        loadedSurah: surah,
        position: initialPosition ?? Duration.zero,
        phase: AudioPhase.preparing,
        // duration will arrive via durationStream
      ),
    );

    return url;
  }

  Future<void> prepareAndPlaySurah(
    int surah, {
    Duration? from,
    bool cache = true,
  }) async {
    // Keep legacy behavior for already-downloaded use cases
    await prepareSurah(surah, initialPosition: from, cache: cache);
    await play();
    // phase/isPlaying are driven by playerStateStream
  }

  Future<void> prefetchSurah(int surah) => _repo.prefetchSurah(surah: surah);

  Future<void> setUrl(String url, {int? surah}) async {
    await _repo.setUrl(url);
    emit(state.copyWith(url: url, loadedSurah: surah ?? state.loadedSurah));
  }

  Future<void> play() async {
    try {
      await _repo.play();
    } catch (e) {
      emit(
        state.copyWith(
          phase: AudioPhase.error,
          isPlaying: false,
          errorMessage: 'فشل تشغيل الصوت: ${e.toString()}',
        ),
      );
      rethrow;
    }
  }

  Future<void> pause() => _repo.pause();

  Future<void> stop() => _repo.stop();

  // Clear audio player completely (stop and clear all state)
  Future<void> clearAudio() async {
    await _repo.stop();
    emit(
      state.copyWith(
        currentSurah: null,
        loadedSurah: null,
        url: null,
        position: Duration.zero,
        duration: null,
        isPlaying: false,
        isBuffering: false,
        phase: AudioPhase.idle,
      ),
    );
  }

  Future<void> seek(Duration position) => _repo.seek(position);

  Future<void> toggle() async {
    try {
      if (state.isPlaying) {
        await pause();
        // phase/isPlaying are driven by playerStateStream
        return;
      }
      if (state.url == null && state.currentSurah != null) {
        // ✅ No prepared source yet. Use unified flow so auto-download works.
        await playSurah(state.currentSurah!);
        return;
      }
      await play();
      // phase/isPlaying are driven by playerStateStream
    } catch (e) {
      emit(
        state.copyWith(
          phase: AudioPhase.error,
          isPlaying: false,
          errorMessage: 'خطأ في التبديل: ${e.toString()}',
        ),
      );
    }
  }

  // New API: unified play that auto-downloads if needed
  // Now sets pending state and waits for user confirmation only for non-downloaded surahs
  Future<void> playSurah(int surah, {Duration? from}) async {
    _lastRequestedSurah = surah;

    try {
      // ✅ Validate input
      if (surah < 1 || surah > 114) {
        throw ArgumentError('رقم السورة غير صحيح: $surah');
      }

      // Check if the surah is already downloaded
      final hasFile = await _downloadRepo.isDownloaded(surah);

      // If already downloaded, play it directly without asking for confirmation
      if (hasFile) {
        await confirmAndPlaySurah(surah, from: from);
        return;
      }

      // For non-downloaded surahs, ask for confirmation
      emit(
        state.copyWith(
          pendingSurah: surah,
          pendingInitialPosition: from,
          phase: AudioPhase.awaitingConfirmation,
          errorMessage: null,
        ),
      );
    } on ArgumentError catch (e) {
      emit(state.copyWith(phase: AudioPhase.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          phase: AudioPhase.error,
          errorMessage: 'فشل تشغيل السورة: ${e.toString()}',
        ),
      );
    }
  }

  // Confirms and starts playing the pending surah
  Future<void> confirmAndPlaySurah(int surah, {Duration? from}) async {
    _lastRequestedSurah = surah;
    // currentSurah is the queued/selected surah
    emit(
      state.copyWith(
        currentSurah: surah,
        pendingSurah: null,
        pendingInitialPosition: null,
        phase: AudioPhase.preparing,
        errorMessage: null,
      ),
    );

    try {
      // ✅ Validate input
      if (surah < 1 || surah > 114) {
        throw ArgumentError('رقم السورة غير صحيح: $surah');
      }

      // If switching to a new surah, stop the previous engine source first.
      if (state.loadedSurah != null && state.loadedSurah != surah) {
        await _repo.stop();
        emit(
          state.copyWith(
            url: null,
            duration: null,
            position: Duration.zero,
            isBuffering: false,
            loadedSurah: null,
            phase: AudioPhase.preparing,
          ),
        );
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

      // phase/isPlaying are driven by playerStateStream
      await prepareSurah(surah, initialPosition: from, cache: true);
      await play();
    } on ArgumentError catch (e) {
      emit(state.copyWith(phase: AudioPhase.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          phase: AudioPhase.error,
          errorMessage: 'فشل تشغيل السورة: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> retry() async {
    final s = _lastRequestedSurah ?? state.currentSurah;
    if (s != null) {
      await confirmAndPlaySurah(s, from: Duration.zero);
    }
  }

  // Reject pending surah (user declined to load)
  Future<void> rejectPendingSurah() async {
    await _repo.stop();
    emit(
      state.copyWith(
        pendingSurah: null,
        pendingInitialPosition: null,
        currentSurah: null,
        loadedSurah: null,
        url: null,
        position: Duration.zero,
        duration: null,
        isPlaying: false,
        isBuffering: false,
        phase: AudioPhase.idle,
      ),
    );
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
      emit(
        state.copyWith(
          phase: AudioPhase.idle,
          isPlaying: false,
          sleepTimer: null,
        ),
      );
    });
    emit(state.copyWith(sleepTimer: duration));
  }

  // Set current surah context (queued/selected) without touching playback.
  // ✅ Do not stop/reset the engine here; switching is handled inside playSurah.
  void selectSurah(int surah) {
    if (surah < 1 || surah > 114) return;
    if (state.currentSurah == surah) return;
    emit(
      state.copyWith(
        currentSurah: surah,
        position: Duration.zero,
        isBuffering: false,
      ),
    );
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

      // phase/isPlaying are driven by playerStateStream
      emit(state.copyWith(errorMessage: null));
      await _repo.setUrl(url);
      emit(state.copyWith(url: url, currentSurah: surah, loadedSurah: surah));
      await _repo.play();
    } on ArgumentError catch (e) {
      emit(state.copyWith(phase: AudioPhase.error, errorMessage: e.message));
    } on StateError catch (e) {
      emit(state.copyWith(phase: AudioPhase.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          phase: AudioPhase.error,
          errorMessage: 'فشل تشغيل الصوت من الكتالوج: ${e.toString()}',
        ),
      );
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
      emit(
        state.copyWith(
          downloadProgress: evt.progress,
          phase: AudioPhase.downloading,
        ),
      );
      if (evt.status == DownloadStatus.completed) {
        await _dlSub?.cancel();
        // phase/isPlaying are driven by playerStateStream
        emit(state.copyWith(downloadProgress: 1.0));
        await prepareSurah(surah, initialPosition: Duration.zero, cache: true);
        await play();
      } else if (evt.status == DownloadStatus.failed ||
          evt.status == DownloadStatus.canceled) {
        await _dlSub?.cancel();
        emit(
          state.copyWith(
            phase: AudioPhase.error,
            errorMessage: 'تعذر تحميل السورة. حاول مرة أخرى.',
          ),
        );
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
        emit(
          state.copyWith(phase: AudioPhase.playing, position: Duration.zero),
        );
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
