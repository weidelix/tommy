import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:xview/cache_managers/global_image_cache_manager.dart';
import 'package:xview/routes/manga/manga_state_provider.dart';
import 'package:xview/routes/manga/reader_layouts/vertical_reader.dart';
import 'package:xview/routes/manga/widgets/reader_command_bar.dart';
import 'package:xview/routes/navigation_manager.dart';
import 'package:xview/sources/manga_source.dart';
import 'package:xview/sources/source_provider.dart';
import 'package:xview/utils/utils.dart';

class MangaReaderPage extends StatelessWidget {
  const MangaReaderPage({required this.readerState, Key? key})
      : super(key: key);

  final MangaReaderState readerState;

  @override
  Widget build(BuildContext context) {
    return _Reader(manga: readerState.manga, chapter: readerState.chapter);
  }
}

class _Reader extends StatefulWidget {
  const _Reader({required this.manga, required this.chapter, Key? key})
      : super(key: key);

  final Manga manga;
  final Chapter chapter;

  @override
  State<_Reader> createState() => _ReaderState();
}

class _ReaderState extends State<_Reader> {
  final _controller = ScrollController();
  final _tranController = TransformationController();
  final FocusNode _focusNode =
      FocusNode(onKey: (_, __) => KeyEventResult.handled);

  bool _canScale = false;
  bool _isAnimating = false;
  var _prevMatrix = Matrix4.identity();
  BoxConstraints _constraints = const BoxConstraints();
  late Chapter _currentChapter;

  @override
  void initState() {
    _currentChapter = widget.chapter;
    super.initState();
  }

