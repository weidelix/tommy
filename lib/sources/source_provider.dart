import 'package:fluent_ui/fluent_ui.dart';

import 'package:xview/sources/MangaDex/mangadex.dart';
import 'package:xview/sources/manga_source.dart';

class SourceProvider extends ChangeNotifier {
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

  Future<void> fetchLatestData() async {
    isFinishedLoading = false;
    final result = await activeSource.latestUpdatesRequest(page++);
    _latest.addAll(result);
    isFinishedLoading = true;
  }

  void reset() {
    _latest.clear();
    page = 1;
    scrollOffset = 0.0;
  }
}
