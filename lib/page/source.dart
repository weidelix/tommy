import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import 'package:xview/sources/manga_source.dart';
import 'package:xview/sources/MangaDex/mangadex.dart';

class SourceState extends ChangeNotifier {
  int page = 1;
  bool isFinishedLoading = true;
  double scrollOffset = 0.0;

  final List<Manga> _latest = [];
  List<Manga> get latest => _latest;

  MangaSource? _activeSource;
  MangaSource get activeSource => _activeSource!;
  set activeSource(MangaSource source) {
    _activeSource = source;
    notifyListeners();
  }

  void fetchLatestData() {
    if (isFinishedLoading) {
      final data = activeSource
          .parseLatestUpdates(activeSource.latestUpdatesRequest(++page));

      data.whenComplete(() async {
        _latest.addAll(await data);
        isFinishedLoading = true;
        notifyListeners();
      });

      isFinishedLoading = false;
    }
  }

  final Map<String, MangaSource> sources = {'MangaDex': MangaDex()};

  void reset() {
    _latest.clear();
    page = 1;
    scrollOffset = 0.0;
  }
}

class SourcePage extends StatefulWidget {
  const SourcePage({Key? key}) : super(key: key);

  @override
  State<SourcePage> createState() => _SourcePageState();
}

class _SourcePageState extends State<SourcePage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final source = context.watch<SourceState>();

    if (source.latest.isEmpty) {
      source.fetchLatestData();
    }

    if (source.latest.isEmpty) {
      return const Center(
        child: ProgressRing(),
      );
    } else {
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          source.scrollOffset = notification.metrics.pixels;

          if (notification.metrics.maxScrollExtent ==
              notification.metrics.pixels) {
            if (source.isFinishedLoading) {
              source.fetchLatestData();
            }
          }
          return true;
        },
        child: ListView(
            controller:
                ScrollController(initialScrollOffset: source.scrollOffset),
            children: [
              Align(
                  alignment: Alignment.topCenter,
                  child: Wrap(
                      alignment: WrapAlignment.start,
                      runSpacing: 24.0,
                      spacing: 24.0,
                      children: [
                        ...source.latest
                            .map((e) => MangaItem(manga: e))
                            .toList(),
                      ])),
            ]),
      );
    }
  }
}
