import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;

import 'package:xview/constants/route_names.dart';
import 'package:xview/routes/navigation_manager.dart';
import 'package:xview/cache_managers/global_image_cache_manager.dart';
import 'package:xview/sources/manga_source.dart';
import 'package:xview/theme.dart';
import 'package:xview/utils/utils.dart';
import 'package:xview/sources/source_provider.dart';

class SourcePage extends StatefulWidget {
  const SourcePage({Key? key}) : super(key: key);

  @override
  State<SourcePage> createState() => _SourcePageState();
}

class _SourcePageState extends State<SourcePage> {
  final controller = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    checkMemory();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final source = context.read<SourceProvider>();
    final appTheme = context.read<AppTheme>();

    return WillPopScope(
      onWillPop: () async {
        source.reset();
        checkMemory();
        return true;
      },
      child: NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (notification) {
          WidgetsBinding.instance.addPostFrameCallback(_checkIfCanScroll);
          return true;
        },
        child: SizeChangedLayoutNotifier(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              source.scrollOffset = notification.metrics.pixels;

              if (notification.metrics.maxScrollExtent ==
                  notification.metrics.pixels) {
                if (source.isFinishedLoading) {
                  showSnackbar(
                      context,
                      SizedBox(
                        width: 120,
                        child: Mica(
                            borderRadius: appTheme.brOuter,
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Loading',
                                    style: appTheme.bodyStrong,
                                  ),
                                  gapWidth(8.0),
                                  const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: ProgressRing(strokeWidth: 2.5))
                                ],
                              ),
                            )),
                      ));
                  source.fetchLatestData().whenComplete(() => setState(() {}));
                }
              }
              return true;
            },
            child: FutureBuilder(
              future: source.latest.isEmpty ? source.fetchLatestData() : null,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        snapshot.error.toString(),
                        style: appTheme.bodyStrong,
                      ),
                      gapHeight(32),
                      IconButton(
                          icon: const Icon(
                            fui.FluentIcons.arrow_clockwise_24_regular,
                            size: 24,
                          ),
                          onPressed: () {
                            setState(() {
                              source.reset();
                            });
                          }),
                      Text(
                        'Refresh',
                        style: appTheme.caption,
                      )
                    ],
                  ));
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return WillPopScope(
                    child: const Center(child: ProgressRing()),
                    onWillPop: () async {
                      source.reset();
                      return true;
                    },
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback(_checkIfCanScroll);
                return GridView.builder(
                    padding: const EdgeInsets.only(right: 4.0),
                    controller: controller,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                            childAspectRatio: 176.0 / 300.0,
                            mainAxisSpacing: 24.0,
                            crossAxisSpacing: 16.0,
                            maxCrossAxisExtent: 176.0),
                    itemCount: source.latest.length,
                    itemBuilder: (context, count) =>
                        MangaItem(manga: source.latest[count]));
              },
            ),
          ),
        ),
      ),
    );
  }

  void _checkIfCanScroll(Duration timestamp) {
    if (controller.position.maxScrollExtent <= 0) {
      final source = context.read<SourceProvider>();
      source.fetchLatestData().whenComplete(() => setState(() {
            WidgetsBinding.instance.addPostFrameCallback(_checkIfCanScroll);
          }));
    }
  }
}

class MangaItem extends StatefulWidget {
  const MangaItem({
    required this.manga,
    Key? key,
  }) : super(key: key);

  final Manga manga;

  @override
  State<MangaItem> createState() => _MangaItemState();
}

class _MangaItemState extends State<MangaItem> {
  static const height = 300.0;
  static const width = 176.0;
  static const imageAspectRatio = 250 / width;
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    checkMemory();
    final hover = Matrix4.identity()..translate(0.0, -3.00);
    final appTheme = context.read<AppTheme>();
    final theme = FluentTheme.of(context);

    return GestureDetector(
      onTap: () => NavigationManager().push(routeManga, widget.manga),
      child: MouseRegion(
        onEnter: (onEnter) => setState(() => isHovering = true),
        onExit: (onExit) => setState(() => isHovering = false),
        child: Tooltip(
          message: widget.manga.title,
          useMousePosition: true,
          child: AnimatedContainer(
            transform: isHovering ? hover : Matrix4.identity(),
            duration: const Duration(milliseconds: 80),
            width: width,
            height: height,
            child: Card(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedNetworkImage(
                    width: width - 24,
                    height: (width - 24) * imageAspectRatio,
                    fit: BoxFit.cover,
                    cacheManager: GlobalImageCacheManager(),
                    cacheKey: widget.manga.id,
                    imageUrl: widget.manga.cover,
                    errorWidget: (context, url, error) => const Mica(
                      child: SizedBox(
                          width: 180,
                          height: 300,
                          child: Center(
                            child: Icon(fui.FluentIcons.image_off_24_regular,
                                size: 20),
                          )),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.manga.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: appTheme.bodyStrong),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
