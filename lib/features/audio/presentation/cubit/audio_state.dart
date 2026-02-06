import 'package:equatable/equatable.dart';

enum AudioPhase { idle, downloading, preparing, playing, paused, error }
/// Visual/behavioral repeat configuration
enum RepeatMode { one, off, next }

class AudioState extends Equatable {
  static const Object _noChange = Object();
  final String? url;
  final bool isPlaying;
  final Duration position;
  final Duration? duration;
  /// The surah currently selected/queued in the UI.
  final int? currentSurah;

  /// The surah currently loaded in the audio engine (source of truth for playback).
  final int? loadedSurah;

  // ✅ Playback details
  /// True when the underlying player is buffering/loading while having a selected track.
  /// We keep [phase] stable (e.g., playing/paused) and expose buffering separately to avoid UI flicker.
  final bool isBuffering;

  // New fields for unified flow
  final AudioPhase phase; // idle | downloading | preparing | playing | paused | error
  final double downloadProgress; // 0..1
  final String? errorMessage;
  final RepeatMode repeatMode; // one | off | next
  final double speed; // 0.5 .. 2.0
  final bool autoDownload; // auto download when playing a surah
  final Duration? sleepTimer; // null = off

  const AudioState({
    required this.url,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.currentSurah,
    required this.loadedSurah,
    required this.isBuffering,
    required this.phase,
    required this.downloadProgress,
    required this.errorMessage,
    required this.repeatMode,
    required this.speed,
    required this.autoDownload,
    required this.sleepTimer,
  });

  factory AudioState.initial() => const AudioState(
        url: null,
        isPlaying: false,
        position: Duration.zero,
        duration: null,
        currentSurah: null,
        loadedSurah: null,
        isBuffering: false,
        phase: AudioPhase.idle,
        downloadProgress: 0.0,
        errorMessage: null,
        repeatMode: RepeatMode.one,
        speed: 1.0,
        autoDownload: true,
        sleepTimer: null,
      );

  /// copyWith supports clearing nullable fields by passing explicit `null`.
  /// For nullable fields we use a sentinel value to differentiate between
  /// "no change" and "set to null".
  AudioState copyWith({
    Object? url = _noChange,
    bool? isPlaying,
    Duration? position,
    Object? duration = _noChange,
    Object? currentSurah = _noChange,
    Object? loadedSurah = _noChange,
    bool? isBuffering,
    AudioPhase? phase,
    double? downloadProgress,
    Object? errorMessage = _noChange,
    RepeatMode? repeatMode,
    double? speed,
    bool? autoDownload,
    Object? sleepTimer = _noChange,
  }) =>
      AudioState(
        url: url == _noChange ? this.url : url as String?,
        isPlaying: isPlaying ?? this.isPlaying,
        position: position ?? this.position,
        duration: duration == _noChange ? this.duration : duration as Duration?,
        currentSurah: currentSurah == _noChange ? this.currentSurah : currentSurah as int?,
        loadedSurah: loadedSurah == _noChange ? this.loadedSurah : loadedSurah as int?,
        isBuffering: isBuffering ?? this.isBuffering,
        phase: phase ?? this.phase,
        downloadProgress: downloadProgress ?? this.downloadProgress,
        errorMessage: errorMessage == _noChange ? this.errorMessage : errorMessage as String?,
        repeatMode: repeatMode ?? this.repeatMode,
        speed: speed ?? this.speed,
        autoDownload: autoDownload ?? this.autoDownload,
        sleepTimer: sleepTimer == _noChange ? this.sleepTimer : sleepTimer as Duration?,
      );

  @override
  List<Object?> get props => [
        url,
        isPlaying,
        position,
        duration,
        currentSurah,
        loadedSurah,
        isBuffering,
        phase,
        downloadProgress,
        errorMessage,
        repeatMode,
        speed,
        autoDownload,
        sleepTimer,
      ];

  bool get isLoading => phase == AudioPhase.downloading || phase == AudioPhase.preparing;
}
