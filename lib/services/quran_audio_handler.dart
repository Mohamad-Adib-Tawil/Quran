import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// AudioHandler يربط just_audio بنظام التشغيل (Lock Screen + Notification).
/// يستخدم نفس AudioPlayer المسجّل في GetIt — لا يُنشئ مشغّلاً جديداً.
class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player;

  QuranAudioHandler(this._player) {
    // إرسال playbackState مستمر من حالة المشغّل الحالي
    _player.playbackEventStream.map(_buildPlaybackState).pipe(playbackState);
  }

  PlaybackState _buildPlaybackState(PlaybackEvent event) {
    final playing = _player.playing;
    final processingState = {
      ProcessingState.idle: AudioProcessingState.idle,
      ProcessingState.loading: AudioProcessingState.loading,
      ProcessingState.buffering: AudioProcessingState.buffering,
      ProcessingState.ready: AudioProcessingState.ready,
      ProcessingState.completed: AudioProcessingState.completed,
    }[_player.processingState]!;

    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: processingState,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: 0,
    );
  }

  // ── Callbacks مُسجَّلة من AudioCubit عند تهيئته ──────────────────────────

  Future<void> Function()? onPlayRequested;
  Future<void> Function()? onPauseRequested;
  Future<void> Function()? onNextRequested;
  Future<void> Function()? onPreviousRequested;
  Future<void> Function()? onStopRequested;

  // ── تنفيذ أوامر النظام ────────────────────────────────────────────────────

  @override
  Future<void> play() => onPlayRequested?.call() ?? _player.play();

  @override
  Future<void> pause() => onPauseRequested?.call() ?? _player.pause();

  @override
  Future<void> skipToNext() async => onNextRequested?.call();

  @override
  Future<void> skipToPrevious() async => onPreviousRequested?.call();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await (onStopRequested?.call() ?? _player.stop());
    await super.stop();
  }

  // ── تحديث معلومات السورة في ويدجت شاشة القفل/الإشعارات ──────────────────

  /// يُستدعى من AudioCubit عند بدء تشغيل سورة جديدة.
  void updateNowPlaying({
    required int surah,
    required String arabicName,
    required String latinName,
    Duration? duration,
    Uri? artUri,
  }) {
    mediaItem.add(MediaItem(
      id: 'surah_$surah',
      album: 'القرآن الكريم',
      title: arabicName,
      artist: latinName,
      duration: duration,
      artUri: artUri,
      extras: {'surahNumber': surah},
    ));
  }

  /// تحديث المدة بعد تحميل الملف (يُستدعى من durationStream).
  void updateDuration(Duration? duration) {
    final current = mediaItem.value;
    if (current == null || duration == null) return;
    mediaItem.add(current.copyWith(duration: duration));
  }
}
