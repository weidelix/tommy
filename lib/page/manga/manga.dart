import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:xview/main.dart';

import 'package:xview/theme.dart';
import 'package:xview/sources/manga_source.dart';
import 'manga_home.dart';
import 'manga_reader.dart';

const routeMangaHome = 'MangaHome';
const routeMangaRead = 'MangaRead';

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
  const MangaPage({Key? key}) : super(key: key);

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
    _checkMemory();
    final mangaState = context.read<MangaState>();
    return Mica(
      child: PageView(
          controller: mangaState.controller,
          children: const [MangaHomePage(), ReaderPage()]),
    );
  }

  void _checkMemory() {
    var imageCache = PaintingBinding.instance!.imageCache;
    if (imageCache!.currentSizeBytes >= 55 << 20) {
      imageCache.clear();
      imageCache.clearLiveImages();
    }
  }
}
