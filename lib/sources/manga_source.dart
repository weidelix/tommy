import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:xview/global_image_cache_manager.dart';

import 'package:xview/tabs.dart';
import 'package:xview/theme.dart';

class Manga {
  Manga(
      {required this.id,
      required this.title,
      required this.source,
      required this.cover,
      required this.description,
      required this.status});

  String id;
  String title;
  String source;
  String cover;
  String description;
  String status;

  List<Chapter> chapters = [];
}

class Chapter {
  Chapter(
      {required this.id,
      required this.title,
      required this.uploader,
      required this.chapter,
      required this.dateUploaded,
      required this.scanlationGroup,
      required this.pages});

  final String id;
  final String title;
  final String uploader;
  final String chapter;
  final String dateUploaded;
  final String scanlationGroup;
  final int pages;
  bool isRead = false;
}

abstract class MangaSource {
  String title = 'Source';
  Future<List<Manga>> parseLatestUpdates(Future<Response> res);
  Future<Response> latestUpdatesRequest([int page = 1]);
  Future<List<Chapter>> fetchChapters(String id);
  Future<List<String>> readChapter(Chapter chapter);
}

class MangaData {}

class MangaItem extends StatelessWidget {
  const MangaItem({
    required this.manga,
    Key? key,
  }) : super(key: key);

  final Manga manga;

  @override
  Widget build(BuildContext context) {
    final tabs = context.read<TabsState>();
    final appTheme = context.read<AppTheme>();
    _checkMemory();

    return SizedBox(
        width: 180,
        height: 270,
        child: GestureDetector(
            onTap: () => tabs.openManga(manga),
            child: Column(
              children: [
                Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(borderRadius: appTheme.brOuter),
                    child: CachedNetworkImage(
                      cacheManager: GlobalImageCacheManager(),
                      cacheKey: manga.id,
                      imageUrl: manga.cover,
                      errorWidget: (context, url, error) => const SizedBox(
                          width: 180,
                          height: 270,
                          child: Center(
                            child: Icon(fui.FluentIcons.image_off_24_regular,
                                size: 16),
                          )),
                      width: 180,
                      height: 270,
                      fit: BoxFit.cover,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                    )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(manga.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 15)),
                ),
              ],
            )));
  }

  void _checkMemory() async {
    var imageCache = PaintingBinding.instance!.imageCache;
    if (imageCache!.currentSizeBytes >= 55 << 5) {
      imageCache.clear();
      imageCache.clearLiveImages();
    }
  }
}
