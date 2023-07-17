import 'package:collection/collection.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:xview/manga_manager.dart';
import 'package:xview/sources/source_provider.dart';
import 'package:xview/theme.dart';
import 'manga_source.dart';

void showMangaUpdater(BuildContext context) {
  late OverlayEntry overlayEntry;

  overlayEntry = showSnackbar(
      context, MangaUpdater(onFinish: () => overlayEntry.remove()),
      alignment: AlignmentDirectional.bottomEnd,
      duration: const Duration(seconds: 999));
}

class MangaUpdater extends StatefulWidget {
  const MangaUpdater({Key? key, required this.onFinish}) : super(key: key);

  final void Function() onFinish;

  @override
  State<MangaUpdater> createState() => _MangaUpdaterState();
}

class _MangaUpdaterState extends State<MangaUpdater> {
  ValueNotifier currentManga = ValueNotifier('');
  ValueNotifier mangaIndex = ValueNotifier(0.0);

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();

    double mangaCount = MangaManager().mangas.length.toDouble();

    if (mangaCount > 0) {
      WidgetsBinding.instance.addPostFrameCallback(_refreshMangas);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((duration) async {
        await Future.delayed(const Duration(seconds: 5));
        widget.onFinish();
      });
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InfoBar(
          severity:
              mangaCount > 0 ? InfoBarSeverity.info : InfoBarSeverity.error,
          style: InfoBarThemeData(
              decoration: (severity) => BoxDecoration(
                  color: FluentTheme.of(context).cardColor,
                  borderRadius: appTheme.brInner),
              icon: (severity) {
                if (severity == InfoBarSeverity.error) {
                  return fui.FluentIcons.error_circle_24_regular;
                }

                return fui.FluentIcons.arrow_clockwise_24_regular;
              }),
          title: const Text(''),
          content: Container(
            height: 40,
            constraints: const BoxConstraints(minWidth: 300, maxWidth: 300),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder(
                    valueListenable: currentManga,
                    builder: (context, value, child) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              mangaCount > 0
                                  ? "Checking for new chapters..."
                                  : "No mangas to update",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: appTheme.bodyStrong,
                            ),
                            mangaCount > 0
                                ? Text(
                                    ' ${mangaIndex.value.toInt() + 1}/${mangaCount.toInt()}',
                                    style: appTheme.caption)
                                : const SizedBox.shrink()
                          ],
                        )),
                mangaCount > 0
                    ? ValueListenableBuilder(
                        valueListenable: mangaIndex,
                        builder: (context, value, child) => SizedBox(
                              width: double.infinity,
                              child: ProgressBar(
                                  value: (100.0 / mangaCount) *
                                      ((value as double) + 1)),
                            ))
                    : Text('Add mangas to your library to update them',
                        style: appTheme.caption)
              ],
            ),
          )),
    );
  }

  void _refreshMangas(Duration timestamp) async {
    final sources = context.read<SourceProvider>().sources;

    for (var manga in MangaManager().mangas) {
      currentManga.value = manga.title;
      mangaIndex.value = MangaManager().mangas.indexOf(manga).toDouble();

      final chapters = manga.chapters;
      try {
        List<Chapter> newChapters =
            await sources[manga.source]!.getChapters(manga.url);
        for (var chapter in newChapters) {
          if (chapters.singleWhereOrNull((c) => c.url == chapter.url) == null) {
            chapters.add(chapter);
          }
        }
      } catch (e) {
        rethrow;
      }

      await Future.delayed(const Duration(seconds: 1));

      chapters.sort(
          (a, b) => double.parse(b.chapter).compareTo(double.parse(a.chapter)));
    }
    MangaManager().save();
    widget.onFinish();
  }
}
