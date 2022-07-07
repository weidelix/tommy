import 'dart:async';
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:cached_network_image/cached_network_image.dart';

import 'package:xview/cache_managers/global_image_cache_manager.dart';
import 'package:xview/routes/manga/manga_state_provider.dart';
import 'package:xview/sources/manga_source.dart';
import 'package:xview/sources/source_provider.dart';
import 'package:xview/theme.dart';
import 'package:xview/utils/utils.dart';

class ReaderPage extends StatelessWidget {
  const ReaderPage({Key? key}) : super(key: key);

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
    final source = context.read<SourceProvider>();
    final mangaState = context.read<MangaStateProvider>();
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
                  .map((url) => Page(
                      url: url, cacheKey: chapter.id + (index++).toString()))
                  .toList();
              return ContinousVertical(images: images);
            }

            return const Center(child: ProgressRing());
          }),
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
    final mangaState = context.read<MangaStateProvider>();
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
            padding: const EdgeInsets.only(bottom: 16.0, top: 36.0),
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
  final FocusNode _focusNode =
      FocusNode(onKey: (_, __) => KeyEventResult.handled);
  final _canScale = ValueNotifier<bool>(false);
  final _tranController = TransformationController();
  bool _isAnimating = false;

  @override
  void initState() {
    _focusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _tranController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mangaState = context.read<MangaStateProvider>();
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
                onInteractionUpdate: (ScaleUpdateDetails details) {
                  _focusNode.requestFocus();
                  final scale = _tranController.value.getMaxScaleOnAxis();
                  final sens = (scale - 5.5) / (1.0 - 5.5);

                  if (scale > 1.0) {
                    final newMatrix = Matrix4.copy(_tranController.value);
                    newMatrix.translate(details.focalPointDelta.dx * sens);
                    _tranController.value = newMatrix;

                    controller.jumpTo((controller.position.pixels -
                        details.focalPointDelta.dy * sens));
                  } else {
                    controller.jumpTo(controller.position.pixels -
                        details.focalPointDelta.dy);
                  }
                },
                transformationController: _tranController,
                maxScale: 4.0,
                panEnabled: false,
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

class Page extends StatefulWidget {
  const Page({required this.url, required this.cacheKey, Key? key})
      : super(key: key);

  // final Chapter chapter;
  final String url;
  final String cacheKey;

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  @override
  void initState() {
    super.initState();
  }

  int count = 0;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      cacheManager: GlobalImageCacheManager(),
      cacheKey: widget.cacheKey,
      imageUrl: widget.url,
      progressIndicatorBuilder: _loadingBuilder,
      errorWidget: (context, url, error) => Center(
          child: FilledButton(child: const Text('Refresh'), onPressed: () {})),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
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
}
