import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AudioCacheDataSource {
  final BaseCacheManager _cache;
  AudioCacheDataSource({BaseCacheManager? cache}) : _cache = cache ?? DefaultCacheManager();

  Future<String?> getCachedFilePath(String url) async {
    final info = await _cache.getFileFromCache(url);
    return info?.file.path;
  }

  Future<String> prefetch(String url) async {
    final file = await _cache.getSingleFile(url);
    return file.path;
  }

  Future<String> getOrDownloadPath(String url) async {
    final cached = await getCachedFilePath(url);
    if (cached != null) return cached;
    return prefetch(url);
  }
}
