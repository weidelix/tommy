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

    return Builder(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback(_refreshMangas);
        double mangaCount = MangaManager().mangas.length.toDouble();

        return InfoBar(
            style: InfoBarThemeData(
                decoration: (severity) =>
                    BoxDecoration(color: FluentTheme.of(context).cardColor),
                icon: (severity) => fui.FluentIcons.arrow_clockwise_24_regular),
            title: const Text(''),
            content: Container(
              height: 35,
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
                                "Updating library...",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: appTheme.bodyStrong,
                              ),
                              Text(
                                  ' ${mangaIndex.value.toInt() + 1}/${mangaCount.toInt()}')
                            ],
                          )),
                  ValueListenableBuilder(
                      valueListenable: mangaIndex,
                      builder: (context, value, child) => SizedBox(
                            width: double.infinity,
                            child: ProgressBar(
                                value: (100.0 / mangaCount) *
                                    ((value as double) + 1)),
                          ))
                ],
              ),
            ));
      },
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
            await sources[manga.source]!.fetchChapters(manga.url);
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
