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
import '../../services/audio_session_manager.dart';
import '../../services/audio_url_catalog_service.dart';
import '../../services/last_read_service.dart';
import '../../services/favorites_service.dart';
import '../../services/study_tools_service.dart';
import '../../features/audio/settings/audio_settings_service.dart';
import '../config/feature_flags.dart';
import '../logging/logging.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // Core externals
  sl.registerLazySingleton<AudioPlayer>(() => AudioPlayer());

  // Async singletons
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  // Feature flags
  sl.registerLazySingleton<FeatureFlagsService>(() => FeatureFlagsService(sl<SharedPreferences>()));
  // Logging & crash
  sl.registerLazySingleton<AppLogger>(() => AppLogger());
  sl.registerLazySingleton<CrashReporter>(() => CrashReporter(sl<AppLogger>()));
  sl.registerLazySingleton<AudioSessionManager>(() => AudioSessionManager(sl<SharedPreferences>()));
  // Audio settings service
  sl.registerLazySingleton<AudioSettingsService>(() => AudioSettingsService(sl<SharedPreferences>()));
  // Last read storage service
  sl.registerLazySingleton<LastReadService>(() => LastReadService(sl<SharedPreferences>()));
  // Favorites storage service
  sl.registerLazySingleton<FavoritesService>(() => FavoritesService(sl<SharedPreferences>()));
  // Study tools service (advanced bookmarks, notes, goals)
  sl.registerLazySingleton<StudyToolsService>(() => StudyToolsService(sl<SharedPreferences>()));
  // Audio catalog from local JSON
  final audioCatalog = AudioUrlCatalogService();
  await audioCatalog.load();
  sl.registerSingleton<AudioUrlCatalogService>(audioCatalog);

  // Data sources
  sl.registerLazySingleton<QuranLocalDataSource>(() => QuranLocalDataSource());
  // Initialize AudioRemoteDataSource to use JSON mapping ONLY (no external fallbacks)
  final audioRemote = AudioRemoteDataSource();
  audioRemote.configure(
    baseUrl: null,
    fallbackBaseUrls: const [],
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
