import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:xview/sources/manga_source.dart';
import 'page/manga/manga.dart';

class TabItem {
  TabItem({required this.tab, required Manga manga, required this.id})
      : state = MangaState(manga: manga);

  final String id;
  final Tab tab;
  final MangaState? state;
  late Widget body = Provider.value(
      key: Key(id), value: state, child: MangaPage(key: Key(id)));
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
                // focusNode: FocusNode(),
                icon: Image.asset('assets/logo/${manga.source}/32x32.png',
                    scale: 2),
                text: Text(manga.title, overflow: TextOverflow.ellipsis),
                closeIcon: fui.FluentIcons.dismiss_48_regular,
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

/*
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:xview/sources/manga_source.dart';
import 'page/manga/manga.dart';

class TabItem {
  TabItem({required this.tab, Manga? manga, required this.id})
      : state = manga != null ? MangaState(manga: manga) : null;

  final String id;
  final Tab tab;
  final MangaState? state;
  late Widget body = Provider.value(
      key: Key(id), value: state, child: MangaPage(key: Key(id)));
}

class TabsState extends ChangeNotifier {
  int maxTabCount = 8;
  int _index = 0;
  int get index => _index;
  set index(int value) {
    _index = value;
    notifyListeners();
  }

  final List<TabItem> _tabs = [
    TabItem(
        tab: const Tab(
            text: Text('Home'),
            icon: Icon(fui.FluentIcons.home_24_regular, size: 14),
            closeIcon: null),
        manga: null,
        id: '-1')
  ];
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
                // key: ValueKey(manga.id),
                icon: Image.asset('assets/logo/${manga.source}/32x32.png',
                    scale: 2),
                text: Text(manga.title, overflow: TextOverflow.ellipsis),
                closeIcon: fui.FluentIcons.dismiss_48_regular,
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
*/