  @override
  void dispose() async {
    checkMemory();
    _focusNode.requestFocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus();
    final source = context.read<SourceProvider>();
    final pages =
        source.sources[widget.manga.source]!.readChapter(_currentChapter);
    return RawKeyboardListener(
        autofocus: true,
        focusNode: _focusNode,
        onKey: _handleKeyEvent,
        child: Stack(children: [
          LayoutBuilder(
              builder: (context, constraints) => FutureBuilder<List<String>>(
                  future: pages,
                  builder: (context, snapshot) {
                    _constraints = constraints;
                    if (snapshot.hasError && !NavigationManager().didPop) {
                      Future.delayed(const Duration(seconds: 1))
                          .whenComplete(() {
                        NavigationManager().back();
                        showInfoBar(context, snapshot.error.toString());
                      });
                    } else if (snapshot.hasData) {
                      final images = snapshot.data!
                          .map((url) => StatefulBuilder(
                                builder: (context, setState) => Page(
                                    key: ValueKey(Random().nextInt(9999)),
                                    onError: () {
                                      setState(() {});
                                    },
                                    url: url),
                              ))
                          .toList();
                      return Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Scrollbar(
                            controller: _controller,
                            child: InteractiveViewer(
                                onInteractionUpdate: _handleScaleAndPanning,
                                transformationController: _tranController,
                                maxScale: 4.0,
                                panEnabled: false,
                                scaleEnabled: true,
                                child: VerticalReader(
                                    images: images,
                                    constraints: constraints,
                                    controller: _controller)),
                          ));
                    }
                    return const Center(child: ProgressRing());
                  })),
          ReaderCommandBar(
              onNextChapter: _onNextChapter,
              onPreviousChapter: _onPreviousChapter,
              onZoomIn: _onZoomIn,
              onZoomOut: _onZoomOut)
        ]));
  }

  void _onNextChapter() {
    int index = widget.manga.chapters.indexOf(_currentChapter);

    if (index - 1 >= 0) {
      setState(() {
        _currentChapter = widget.manga.chapters[index - 1];
        _currentChapter.read = true;
      });
      _controller.jumpTo(0);
    } else {
      showInfoBar(context, 'No next chapter');
    }
  }

  void _onPreviousChapter() {
    int index = widget.manga.chapters.indexOf(_currentChapter);

    if (index + 1 < widget.manga.chapters.length) {
      setState(() {
        _currentChapter = widget.manga.chapters[index + 1];
        _currentChapter.read = true;
      });
      _controller.jumpTo(0);
    } else {
      showInfoBar(context, 'No previous chapter');
    }
  }

  void _onZoomIn() {
    final scale = _tranController.value.getMaxScaleOnAxis();
    _tranController.value = Matrix4.identity()..scale(scale + 0.3);
    _prevMatrix = _tranController.value;
  }

  void _onZoomOut() {
    final scale = _tranController.value.getMaxScaleOnAxis();
    _tranController.value = Matrix4.identity()..scale(scale - 0.3);

    if (_tranController.value.getMaxScaleOnAxis() < 1.0) {
      _tranController.value = Matrix4.identity();
    }

    _prevMatrix = _tranController.value;
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      NavigationManager().back();
    } else {
      _canScale = event.isControlPressed;
    }

    if (!_isAnimating) {
      const duration = Duration(milliseconds: 300);
      const curve = Curves.easeInOutCubicEmphasized;

      if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
        final nearestUp = _constraints.maxHeight *
            ((_controller.position.pixels - _constraints.maxHeight.ceil()) /
                    _constraints.maxHeight)
                .ceil();
        _isAnimating = true;
        _controller
            .animateTo(nearestUp, duration: duration, curve: curve)
            .then((value) => _isAnimating = false);
      } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
        final nearestDown = _constraints.maxHeight *
            ((_controller.position.pixels + _constraints.maxHeight.ceil()) /
                    _constraints.maxHeight)
                .floor();
        _isAnimating = true;
        _controller
            .animateTo(nearestDown, duration: duration, curve: curve)
            .then((value) => _isAnimating = false);
      } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
        _onPreviousChapter();
      } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
        _onNextChapter();
      }
    }
  }

  void _handleScaleAndPanning(ScaleUpdateDetails details) {
    _focusNode.requestFocus();

    final scale = _tranController.value.getMaxScaleOnAxis();
    final sens = (scale - 5.5) / (1.0 - 5.5);

    if (!_canScale) {
      _tranController.value = _prevMatrix;
    }

    if (scale > 1.0) {
      final newMatrix = Matrix4.copy(_tranController.value);

      _tranController.value = newMatrix
        ..translate(details.focalPointDelta.dx * sens);

      _controller.jumpTo(
          (_controller.position.pixels - details.focalPointDelta.dy * sens));
    } else {
      _controller
          .jumpTo(_controller.position.pixels - details.focalPointDelta.dy);
    }

    _prevMatrix = _tranController.value;
  }
}

class Page extends StatefulWidget {
  const Page({required this.url, required this.onError, Key? key})
      : super(key: key);

  final String url;
  final void Function() onError;

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  late double? currProgress = 0;
  late double? progress = 0;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (context, setState) => _buildImageWidget(setState));
  }

  Widget _loadingBuilder(
      BuildContext context, String url, DownloadProgress download) {
    double? prevProgress = progress;

    if (download.progress != null) {
      progress = (download.progress! * 100.0);
    }

    return TweenAnimationBuilder<double?>(
        tween: Tween<double?>(begin: prevProgress, end: progress),
        curve: Curves.ease,
        duration: const Duration(milliseconds: 100),
        builder: (context, value, child) {
          return Center(
            child: ProgressRing(
              value: value,
            ),
          );
        });
  }

  CachedNetworkImage _buildImageWidget(
      void Function(void Function()) setState) {
    return CachedNetworkImage(
      cacheManager: GlobalImageCacheManager(),
      cacheKey: widget.url,
      imageUrl: widget.url,
      progressIndicatorBuilder: _loadingBuilder,
      errorWidget: (context, url, error) {
        return Center(
            child: FilledButton(
                onPressed: widget.onError, child: const Text('Refresh')));
      },
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
    );
  }
}
