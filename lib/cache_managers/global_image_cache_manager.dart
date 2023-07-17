import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class GlobalImageCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'xview';

  static final GlobalImageCacheManager _instance = GlobalImageCacheManager._(
    Config(
      key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 200,
      fileService: HttpFileService(),
    ),
  );

  factory GlobalImageCacheManager() {
    return _instance;
  }

  GlobalImageCacheManager._(Config config) : super(config);
}
