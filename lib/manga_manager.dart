import 'dart:convert';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:xview/sources/manga_source.dart';

class MangaManager {
  static final _instance = MangaManager._();

  factory MangaManager() {
    return _instance;
  }

  MangaManager._() {
    final dir = Directory('./user');
    final file = File('./user/mangas.json');

    if (!dir.existsSync()) {
      dir.createSync();
    }

    if (file.existsSync()) {
      if (file.readAsStringSync() == '') file.writeAsStringSync('[]');

      mangas = (jsonDecode(file.readAsStringSync()) as List<dynamic>)
          .map((e) => Manga.fromJSON(e as Map<String, dynamic>))
          .toList();
    } else {
      File('./user/mangas.json').createSync();
    }
  }

  get manga => mangas;
  List<Manga> mangas = [];

  void addManga(Manga manga) {
    if (mangas.any((element) => element.url == manga.url)) return;
    mangas.add(manga);
    // notifyListeners();
  }

  void removeManga(Manga manga) {
    mangas.remove(manga);
    // notifyListeners();
  }

  void clearMangas() {
    mangas.clear();
  }

  Manga? getManga(String url) {
    return mangas.firstWhereOrNull((element) => element.url == url);
  }

  void save() {
    File('./user/mangas.json').writeAsStringSync(jsonEncode(mangas));
  }

  void read() {
    mangas = (jsonDecode(File('./user/mangas.json').readAsStringSync())
            as List<dynamic>)
        .map((e) => Manga.fromJSON(e as Map<String, dynamic>))
        .toList();
  }
}
