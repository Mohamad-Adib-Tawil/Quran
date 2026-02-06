import 'package:equatable/equatable.dart';

enum AudioPhase { idle, downloading, preparing, playing, paused, error }
/// Visual/behavioral repeat configuration
enum RepeatMode { one, off, next }

class AudioState extends Equatable {
  final String? url;
  final bool isPlaying;
  final Duration position;
  final Duration? duration;
  final int? currentSurah;

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
        isBuffering: false,
        phase: AudioPhase.idle,
        downloadProgress: 0.0,
        errorMessage: null,
        repeatMode: RepeatMode.one,
        speed: 1.0,
        autoDownload: true,
        sleepTimer: null,
      );

  AudioState copyWith({
    String? url,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    int? currentSurah,
    bool? isBuffering,
    AudioPhase? phase,
    double? downloadProgress,
    String? errorMessage,
    RepeatMode? repeatMode,
    double? speed,
    bool? autoDownload,
    Duration? sleepTimer,
  }) =>
      AudioState(
        url: url ?? this.url,
        isPlaying: isPlaying ?? this.isPlaying,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        currentSurah: currentSurah ?? this.currentSurah,
        isBuffering: isBuffering ?? this.isBuffering,
        phase: phase ?? this.phase,
        downloadProgress: downloadProgress ?? this.downloadProgress,
        errorMessage: errorMessage ?? this.errorMessage,
        repeatMode: repeatMode ?? this.repeatMode,
        speed: speed ?? this.speed,
        autoDownload: autoDownload ?? this.autoDownload,
        sleepTimer: sleepTimer ?? this.sleepTimer,
      );

  @override
  List<Object?> get props => [
        url,
        isPlaying,
        position,
        duration,
        currentSurah,
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
