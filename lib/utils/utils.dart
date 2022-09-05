import 'package:fluent_ui/fluent_ui.dart';

void checkMemory() {
  var imageCache = PaintingBinding.instance.imageCache;
  if (imageCache.currentSizeBytes >= 55 << 20) {
    imageCache.clear();
    imageCache.clearLiveImages();
  }
}
