import 'package:ellipsis_overflow_text/ellipsis_overflow_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:image_compression_flutter/image_compression_flutter.dart';

import 'package:xview/cache_managers/global_image_cache_manager.dart';
import 'package:xview/constants/route_names.dart';
import 'package:xview/routes/navigation_manager.dart';
import 'package:xview/sources/manga_source.dart';
import 'package:xview/theme.dart';
import 'package:xview/utils/utils.dart';

class MangaItem extends StatefulWidget {
  const MangaItem({
    required this.manga,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final Manga manga;
  final void Function() onPressed;

  @override
  State<MangaItem> createState() => _MangaItemState();
}

class _MangaItemState extends State<MangaItem> {
  static const width = 250.0;
  static const height = 225.0;
  static const imageAspectRatio = (height) / (width);
  ImageFile? compressedImage;
  bool isHovering = false;
  bool processing = false;

  @override
  void initState() {
    super.initState();
    _compressImage();
  }

  @override
  Widget build(BuildContext context) {
    checkMemory();
    final appTheme = context.read<AppTheme>();

    bool notInLibrary = (widget.manga.inLibrary &&
        NavigationManager().currentRoute == routeBrowseSource);

    return GestureDetector(
      onTap: widget.onPressed,
      child: MouseRegion(
        onEnter: (onEnter) => setState(() => isHovering = true),
        onExit: (onExit) => setState(() => isHovering = false),
        child: Tooltip(
          message: widget.manga.title,
          useMousePosition: true,
          child: Stack(children: [
            SizedBox(
              width: width,
              height: height + 40,
              child: AnimatedOpacity(
                opacity: isHovering || notInLibrary
                    ? isHovering && notInLibrary
                        ? 0.5
                        : 0.7
                    : 1,
                duration: const Duration(milliseconds: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                      width: width,
                      height: (width) * imageAspectRatio,
                      fit: BoxFit.cover,
                      cacheManager: GlobalImageCacheManager(),
                      cacheKey: widget.manga.url,
                      imageUrl: widget.manga.cover,
                      imageBuilder: (context, imageProvider) => ClipRRect(
                        borderRadius: appTheme.brInner,
                        child: Image(image: imageProvider, fit: BoxFit.cover),
                      ),
                      errorWidget: (context, url, error) => const Mica(
                        child: SizedBox(
                            width: 180,
                            height: 270,
                            child: Center(
                              child: Icon(fui.FluentIcons.image_off_24_regular,
                                  size: 20),
                            )),
                      ),
                    ),
                    EllipsisOverflowText(widget.manga.title,
                        maxLines: 2,
                        showEllipsisOnBreakLineOverflow: true,
                        style: appTheme.bodyStrong),
                  ],
                ),
              ),
            ),
            notInLibrary
                ? Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                        decoration: BoxDecoration(
                            color: appTheme.accentColorPrimary,
                            borderRadius: appTheme.brInner),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 2.0),
                          child: Text("In Library",
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold)),
                        )),
                  )
                : const SizedBox.shrink(),
          ]),
        ),
      ),
    );
  }

  Future<void> _compressImage() async {
    FileInfo? fi =
        await GlobalImageCacheManager().getFileFromCache(widget.manga.url);

    if (fi == null) {
      final res = get(Uri.parse(widget.manga.cover));
      ImageFile image =
          ImageFile(filePath: "", rawBytes: (await res).bodyBytes);

      compressedImage = await compressor.compressJpg(ImageFileConfiguration(
          input: image, config: const Configuration(quality: 80)));

      GlobalImageCacheManager().putFile(
          widget.manga.cover, compressedImage!.rawBytes,
          key: widget.manga.url);
    }
  }
}
