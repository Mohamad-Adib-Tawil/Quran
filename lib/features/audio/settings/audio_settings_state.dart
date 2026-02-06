import 'package:equatable/equatable.dart';
import '../presentation/cubit/audio_state.dart';

class AudioSettingsState extends Equatable {
  final double speed; // 0.5..2.0
  final RepeatMode repeatMode;
  final bool autoDownload;

  const AudioSettingsState({
    required this.speed,
    required this.repeatMode,
    required this.autoDownload,
  });

  factory AudioSettingsState.initial({double speed = 1.0, RepeatMode repeatMode = RepeatMode.one, bool autoDownload = true}) =>
      AudioSettingsState(speed: speed, repeatMode: repeatMode, autoDownload: autoDownload);

  AudioSettingsState copyWith({double? speed, RepeatMode? repeatMode, bool? autoDownload}) =>
      AudioSettingsState(
        speed: speed ?? this.speed,
        repeatMode: repeatMode ?? this.repeatMode,
        autoDownload: autoDownload ?? this.autoDownload,
      );

  @override
  List<Object?> get props => [speed, repeatMode, autoDownload];
}
