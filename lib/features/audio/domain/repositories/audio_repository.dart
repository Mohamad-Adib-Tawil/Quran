import 'package:just_audio/just_audio.dart';

abstract class AudioRepository {
  Future<void> setUrl(String url);
  Future<String> prepareSurah({required int surah, Duration? initialPosition, bool cache = true});
  Future<void> prefetchSurah({required int surah});
  Future<String> prepareAyah({required int surah, required int ayah});
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> setSpeed(double speed);

  bool get isPlaying;
  Duration? get duration;

  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<PlayerState> get playerStateStream;
}
