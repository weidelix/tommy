import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:collection/collection.dart';

import 'package:xview/cache_managers/global_image_cache_manager.dart';
import 'package:xview/constants/route_names.dart';
import 'package:xview/manga_manager.dart';
import 'package:xview/routes/manga/manga_state_provider.dart';
import 'package:xview/routes/manga/widgets/tags.dart';
import 'package:xview/routes/navigation_manager.dart';
import 'package:xview/theme.dart';
import 'package:xview/sources/manga_source.dart';
import 'package:xview/sources/source_provider.dart';
import 'package:xview/utils/utils.dart';

class MangaPage extends StatefulWidget {
  const MangaPage({required this.manga, Key? key}) : super(key: key);

  final Manga manga;

  @override
  State<MangaPage> createState() => _MangaPageState();
}

class _MangaPageState extends State<MangaPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    checkMemory();
    final sources = context.read<SourceProvider>().sources;
    final appTheme = context.read<AppTheme>();
    final manga = widget.manga;
    final chapters = widget.manga.chapters;
    final controller = ScrollController();
    final palette = PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(
          widget.manga.cover,
          cacheManager: GlobalImageCacheManager(),
          cacheKey: widget.manga.url,
        ),
        size: const Size(50, 50),
        region: const Rect.fromLTRB(10, 10, 40, 40),
        maximumColorCount: 8);

    return FutureBuilder<List<dynamic>>(
      future: manga.chapters.isEmpty
          ? Future.wait([
              sources[manga.source]!.fetchChapters(manga.url),
              sources[manga.source]!.getFullMangaData(manga),
              palette
            ])
          : Future.wait([palette]),
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          NavigationManager().back();
          showSnackbar(context, Snackbar(content: Text('${snapshot.error}')),
              duration: const Duration(seconds: 5));
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
              width: double.infinity,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Fetching details...', style: appTheme.bodyStrong),
                    gapHeight(),
                    const ProgressBar()
                  ]));
        } else if (snapshot.hasData && snapshot.data!.length > 1) {
          if (chapters.length != snapshot.data![0].length) {
            chapters.addAll(snapshot.data![0]);
            chapters.sort((a, b) =>
                double.parse(b.chapter).compareTo(double.parse(a.chapter)));
          }

          manga.hasCompleteData = true;
        }

        return Mica(
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Scrollbar(
              controller: controller,
              child: ListView.builder(
                  key: const PageStorageKey('Manga'),
                  controller: controller,
                  padding: const EdgeInsets.only(bottom: 24.0),
                  itemCount: manga.chapters.length + 1,
                  itemBuilder: (context, index) => index != 0
                      ? ChapterItem(
                          manga: manga, chapter: manga.chapters[index - 1])
                      : MangaInfo(
                          manga: manga,
                          palette: snapshot.data!.length > 1
                              ? snapshot.data![2]
                              : snapshot.data![0],
                          onRefresh: refreshManga)),
            ),
          ),
        );
      },
    );
  }

  void refreshManga() {
    final sources = context.read<SourceProvider>().sources;
    final manga = widget.manga;
    final chapters = widget.manga.chapters;

    sources[manga.source]!.getFullMangaData(manga);
    sources[manga.source]!.fetchChapters(manga.url).then((value) {
      setState(() {
        for (var chapter in value) {
          if (chapters.singleWhereOrNull((c) => c.url == chapter.url) == null) {
            chapters.add(chapter);
          }
        }
        chapters.sort((a, b) =>
            double.parse(b.chapter).compareTo(double.parse(a.chapter)));
        MangaManager().save();
      });
    });
  }
}

class MangaInfo extends StatefulWidget {
  const MangaInfo(
      {required this.manga,
      required this.palette,
      required this.onRefresh,
      Key? key})
      : super(key: key);

  final Manga manga;
  final PaletteGenerator palette;
  final void Function() onRefresh;

  @override
  State<MangaInfo> createState() => _MangaInfoState();
}

class _MangaInfoState extends State<MangaInfo> {
  static const double width = 220;
  static const double height = 330;
  late Future<ImageProvider> image;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();
    final theme = FluentTheme.of(context);
    final bgColor = theme.micaBackgroundColor;
    Chapter? lastRead = widget.manga.chapters
        .firstWhereOrNull((element) => element.url == widget.manga.lastRead);

