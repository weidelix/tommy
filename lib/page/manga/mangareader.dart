import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_compression/image_compression.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:inview_notifier_list/inview_notifier_list.dart';
// import 'package:image_picker_for_web/image_picker_for_web.dart';

import 'package:xview/page/source.dart';
import 'package:xview/theme.dart';
import 'package:xview/sources/manga_source.dart';
import 'manga.dart';

// TODO: Add compression to images
class ReaderPage extends StatefulWidget {
  const ReaderPage({required this.manga, Key? key}) : super(key: key);

  final Manga manga;

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Reader(manga: widget.manga),
      const CommandBar(),
    ]);
  }
}

class Reader extends StatefulWidget {
  const Reader({required this.manga, Key? key}) : super(key: key);

  final Manga manga;

  @override
  State<Reader> createState() => _ReaderState();
}

class _ReaderState extends State<Reader> {
  final List<CachedNetworkImage> images = [];

  @override
  void dispose() {
    _checkMemory();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final source = context.read<SourceState>();
    final mangaState = context.read<MangaState>();

    final chapter = widget.manga.chapters[mangaState.chapterIndex];
    final pages = source.sources[widget.manga.source]!.readChapter(chapter);
    return LayoutBuilder(
      builder: (context, constraints) => FutureBuilder<List<String>>(
          future: pages,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              showSnackbar(
                context,
                Snackbar(
                  content: Text(snapshot.error.toString()),
                ),
              );
            } else if (snapshot.hasData) {
              final images = snapshot.data!
                  .map((url) => CachedNetworkImage(
                        cacheKey: url,
                        imageUrl: url,
                        height: constraints.maxHeight * 0.7,
                        progressIndicatorBuilder: _loadingBuilder,
                        errorWidget: (context, url, error) =>
                            const Center(child: Text('Failed to load image')),
                        fit: BoxFit.contain,
                        fadeOutDuration: Duration.zero,
                        filterQuality: FilterQuality.medium,
                      ))
                  .toList();
              return ContinousVertical(images: images);
            }

            return const Center(child: ProgressRing());
          }),
    );
  }

  Widget _loadingBuilder(
      BuildContext context, String url, DownloadProgress loadingProgress) {
    return Center(
      child: ProgressRing(
        value: loadingProgress.progress != null
            ? loadingProgress.progress! * 100.0
            : null,
      ),
    );
  }

  void _checkMemory() {
    var imageCache = PaintingBinding.instance!.imageCache;
    if (imageCache!.currentSizeBytes >= 55 << 20) {
      imageCache.clear();
      imageCache.clearLiveImages();
    }
  }
}

class CommandBar extends StatelessWidget {
  const CommandBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mangaState = context.read<MangaState>();
    final appTheme = context.read<AppTheme>();

    const divider = Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.0),
        child: Divider(direction: Axis.vertical, size: 15));

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              borderRadius: appTheme.brOuter,
              padding: const EdgeInsets.all(4.0),
              child: Flex(direction: Axis.horizontal, children: [
                IconButton(
                    icon: const Icon(
                      fui.FluentIcons.dismiss_24_regular,
                      size: 16,
                    ),
                    onPressed: () {
                      mangaState.readerScrollOffset = 0;
                      mangaState.setRoute(routeMangaHome);
                    }),
                divider,
                IconButton(
                    icon: const Icon(
                      fui.FluentIcons.previous_24_regular,
                      size: 16,
                    ),
                    onPressed: () {}),
                IconButton(
                    icon: const Icon(
                      fui.FluentIcons.next_24_regular,
                      size: 16,
                    ),
                    onPressed: () {}),
                divider,
                IconButton(
                    icon: const Icon(
                      fui.FluentIcons.zoom_out_24_regular,
                      size: 16,
                    ),
                    onPressed: () {}),
                IconButton(
                    icon: const Icon(
                      fui.FluentIcons.zoom_in_24_regular,
                      size: 16,
                    ),
                    onPressed: () {}),
              ]),
            )
          ],
        ),
      ),
    );
  }
}

/// [Reader] layouts
class ContinousVertical extends StatefulWidget {
  const ContinousVertical({required this.images, Key? key}) : super(key: key);

  final List<CachedNetworkImage> images;

  @override
  State<ContinousVertical> createState() => _ContinousVerticalState();
}

class _ContinousVerticalState extends State<ContinousVertical> {
  final FocusNode _focusNode = FocusNode();
  bool canScale = false;
  bool isAnimatingTo = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mangaState = context.read<MangaState>();
    final controller =
        ScrollController(initialScrollOffset: mangaState.readerScrollOffset);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: LayoutBuilder(builder: (context, constraints) {
        FocusScope.of(context).requestFocus(_focusNode);
        return RawKeyboardListener(
          autofocus: true,
          focusNode: _focusNode,
          onKey: (RawKeyEvent event) {
            setState(() => canScale = event.isControlPressed);

            if (event.logicalKey == LogicalKeyboardKey.escape) {
              mangaState.setRoute(routeMangaHome);
            }

            if (!isAnimatingTo) {
              const duration = Duration(milliseconds: 150);
              const curve = Curves.easeInOut;
              final nearestUp = constraints.maxHeight *
                  ((controller.position.pixels - constraints.maxHeight) /
                          constraints.maxHeight)
                      .ceil();
              final nearestDown = constraints.maxHeight *
                  ((controller.position.pixels + constraints.maxHeight) /
                          constraints.maxHeight)
                      .floor();

              if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                isAnimatingTo = true;
                controller
                    .animateTo(nearestUp, duration: duration, curve: curve)
                    .then((value) => isAnimatingTo = false);
              } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                isAnimatingTo = true;
                controller
                    .animateTo(nearestDown, duration: duration, curve: curve)
                    .then((value) => isAnimatingTo = false);
              }
            }
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              mangaState.readerScrollOffset = notification.metrics.pixels;
              return true;
            },
            child: Scrollbar(
              controller: controller,
              child: InteractiveViewer(
                minScale: 0.2,
                maxScale: 4.0,
                scaleEnabled: canScale,
                child: ListView.builder(
                    cacheExtent: constraints.maxHeight,
                    controller: controller,
                    prototypeItem: SizedBox(
                        height: constraints.maxHeight,
                        child: const Center(child: ProgressRing())),
                    itemCount: widget.images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: widget.images[index],
                      );
                    }),
              ),
            ),
          ),
        );
      }),
    );
  }
}
