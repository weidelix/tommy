import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import 'package:xview/sources/manga_source.dart';
import 'package:xview/sources/MangaDex/mangadex.dart';
import 'package:xview/utils.dart';

class SourceState extends ChangeNotifier {
  final Map<String, MangaSource> sources = {'MangaDex': MangaDex()};
  final List<Manga> _latest = [];
  List<Manga> get latest => _latest;

  int page = 1;
  bool isFinishedLoading = true;
  double scrollOffset = 0.0;

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
    checkMemory();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final source = context.watch<SourceState>();
    final controller =
        ScrollController(initialScrollOffset: source.scrollOffset);

    if (source.latest.isEmpty) {
      source.fetchLatestData();
    }

    if (source.latest.isEmpty) {
      return WillPopScope(
        onWillPop: () async {
          source.reset();
          return true;
        },
        child: const Center(
          child: ProgressRing(),
        ),
      );
    } else {
      return WillPopScope(
        onWillPop: () async {
          source.reset();
          return true;
        },
        child: NotificationListener<ScrollNotification>(
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
          child: LayoutBuilder(
            builder: (context, constrainst) => Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Scrollbar(
                controller: controller,
                child: GridView.builder(
                    cacheExtent: 0,
                    controller: controller,
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (constrainst.maxWidth / 210).floor(),
                      childAspectRatio: 180 / 270,
                    ),
                    itemCount: source.latest.length,
                    itemBuilder: (context, index) {
                      return MangaItem(manga: source.latest[index]);
                    }),
              ),
            ),
          ),
        ),
      );
    }
  }
}
