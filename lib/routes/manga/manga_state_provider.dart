import 'package:fluent_ui/fluent_ui.dart';
import 'package:xview/sources/manga_source.dart';

class MangaStateProvider {
  MangaStateProvider({required this.manga});

  final Manga manga;

  int chapterSelected = 0;
  double homeScrollOffset = 0.0;
  double readerScrollOffset = 0.0;

  final controller = PageController(initialPage: 0, viewportFraction: 1.0);
}
