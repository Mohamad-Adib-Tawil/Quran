import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/audio/data/datasources/audio_player_data_source.dart';
import '../../features/audio/data/datasources/audio_remote_data_source.dart';
import '../../features/audio/data/datasources/audio_cache_data_source.dart';
import '../../features/audio/data/datasources/audio_storage_data_source.dart';
import '../../features/audio/data/repositories/audio_repository_impl_fixed.dart';
import '../../features/audio/domain/repositories/audio_repository.dart' as audio_domain;
import '../../features/audio/domain/repositories/audio_download_repository.dart';
import '../../features/audio/data/repositories/audio_download_repository_impl.dart';
import '../../features/quran/data/datasources/quran_local_data_source.dart';
import '../../features/quran/data/repositories/quran_repository_impl.dart';
import '../../features/quran/domain/repositories/quran_repository.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // Core externals
  sl.registerLazySingleton<AudioPlayer>(() => AudioPlayer());

  // Async singletons
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Data sources
  sl.registerLazySingleton<QuranLocalDataSource>(() => QuranLocalDataSource());
  // Initialize AudioRemoteDataSource with asset mapping and optional baseUrl fallback
  final audioRemote = AudioRemoteDataSource();
  audioRemote.configure(
    baseUrl: 'https://quran.devmmnd.com/quran-audio/',
    fallbackBaseUrls: const [
      // HTTP variant (some networks/hosts may only be reachable via IPv4/HTTP)
      'http://quran.devmmnd.com/quran-audio/',
      // Public reciter hosts (zero-padded 3-digit files)
      'https://server8.mp3quran.net/afs/', // Mishary Alafasy
      'https://server7.mp3quran.net/sds/', // Abdul Rahman AlSudais
    ],
  );
  await audioRemote.loadFromAssets();
  sl.registerSingleton<AudioRemoteDataSource>(audioRemote);
  sl.registerLazySingleton<AudioPlayerDataSource>(() => AudioPlayerDataSource(sl<AudioPlayer>()));
  sl.registerLazySingleton<AudioCacheDataSource>(() => AudioCacheDataSource());
  sl.registerLazySingleton<AudioStorageDataSource>(() => AudioStorageDataSource());

  // Repositories
  sl.registerLazySingleton<QuranRepository>(() => QuranRepositoryImpl(sl<QuranLocalDataSource>()));
  sl.registerLazySingleton<AudioDownloadRepository>(() => AudioDownloadRepositoryImpl(
        remote: sl<AudioRemoteDataSource>(),
        storage: sl<AudioStorageDataSource>(),
        cache: sl<AudioCacheDataSource>(),
      ));
  sl.registerLazySingleton<audio_domain.AudioRepository>(() => AudioRepositoryImpl(
        player: sl<AudioPlayerDataSource>(),
        storage: sl<AudioStorageDataSource>(),
      ));
}
