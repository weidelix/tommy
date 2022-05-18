import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import 'package:xview/sources/manga_source.dart';
import 'package:xview/utils.dart';
import 'package:xview/page/manga/manga_home.dart';
import 'package:xview/page/manga/manga_reader.dart';

// TODO: Implement goto next and previous chapter
// TODO: Add page number
// TODO: Add flyout text to commandbar buttons

class MangaState {
  MangaState({required this.manga});

  final Manga manga;

  int chapterSelected = 0;
  double homeScrollOffset = 0.0;
  double readerScrollOffset = 0.0;

  final controller = PageController(initialPage: 0, viewportFraction: 1.0);
}

class MangaPage extends StatefulWidget {
  const MangaPage({required this.manga, Key? key}) : super(key: key);

  final Manga manga;

  @override
  State<MangaPage> createState() => _MangaPageState();
}

class _MangaPageState extends State<MangaPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    checkMemory();
    return Provider(
        create: (_) => MangaState(manga: widget.manga),
        builder: (context, __) {
          final mangaState = context.read<MangaState>();
          return Mica(
              child: PageView(
                  controller: mangaState.controller,
                  children: const [MangaHomePage(), ReaderPage()]));
        });
  }
}
