import 'package:equatable/equatable.dart';

enum AudioPhase { idle, downloading, preparing, playing, paused, error }
enum OnCompleteBehavior { repeatOne, stop, next }

class AudioState extends Equatable {
  final String? url;
  final bool isPlaying;
  final Duration position;
  final Duration? duration;
  final int? currentSurah;

  // New fields for unified flow
  final AudioPhase phase; // idle | downloading | preparing | playing | paused | error
  final double downloadProgress; // 0..1
  final String? errorMessage;
  final OnCompleteBehavior onComplete; // repeatOne | stop | next

  const AudioState({
    required this.url,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.currentSurah,
    required this.phase,
    required this.downloadProgress,
    required this.errorMessage,
    required this.onComplete,
  });

  factory AudioState.initial() => const AudioState(
        url: null,
        isPlaying: false,
        position: Duration.zero,
        duration: null,
        currentSurah: null,
        phase: AudioPhase.idle,
        downloadProgress: 0.0,
        errorMessage: null,
        onComplete: OnCompleteBehavior.repeatOne,
      );

  AudioState copyWith({
    String? url,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    int? currentSurah,
    AudioPhase? phase,
    double? downloadProgress,
    String? errorMessage,
    OnCompleteBehavior? onComplete,
  }) =>
      AudioState(
        url: url ?? this.url,
        isPlaying: isPlaying ?? this.isPlaying,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        currentSurah: currentSurah ?? this.currentSurah,
        phase: phase ?? this.phase,
        downloadProgress: downloadProgress ?? this.downloadProgress,
        errorMessage: errorMessage ?? this.errorMessage,
        onComplete: onComplete ?? this.onComplete,
      );

  @override
  List<Object?> get props => [
        url,
        isPlaying,
        position,
        duration,
        currentSurah,
        phase,
        downloadProgress,
        errorMessage,
        onComplete,
      ];
}
