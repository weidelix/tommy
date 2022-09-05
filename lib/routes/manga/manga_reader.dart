import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:xview/cache_managers/global_image_cache_manager.dart';
import 'package:xview/routes/manga/reader_layouts/vertical_reader.dart';
import 'package:xview/routes/manga/widgets/reader_command_bar.dart';
import 'package:xview/routes/navigation_manager.dart';
import 'package:xview/sources/manga_source.dart';
import 'package:xview/sources/source_provider.dart';
import 'package:xview/utils/utils.dart';

class MangaReaderPage extends StatelessWidget {
  const MangaReaderPage({required this.chapter, Key? key}) : super(key: key);

  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    return _Reader(chapter: chapter);
  }
}

class _Reader extends StatefulWidget {
  const _Reader({required this.chapter, Key? key}) : super(key: key);

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
    final chapter = widget.chapter;
    final pages = source.sources[chapter.source]!.readChapter(chapter);

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
                              url: url,
                              cacheKey: chapter.id + (index++).toString()))
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
          ReaderCommandBar(onZoomIn: _onZoomIn, onZoomOut: _onZoomOut)
        ]));
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

      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        final nearestUp = _constraints.maxHeight *
            ((_controller.position.pixels - _constraints.maxHeight.ceil()) /
                    _constraints.maxHeight)
                .ceil();
        _isAnimating = true;
        _controller
            .animateTo(nearestUp, duration: duration, curve: curve)
            .then((value) => _isAnimating = false);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        final nearestDown = _constraints.maxHeight *
            ((_controller.position.pixels + _constraints.maxHeight.ceil()) /
                    _constraints.maxHeight)
                .floor();
        _isAnimating = true;
        _controller
            .animateTo(nearestDown, duration: duration, curve: curve)
            .then((value) => _isAnimating = false);
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

class Page extends StatelessWidget {
  const Page({required this.url, required this.cacheKey, Key? key})
      : super(key: key);

  final String url;
  final String cacheKey;

  @override
  Widget build(BuildContext context) {
    return _buildImageWidget();
  }

  Widget _loadingBuilder(
      BuildContext context, String url, DownloadProgress download) {
    double? progress = download.progress;

    return Center(
      child: ProgressRing(
        value: progress != null ? progress * 100.0 : progress,
      ),
    );
  }

  CachedNetworkImage _buildImageWidget() {
    return CachedNetworkImage(
      cacheManager: GlobalImageCacheManager(),
      cacheKey: cacheKey,
      imageUrl: url,
      progressIndicatorBuilder: _loadingBuilder,
      errorWidget: (context, url, error) => Center(
          child: FilledButton(child: const Text('Refresh'), onPressed: () {})),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
    );
  }
}
