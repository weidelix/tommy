import 'package:fluent_ui/fluent_ui.dart';

import 'package:xview/sources/MangaDex/mangadex.dart';
import 'package:xview/sources/manga_source.dart';

class SourceProvider extends ChangeNotifier {
  final Map<String, MangaSource> sources = {'MangaDex': MangaDex()};
  final List<Manga> _mangaList = [];
  List<Manga> get mangaList => _mangaList;
  final List<Manga> _mangaSearchList = [];
  List<Manga> get mangaSearchList => _mangaSearchList;

  int page = 1;
  bool isFinishedLoading = true;
  double scrollOffset = 0.0;

  MangaSource? _activeSource;
  MangaSource get activeSource => _activeSource!;
  set activeSource(MangaSource source) {
    _activeSource = source;
    notifyListeners();
  }

  Future<void> latestUpdates() async {
    isFinishedLoading = false;
    final result = await activeSource.latestUpdatesRequest(page++);
    _mangaList.addAll(result);
    isFinishedLoading = true;
  }

  Future<void> popularMangas() async {
    isFinishedLoading = false;
    final result = await activeSource.popularMangasRequest(page++);
    _mangaList.addAll(result);
    isFinishedLoading = true;
  }

  Future<void> searchManga(String title) async {
    isFinishedLoading = false;
    final result = await activeSource.searchMangaRequest(title);
    _mangaSearchList.clear();
    _mangaSearchList.addAll(result);
    isFinishedLoading = true;
  }

  void reset() {
    _mangaList.clear();
    _mangaSearchList.clear();
    page = 1;
    scrollOffset = 0.0;
  }
}
