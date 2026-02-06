import 'package:flutter_bloc/flutter_bloc.dart';
import 'audio_settings_service.dart';
import 'audio_settings_state.dart';
import '../presentation/cubit/audio_cubit.dart';
import '../presentation/cubit/audio_state.dart';

class AudioSettingsCubit extends Cubit<AudioSettingsState> {
  final AudioSettingsService _svc;
  final AudioCubit _player;
  AudioSettingsCubit(this._svc, this._player)
      : super(AudioSettingsState.initial(
          speed: _svc.loadSpeed(),
          repeatMode: _svc.loadRepeat(),
          autoDownload: _svc.loadAutoDownload(),
        )) {
    // Apply settings to player on init
    _player.setPlaybackSpeed(state.speed);
    _player.setRepeatMode(state.repeatMode);
    _player.setAutoDownload(state.autoDownload);
  }

  Future<void> setSpeed(double v) async {
    await _player.setPlaybackSpeed(v);
    await _svc.saveSpeed(v);
    emit(state.copyWith(speed: v));
  }

  Future<void> setRepeat(RepeatMode mode) async {
    _player.setRepeatMode(mode);
    await _svc.saveRepeat(mode);
    emit(state.copyWith(repeatMode: mode));
  }

  Future<void> setAutoDownload(bool v) async {
    _player.setAutoDownload(v);
    await _svc.saveAutoDownload(v);
    emit(state.copyWith(autoDownload: v));
  }
}
