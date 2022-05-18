import 'dart:async';
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:xview/global_image_cache_manager.dart';

import 'package:xview/page/source.dart';
import 'package:xview/theme.dart';
import 'package:xview/utils.dart';
import 'manga.dart';

class ReaderPage extends StatelessWidget {
  const ReaderPage({Key? key}) : super(key: key);

  // final int chapterIndex;

  @override
  Widget build(BuildContext context) {
    return Stack(children: const [
      _Reader(),
      _CommandBar(),
    ]);
  }
}

class _Reader extends StatefulWidget {
  const _Reader({Key? key}) : super(key: key);

  @override
  State<_Reader> createState() => _ReaderState();
}

class _ReaderState extends State<_Reader> {
  final List<CachedNetworkImage> images = [];

  @override
  void dispose() async {
    checkMemory();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final source = context.read<SourceState>();
    final mangaState = context.read<MangaState>();
    final manga = mangaState.manga;

    final chapter = manga.chapters[mangaState.chapterSelected];
    final pages = source.sources[manga.source]!.readChapter(chapter);
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
              int index = 0;
              final images = snapshot.data!
                  .map((url) => StatefulBuilder(
                        builder: (context, setState) => CachedNetworkImage(
                          cacheManager: GlobalImageCacheManager(),
                          cacheKey: chapter.id + (index++).toString(),
                          imageUrl: url,
                          height: constraints.maxHeight * 0.8,
                          progressIndicatorBuilder: _loadingBuilder,
                          errorWidget: (context, url, error) => Center(
                              child: FilledButton(
                                  child: const Text('Refresh'),
                                  onPressed: () {
                                    setState(() {});
                                  })),
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                          fadeInDuration: Duration.zero,
                          fadeOutDuration: Duration.zero,
                        ),
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
            ? lerpDouble(loadingProgress.progress! * 100.0, 100.0, 0.1)
            : null,
      ),
    );
  }
}

class _CommandBar extends StatefulWidget {
  const _CommandBar({Key? key}) : super(key: key);

  @override
  State<_CommandBar> createState() => _CommandBarState();
}

class _CommandBarState extends State<_CommandBar> {
  bool showCommandBar = true;

  @override
  initState() {
    Timer(const Duration(milliseconds: 1500),
        () => setState(() => showCommandBar = false));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mangaState = context.read<MangaState>();
    final appTheme = context.read<AppTheme>();

    const divider = Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.0),
        child: Divider(direction: Axis.vertical, size: 15));

    const iconSize = 18.0;

    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: MouseRegion(
          onEnter: (_) {
            setState(() => showCommandBar = true);
          },
          onExit: (_) {
            setState(() => showCommandBar = false);
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: showCommandBar ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 100),
                  child: AnimatedSlide(
                    offset: showCommandBar ? Offset.zero : const Offset(0, 10),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    child: Card(
                      elevation: 10.0,
                      borderRadius: appTheme.brOuter,
                      padding: const EdgeInsets.all(4.0),
                      child: Flex(direction: Axis.horizontal, children: [
                        IconButton(
                            icon: const Icon(
                              fui.FluentIcons.dismiss_24_regular,
                              size: iconSize,
                            ),
                            onPressed: () {
                              mangaState.readerScrollOffset = 0;
                              mangaState.controller.animateToPage(0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                            }),
                        divider,
                        IconButton(
                            icon: const Icon(
                              fui.FluentIcons.previous_24_regular,
                              size: iconSize,
                            ),
                            onPressed: () {}),
                        IconButton(
                            icon: const Icon(
                              fui.FluentIcons.next_24_regular,
                              size: iconSize,
                            ),
                            onPressed: () {}),
                        divider,
                        IconButton(
                            icon: const Icon(
                              fui.FluentIcons.zoom_out_24_regular,
                              size: iconSize,
                            ),
                            onPressed: () {}),
                        IconButton(
                            icon: const Icon(
                              fui.FluentIcons.zoom_in_24_regular,
                              size: iconSize,
                            ),
                            onPressed: () {}),
                      ]),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// [_Reader] layouts
class ContinousVertical extends StatefulWidget {
  const ContinousVertical({required this.images, Key? key}) : super(key: key);

  final List<Widget> images;

  @override
  State<ContinousVertical> createState() => _ContinousVerticalState();
}

class _ContinousVerticalState extends State<ContinousVertical> {
  final FocusNode _focusNode = FocusNode();
  final _canScale = ValueNotifier<bool>(false);
  bool _isAnimating = false;

  @override
  void initState() {
    _focusNode.requestFocus();
    super.initState();
  }

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
    FocusScope.of(context).requestFocus();
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: LayoutBuilder(builder: (context, constraints) {
        return RawKeyboardListener(
          autofocus: true,
          focusNode: _focusNode,
          onKey: (RawKeyEvent event) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              mangaState.readerScrollOffset = 0;
              mangaState.controller.animateToPage(0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
            } else {
              _canScale.value = event.isControlPressed;
            }

            if (!_isAnimating) {
              const duration = Duration(milliseconds: 300);
              const curve = Curves.easeInOutCubicEmphasized;

              if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                final nearestUp = constraints.maxHeight *
                    ((controller.position.pixels -
                                constraints.maxHeight.ceil()) /
                            constraints.maxHeight)
                        .ceil();
                _isAnimating = true;
                controller
                    .animateTo(nearestUp, duration: duration, curve: curve)
                    .then((value) => _isAnimating = false);
              } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                final nearestDown = constraints.maxHeight *
                    ((controller.position.pixels +
                                constraints.maxHeight.ceil()) /
                            constraints.maxHeight)
                        .floor();
                _isAnimating = true;
                controller
                    .animateTo(nearestDown, duration: duration, curve: curve)
                    .then((value) => _isAnimating = false);
              }
            }
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              mangaState.readerScrollOffset = notification.metrics.pixels;
              return true;
            },
            child: ValueListenableBuilder(
              valueListenable: _canScale,
              builder: (BuildContext context, bool value, Widget? child) =>
                  InteractiveViewer(
                constrained: true,
                minScale: 0.01,
                maxScale: 4.0,
                scaleEnabled: value,
                child: Scrollbar(
                  controller: controller,
                  child: ListView.builder(
                      controller: controller,
                      prototypeItem: SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: const Center(child: ProgressRing())),
                      itemCount: widget.images.length,
                      itemBuilder: (context, index) {
                        checkMemory();
                        return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: widget.images[index]);
                      }),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
