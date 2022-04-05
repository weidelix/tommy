import 'package:fluentui_system_icons/fluentui_system_icons.dart' as ms;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:xview/sources/manga_source.dart';
import 'page/manga.dart';

class TabItem {
  TabItem({required this.tab, required this.manga, required this.id});

  final String id;
  final Tab tab;
  final Manga manga;
  MangaState state = MangaState();
  late Widget body = body = ChangeNotifierProvider.value(
      value: state, child: MangaPage(manga: manga));
}

class TabsState extends ChangeNotifier {
  int maxTabCount = 8;
  int _index = 0;
  int get index => _index;
  set index(int value) {
    _index = value;
    notifyListeners();
  }

  final List<TabItem> _tabs = [];
  List<TabItem> get tabs => _tabs;

  void _close(String id) {
    final tab = _tabs.firstWhere((element) => element.id == id);

    if (_index > _tabs.indexOf(tab)) {
      _index = _tabs.length - 1;
    }

    _tabs.remove(tab);
    notifyListeners();
  }

  void openManga(Manga manga) {
    if (_tabs.length <= maxTabCount) {
      if (_tabs.any((element) => element.id == manga.id)) {
        _index = _tabs.indexWhere((element) => element.id == manga.id) + 1;
      } else {
        late TabItem tab;
        tab = TabItem(
            id: manga.id,
            tab: Tab(
                icon: Image.asset('assets/logo/${manga.source}/32x32.png',
                    scale: 2),
                text: Text(manga.title, overflow: TextOverflow.ellipsis),
                closeIcon: ms.FluentIcons.dismiss_48_regular,
                onClosed: () {
                  _close(manga.id);
                }),
            manga: manga);

        _tabs.add(tab);
        _index = _tabs.length;
      }

      notifyListeners();
    }
  }
}
