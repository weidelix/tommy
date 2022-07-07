import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:xview/routes/manga/manga_state_provider.dart';

import 'package:xview/sources/manga_source.dart';
import 'package:xview/utils/utils.dart';
import 'package:xview/routes/manga/manga_home.dart';
import 'package:xview/routes/manga/manga_reader.dart';

// TODO: Implement goto next and previous chapter
// TODO: Add page number
// TODO: Add flyout text to commandbar buttons

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
        create: (_) => MangaStateProvider(manga: widget.manga),
        builder: (context, __) {
          final mangaState = context.read<MangaStateProvider>();
          return Mica(
              child: PageView(
                  controller: mangaState.controller,
                  children: const [MangaHomePage(), ReaderPage()]));
        });
  }
}
