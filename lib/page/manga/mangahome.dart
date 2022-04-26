import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:xview/page/source.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;

import 'package:xview/theme.dart';
import 'package:xview/sources/manga_source.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'manga.dart';

class MangaHomePage extends StatefulWidget {
  const MangaHomePage({required this.manga, Key? key}) : super(key: key);

  final Manga manga;

  @override
  State<MangaHomePage> createState() => _MangaHomePageState();
}

class _MangaHomePageState extends State<MangaHomePage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final source = context.read<SourceState>();
    final mangaState = context.read<MangaState>();
    final appTheme = context.read<AppTheme>();

    final controller =
        ScrollController(initialScrollOffset: mangaState.homeScrollOffset);

    return FutureBuilder<List<Chapter>>(
        future: widget.manga.chapters.isEmpty
            ? source.sources[widget.manga.source]!
                .fetchChapters(widget.manga.id)
            : null,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
                width: double.infinity,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Fetching details...', style: appTheme.bodyStrong),
                      gapHeight(),
                      const ProgressBar()
                    ]));
          } else if (snapshot.hasError) {
            showSnackbar(
              context,
              Snackbar(
                content: Text(snapshot.error.toString()),
              ),
            );
          } else if (snapshot.connectionState != ConnectionState.none) {
            if (widget.manga.chapters.length != snapshot.data!.length) {
              widget.manga.chapters.addAll(snapshot.data!);

              widget.manga.chapters.sort((a, b) =>
                  double.parse(b.chapter).compareTo(double.parse(a.chapter)));
            }
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              mangaState.homeScrollOffset = notification.metrics.pixels;
              return true;
            },
            child: Scrollbar(
              isAlwaysShown: false,
              controller: controller,
              child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.all(24.0),
                  itemCount: widget.manga.chapters.length + 1,
                  itemBuilder: (context, index) {
                    if (index != 0) {
                      return ChapterItem(
                          chapter: widget.manga.chapters[index - 1],
                          index: index - 1);
                    } else {
                      return MangaInfo(manga: widget.manga);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 16.0,
              direction: Axis.horizontal,
              children: [
                Container(
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
                                              fui.FluentIcons.share_16_regular,
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
                      imageUrl: widget.manga.cover,
                      width: 210,
                      height: 315,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8.0,
                  direction: Axis.vertical,
                  children: [
                    SizedBox(
                        width: 600,
                        child: Text(
                          widget.manga.title,
                          style: appTheme.title,
                        )),
                    Row(children: [
                      Opacity(
                        opacity: 0.7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Author',
                              style: appTheme.body,
                            ),
                            Text(
                              '${widget.manga.source} • ${widget.manga.status}',
                              style: appTheme.body,
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ],
                ),
              ],
            ),
          ],
        ),
        gapHeight(),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(direction: Axis.vertical, spacing: 16.0, children: [
            SizedBox(
              width: 210,
              child: FilledButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(fui.FluentIcons.heart_16_regular, size: 18),
                      gapWidth(8.0),
                      const Text(
                        'Add to library',
                      ),
                    ],
                  ),
                  onPressed: () {}),
            ),
            SizedBox(
              width: 210,
              child: Button(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(fui.FluentIcons.share_16_regular, size: 18),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text('Share'),
                    ],
                  ),
                  onPressed: () {}),
            ),
          ]),
          gapWidth(),
          Description(description: widget.manga.description)
        ]),
        gapHeight(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text('${widget.manga.chapters.length} chapters',
                    style: appTheme.subtitle)),
            Row(
              children: [
                FilledButton(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            fui.FluentIcons.play_24_filled,
                            size: 14,
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text('Resume'),
                        ]),
                    onPressed: () {}),
                gapWidth(8.0),
                IconButton(
                    icon: const Icon(fui.FluentIcons.arrow_clockwise_16_regular,
                        size: 18),
                    onPressed: () {}),
                gapWidth(8.0),
                IconButton(
                    icon: const Icon(
                      fui.FluentIcons.arrow_sort_16_regular,
                      size: 18,
                    ),
                    onPressed: () {})
              ],
            )
          ],
        ),
        gapHeight()
      ],
    );
  }
}

class ChapterItem extends StatelessWidget {
  const ChapterItem({required this.chapter, required this.index, Key? key})
      : super(key: key);

  final int index;
  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();
    final mangaState = context.read<MangaState>();

    return SizedBox(
      height: 70.0,
      child: Button(
        style: ButtonStyle(
          padding: ButtonState.all(const EdgeInsets.all(16.0)),
          border: ButtonState.all(BorderSide.none),
          shape: ButtonState.all(const BeveledRectangleBorder()),
        ),
        onPressed: () {
          mangaState.chapterIndex = index;
          mangaState.setRoute(routeMangaRead);
        },
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chapter ${chapter.chapter} ${chapter.title != '' ? '- ' + chapter.title : ''}',
                  textAlign: TextAlign.left,
                  style: appTheme.body,
                ),
                Opacity(
                  opacity: 0.7,
                  child: Text(
                    '${chapter.dateUploaded} • ${chapter.scanlationGroup}',
                    style: appTheme.caption,
                  ),
                ),
              ],
            ),
          ],
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

    final minDesc = SizedBox(
      height: 40.0,
      child: Text(
        widget.description,
        overflow: TextOverflow.fade,
      ),
    );

    final maxDesc = Text(
      widget.description,
      style: appTheme.body,
    );

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: appTheme.bodyStrongAccent,
          ),
          gapHeight(),
          GestureDetector(
              onTap: () {
                setState(() {
                  tap = !tap;
                });
              },
              child: Opacity(
                opacity: 0.7,
                child: AnimatedCrossFade(
                    sizeCurve: Curves.easeInOut,
                    firstCurve: Curves.easeIn,
                    secondCurve: Curves.easeOut,
                    crossFadeState: !tap
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 200),
                    firstChild: minDesc,
                    secondChild: maxDesc),
              )),
          !tap
              ? const Center(child: Icon(FluentIcons.chevron_down, size: 10))
              : const Center(child: Icon(FluentIcons.chevron_up, size: 10))
        ],
      ),
    );
  }
}
