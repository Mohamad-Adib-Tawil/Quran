import 'package:just_audio/just_audio.dart';

import '../../domain/repositories/audio_repository.dart';
import '../datasources/audio_player_data_source.dart';
import '../datasources/audio_storage_data_source.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioPlayerDataSource player;
  final AudioStorageDataSource storage;

  AudioRepositoryImpl({required this.player, required this.storage});

  @override
  Future<void> setUrl(String url) async {
    await player.setUrl(url);
  }

  @override
  Future<String> prepareSurah({
    required int surah,
    Duration? initialPosition,
    bool cache = true,
  }) async {
    final exists = await storage.exists(surah);
    if (!exists) {
      throw StateError('Surah $surah is not downloaded');
    }
    final path = await storage.filePathForSurah(surah);
    await player.setFilePath(path, initialPosition: initialPosition);
    return path;
  }

  @override
  Future<String> prepareAyah({required int surah, required int ayah}) async {
    // Backward-compatible: use surah-level URL for now
    return prepareSurah(surah: surah);
  }

  @override
  Future<void> prefetchSurah({required int surah}) async {}

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() => player.stop();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> setSpeed(double speed) => player.setSpeed(speed);

  @override
  bool get isPlaying => player.playing;

  @override
  Duration? get duration => player.duration;

  @override
  Stream<Duration> get positionStream => player.positionStream;

  @override
  Stream<PlayerState> get playerStateStream => player.playerStateStream;

  @override
  Stream<Duration?> get durationStream => player.durationStream;
}