    return Column(
      children: [
        Stack(children: [
          SizedBox(
            width: double.infinity,
            height: 600,
            child: CachedNetworkImage(
                cacheManager: GlobalImageCacheManager(),
                cacheKey: widget.manga.url,
                imageUrl: widget.manga.cover,
                alignment: const Alignment(0.5, -0.6),
                fit: BoxFit.cover,
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
                filterQuality: FilterQuality.high),
          ),
          Container(
            width: double.infinity,
            height: 600,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [
                  0.5,
                  0.8,
                  1.0,
                ],
                    colors: [
                  bgColor.withOpacity(0),
                  bgColor,
                  bgColor
                ])),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 250.0, top: 380.0, right: 250.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      alignment: Alignment.topLeft,
                      width: width,
                      height: height,
                      decoration: BoxDecoration(borderRadius: appTheme.brOuter),
                      clipBehavior: Clip.antiAlias,
                      child: GestureDetector(
                        onSecondaryTap: () {
                          showDialog(
                              context: context,
                              builder: (context) => ContentDialog(
                                    title: Text(
                                      'Cover',
                                      style: appTheme.subtitle,
                                    ),
                                    content: Wrap(runSpacing: 8.0, children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Save image'),
                                            IconButton(
                                                icon: const Icon(
                                                  fui.FluentIcons
                                                      .arrow_download_16_regular,
                                                  size: 18,
                                                ),
                                                onPressed: () {})
                                          ]),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Share'),
                                            IconButton(
                                                icon: const Icon(
                                                  fui.FluentIcons
                                                      .share_16_regular,
                                                  size: 18,
                                                ),
                                                onPressed: () {})
                                          ])
                                    ]),
                                    actions: [
                                      Button(
                                          child: const Text('Cancel'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          }),
                                    ],
                                  ));
                        },
                        child: CachedNetworkImage(
                          cacheManager: GlobalImageCacheManager(),
                          cacheKey: widget.manga.url,
                          imageUrl: widget.manga.cover,
                          width: width,
                          height: height,
                          fit: BoxFit.cover,
                          fadeInDuration: Duration.zero,
                          fadeOutDuration: Duration.zero,
                        ),
                      ),
                    ),
                    gapWidth(32.0),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(minHeight: height),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.manga.title,
                                  style: appTheme.titleLarge,
                                ),
                                gapHeight(8.0),
                                Row(children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(widget.manga.authors ?? 'Author(s)',
                                          style: appTheme.caption),
                                      Text(
                                        '${widget.manga.source} • ${widget.manga.status}',
                                        style: appTheme.caption,
                                      ),
                                    ],
                                  ),
                                ]),
                                gapHeight(32.0),
                                Wrap(
                                  direction: Axis.horizontal,
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: widget.manga.tags
                                      .map((e) => buildTag(context, e))
                                      .toList(),
                                ),
                                gapHeight(32.0),
                                Text(_getMinDscription() ?? 'Unknown',
                                    style: appTheme.body),
                                gapHeight(32.0),
                              ],
                            ),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                      height: 50,
                                      width: 230,
                                      child: _addToLibraryButton(context)),
                                  gapWidth(),
                                  Row(
                                    children: [
                                      IconButton(
                                          icon: const Icon(
                                              fui.FluentIcons.play_24_regular,
                                              size: 16),
                                          onPressed: () {
                                            if (widget.manga.lastRead == null) {
                                              NavigationManager().push(
                                                  routeMangaRead,
                                                  MangaReaderState(
                                                      manga: widget.manga,
                                                      chapter: lastRead!));
                                            } else {
                                              NavigationManager().push(
                                                  routeMangaRead,
                                                  MangaReaderState(
                                                      manga: widget.manga,
                                                      chapter: lastRead!));
                                            }
                                          }),
                                      gapWidth(8.0),
                                      IconButton(
                                          icon: const Icon(
                                              fui.FluentIcons
                                                  .arrow_clockwise_24_regular,
                                              size: 16),
                                          onPressed: widget.onRefresh),
                                      gapWidth(8.0),
                                      IconButton(
                                          icon: const Icon(
                                              fui.FluentIcons.share_24_regular,
                                              size: 16),
                                          onPressed: () {}),
                                    ],
                                  ),
                                ]),
                          ],
                        ),
                      ),
                    ),
                  ]),
                  gapHeight(32.0),
                  Description(
                      description: widget.manga.description ?? 'Unknown'),
                ],
              ),
            ),
          ),
        ]),
        gapHeight(32.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 250.0),
          child: Mica(
            borderRadius: BorderRadius.only(
                topLeft: appTheme.brOuter.topLeft,
                topRight: appTheme.brOuter.topRight),
            child: Column(
              children: [
                Card(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${widget.manga.chapters.length} Chapter${widget.manga.chapters.length == 1 ? '' : 's'}',
                            style: appTheme.bodyStrong
                                .apply(fontSizeFactor: 1.15)),
                        IconButton(
                            icon: const Icon(
                              fui.FluentIcons.arrow_sort_24_regular,
                              size: 16,
                            ),
                            onPressed: () {}),
                      ],
                    )),
                const Divider(size: double.infinity)
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _addToLibraryButton(BuildContext context) {
    final appTheme = context.read<AppTheme>();
    final palette = widget.palette;
    final color = (FluentTheme.of(context).brightness == Brightness.dark
            ? palette.lightVibrantColor ?? palette.lightMutedColor
            : palette.darkVibrantColor ?? palette.darkMutedColor) ??
        palette.vibrantColor ??
        palette.dominantColor;

    return FilledButton(
        style: ButtonStyle(
            foregroundColor:
                ButtonState.all(color!.titleTextColor.withOpacity(1.0)),
            backgroundColor: ButtonState.resolveWith((states) =>
                FilledButton.backgroundColor(
                    ThemeData(accentColor: color.color.toAccentColor()),
                    states))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: SizedBox(
              width: 230,
              child: Text(
                !widget.manga.inLibrary
                    ? 'Add to library'
                    : 'Remove from library',
                textAlign: TextAlign.left,
                style: appTheme.bodyStrong,
              ),
            ),
          ),
        ),
        onPressed: () {
          setState(() {
            if (!widget.manga.inLibrary) {
              widget.manga.inLibrary = true;
              MangaManager().addManga(widget.manga);
            } else {
              widget.manga.inLibrary = false;
              MangaManager().removeManga(widget.manga);
            }

            MangaManager().save();
          });
        });
  }

  String? _getMinDscription() {
    String? desc = widget.manga.description;
    int? i = desc?.indexOf(RegExp(r'[.?!]'));

    return desc?.substring(0, i! + 1);
  }
}

