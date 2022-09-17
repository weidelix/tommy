import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:collection/collection.dart';

import 'package:xview/cache_managers/global_image_cache_manager.dart';
import 'package:xview/constants/route_names.dart';
import 'package:xview/routes/manga/manga_state_provider.dart';
import 'package:xview/routes/manga/widgets/tags.dart';
import 'package:xview/routes/navigation_manager.dart';
import 'package:xview/theme.dart';
import 'package:xview/sources/manga_source.dart';
import 'package:xview/sources/source_provider.dart';

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
    final source = context.read<SourceProvider>();
    final manga = widget.manga;
    final appTheme = context.read<AppTheme>();

    final controller = ScrollController();

    return FutureBuilder<List<dynamic>>(
        future: manga.chapters.isEmpty && !manga.hasCompleteData
            ? Future.wait([
                source.sources[manga.source]!.fetchChapters(manga.id),
                source.sources[manga.source]!.getFullMangaData(manga)
              ])
            : null,
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            NavigationManager().back();
            showSnackbar(
                context,
                Snackbar(
                  content: Text(snapshot.error.toString()),
                ),
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
          } else if (snapshot.hasData) {
            if (manga.chapters.length !=
                (snapshot.data![0] as List<Chapter>).length) {
              manga.chapters.addAll((snapshot.data![0] as List<Chapter>));

              manga.chapters.sort((a, b) =>
                  double.parse(b.chapter).compareTo(double.parse(a.chapter)));
            }

            manga.hasCompleteData = true;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Scrollbar(
              controller: controller,
              child: ListView.builder(
                  key: const PageStorageKey('Manga'),
                  controller: controller,
                  padding: const EdgeInsets.only(bottom: 24.0),
                  itemCount: manga.chapters.length + 1,
                  itemBuilder: (context, index) {
                    if (index != 0) {
                      int i = index - 1;
                      return ChapterItem(
                          manga: manga, chapter: manga.chapters[i]);
                    } else {
                      return MangaInfo(manga: manga);
                    }
                  }),
            ),
          );
        });
  }
}

class MangaInfo extends StatefulWidget {
  const MangaInfo({required this.manga, Key? key}) : super(key: key);

  final Manga manga;

  @override
  State<MangaInfo> createState() => _MangaInfoState();
}

class _MangaInfoState extends State<MangaInfo> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();
    final bgColor = FluentTheme.of(context).micaBackgroundColor;
    Chapter? lastRead = widget.manga.chapters
        .firstWhereOrNull((element) => element.id == widget.manga.lastRead);

    return Column(
      children: [
        Stack(children: [
          SizedBox(
            width: double.infinity,
            height: 500,
            child: CachedNetworkImage(
              cacheManager: GlobalImageCacheManager(),
              cacheKey: widget.manga.id,
              imageUrl: widget.manga.cover,
              alignment: const Alignment(0.5, -0.6),
              fit: BoxFit.cover,
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              filterQuality: FilterQuality.high,
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              width: double.infinity,
              height: 515,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [
                    0.0,
                    0.6,
                    0.9,
                    1.0,
                  ],
                      colors: [
                    bgColor.withAlpha(0),
                    bgColor.withAlpha(100),
                    bgColor,
                    bgColor
                  ])),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 200.0, top: 380.0, right: 200.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    alignment: Alignment.topLeft,
                    width: 210,
                    height: 315,
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
                        cacheKey: widget.manga.id,
                        imageUrl: widget.manga.cover,
                        width: 210,
                        height: 315,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                      ),
                    ),
                  ),
                  gapWidth(32.0),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 315),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: 600,
                                  child: Text(
                                    widget.manga.title,
                                    style: appTheme.titleLarge,
                                  )),
                              gapHeight(8.0),
                              Row(children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 600,
                                      child: Text(
                                          widget.manga.authors ?? 'Author(s)',
                                          style: appTheme.caption),
                                    ),
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
                              Text(
                                  widget.manga.description?.substring(
                                          0,
                                          widget.manga.description!
                                                  .indexOf('.') +
                                              1) ??
                                      'Unknown',
                                  style: appTheme.body),
                              gapHeight(32.0),
                            ],
                          ),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: FilledButton(
                                      child: const Text(
                                        'Add to library',
                                      ),
                                      onPressed: () {}),
                                ),
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
                                        onPressed: () {}),
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
                Description(description: widget.manga.description ?? 'Unknown'),
              ],
            ),
          ),
        ]),
        gapHeight(32.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 200.0),
          child: Mica(
            borderRadius: BorderRadius.only(
                topLeft: appTheme.brOuter.topLeft,
                topRight: appTheme.brOuter.topRight),
            backgroundColor:
                FluentTheme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : const Color(0xFF2b2b2b),
            child: Column(
              children: [
                Padding(
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
      opacity: widget.chapter.isRead ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 200.0),
        child: SizedBox(
          height: 70.0,
          child: Button(
            style: ButtonStyle(
              padding: ButtonState.all(const EdgeInsets.all(16.0)),
              border: ButtonState.all(BorderSide.none),
              shape: ButtonState.all(const BeveledRectangleBorder()),
            ),
            onPressed: () {
              NavigationManager().push(
                  routeMangaRead,
                  MangaReaderState(
                      manga: widget.manga, chapter: widget.chapter));
              widget.manga.lastRead = widget.chapter.id;

              // Crude checking whether chapter is read
              if (!widget.chapter.isRead) {
                setState(() {
                  widget.chapter.isRead = true;
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
                          ? 'Chapter ${widget.chapter.chapter} ${widget.chapter.title != '' ? '- ' + widget.chapter.title : ''}'
                          : 'Oneshot',
                      textAlign: TextAlign.left,
                      style: appTheme.body,
                    ),
                    Opacity(
                      opacity: 0.7,
                      child: Text(
                        '${widget.chapter.dateUploaded} • ${widget.chapter.scanlationGroup}',
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

    return Mica(
      borderRadius: appTheme.brOuter,
      backgroundColor: FluentTheme.of(context).brightness == Brightness.light
          ? Colors.white
          : const Color(0xFF2b2b2b),
      child: Padding(
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
      ),
    );
  }
}
