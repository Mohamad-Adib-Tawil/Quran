import 'package:just_audio/just_audio.dart';

class AudioPlayerDataSource {
  final AudioPlayer _player;
  AudioPlayerDataSource(this._player);

  Future<void> setUrl(String url, {Duration? initialPosition}) async {
    // Use setAudioSource to support setting an initial position before loading
    final source = AudioSource.uri(Uri.parse(url));
    await _player.setAudioSource(source, initialPosition: initialPosition);
  }

  Future<void> setFilePath(String path, {Duration? initialPosition}) async {
    final source = AudioSource.uri(Uri.file(path));
    await _player.setAudioSource(source, initialPosition: initialPosition);
  }
  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration position) => _player.seek(position);

  bool get playing => _player.playing;
  Duration? get duration => _player.duration;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
}