class ChapterItem extends StatefulWidget {
  const ChapterItem({required this.manga, required this.chapter, Key? key})
      : super(key: key);

  final Manga manga;
  final Chapter chapter;

  @override
  State<ChapterItem> createState() => _ChapterItemState();
}

class _ChapterItemState extends State<ChapterItem> {
  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();

    return Opacity(
      opacity: widget.chapter.read ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 250.0),
        child: SizedBox(
          height: 70.0,
          child: Button(
            style: ButtonStyle(
              backgroundColor: ButtonState.resolveWith(_resolveButtonColor),
              padding: ButtonState.all(const EdgeInsets.all(16.0)),
              border: ButtonState.all(BorderSide.none),
              shape: ButtonState.all(const BeveledRectangleBorder()),
            ),
            onPressed: () {
              NavigationManager().push(
                  routeMangaRead,
                  MangaReaderState(
                      manga: widget.manga, chapter: widget.chapter));
              widget.manga.lastRead = widget.chapter.url;

              // Crude checking whether chapter is read
              if (!widget.chapter.read) {
                setState(() {
                  widget.chapter.read = true;
                  MangaManager().save();
                });
              }
            },
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.chapter.chapter != '-1'
                          ? 'Chapter ${widget.chapter.chapter} ${widget.chapter.title != '' ? '- ${widget.chapter.title}' : ''}'
                          : 'Oneshot',
                      textAlign: TextAlign.left,
                      style: appTheme.body,
                    ),
                    Opacity(
                      opacity: 0.7,
                      child: Text(
                        '${widget.chapter.dateUploaded} • ${widget.chapter.scanlationGroup ?? 'Unknown'}',
                        style: appTheme.caption,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _resolveButtonColor(Set<ButtonStates> states) {
    final theme = FluentTheme.of(context);
    final color = theme.cardColor.toAccentColor();

    if (states.isDisabled) {
      if (theme.brightness.isDark) {
        return const Color(0xFF434343);
      } else {
        return const Color(0xFFBFBFBF);
      }
    } else if (states.isPressing) {
      if (theme.brightness.isDark) {
        return color.dark;
      } else {
        return color.light;
      }
    } else if (states.isHovering) {
      if (theme.brightness.isDark) {
        return color.light;
      } else {
        return color.dark;
      }
    }

    return color;
  }
}

class Description extends StatefulWidget {
  const Description({
    Key? key,
    required this.description,
  }) : super(key: key);

  final String description;

  @override
  State<Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<Description> {
  bool tap = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme appTheme = context.read<AppTheme>();

    final minDesc = Text(
      widget.description,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    final maxDesc = Text(
      widget.description,
      style: appTheme.body,
    );

    return Card(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Description',
              style: appTheme.bodyStrong.apply(fontSizeFactor: 1.15),
            ),
          ),
          gapHeight(),
          const Divider(size: double.infinity),
          gapHeight(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
                onTap: () {
                  setState(() {
                    tap = !tap;
                  });
                },
                child: AnimatedCrossFade(
                    sizeCurve: Curves.easeInOut,
                    firstCurve: Curves.easeIn,
                    secondCurve: Curves.easeOut,
                    crossFadeState: !tap
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 200),
                    firstChild: minDesc,
                    secondChild: maxDesc)),
          ),
          gapHeight(),
          !tap
              ? const Center(child: Icon(FluentIcons.chevron_down, size: 10))
              : const Center(child: Icon(FluentIcons.chevron_up, size: 10))
        ],
      ),
    );
  }
}
