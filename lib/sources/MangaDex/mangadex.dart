import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:xview/manga_manager.dart';
import 'package:collection/collection.dart';
import 'package:xview/sources/manga_source.dart';
import 'package:xview/sources/MangaDex/md_constants.dart';
import 'package:xview/sources/MangaDex/md_helper.dart';

class MangaDex implements MangaSource {
  @override
  String title = 'MangaDex';

  Future<List<Manga>> parseLatestUpdates(Future<Response> res) async {
    try {
      final response = await res;
      final latest = jsonDecode(response.body)['data'] as List<dynamic>;

      final latestIds = latest.map((element) {
        return (element['relationships'] as List<dynamic>)
            .firstWhere((element) => element['type'] == 'manga')['id'];
      }).toList();

      final Map<String, dynamic> query = {};

      query.addAll(MDQueries.limit(latestIds.length));
      query.addAll(MDQueries.includes(['cover_art']));
      query.addAll(MDQueries.ids(latestIds));

      final uri = Uri.https(MDDomains.api, MDPaths.manga, query);
      var data = await get(uri);
      var mangasData = jsonDecode(data.body);
      if (mangasData['result'] == 'error') {
        var error = mangasData['errors'].first;

        throw HttpException(error['detail']);
      }

      List<Manga> mangas = [];
      for (var manga in mangasData['data']) {
        mangas.add(MangaManager().getManga(MDHelper.toMangaUri(manga['id'])) ??
            await getMinMangaData(manga));
      }

      return mangas;
    } catch (identifier) {
      rethrow;
    }
  }

  Future<List<Manga>> parsePopularMangas(Future<Response> res) async {
    try {
      final response = await res;
      final latest = jsonDecode(response.body)['data'] as List<dynamic>;

      final latestIds =
          latest.map((element) => element['id'] as String).toList();

      final Map<String, dynamic> query = {};

      query.addAll(MDQueries.limit(latestIds.length));
      query.addAll(MDQueries.includes(['cover_art']));
      query.addAll(MDQueries.ids(latestIds));

      final uri = Uri.https(MDDomains.api, MDPaths.manga, query);
      var data = await get(uri);
      var mangasData = jsonDecode(data.body);
      if (mangasData['result'] == 'error') {
        var error = mangasData['errors'].first;

        throw HttpException(error['detail']);
      }

      List<Manga> mangas = [];
      for (var manga in mangasData['data']) {
        mangas.add(MangaManager().getManga(MDHelper.toMangaUri(manga['id'])) ??
            await getMinMangaData(manga));
      }

      return mangas;
    } catch (identifier) {
      rethrow;
    }
  }

  Future<List<Manga>> parseMangaSearch(Future<Response> res) async {
    try {
      final response = await res;
      final searchResult = jsonDecode(response.body)['data'] as List<dynamic>;
      final ids =
          searchResult.map((element) => element['id'] as String).toList();

      final Map<String, dynamic> query = {};

      query.addAll(MDQueries.limit(ids.length));
      query.addAll(MDQueries.includes(['cover_art']));
      query.addAll(MDQueries.ids(ids));

      final uri = Uri.https(MDDomains.api, MDPaths.manga, query);
      var data = await get(uri);
      var mangasData = jsonDecode(data.body);

      if (mangasData['result'] == 'error') {
        var error = mangasData['errors'].first;

        throw HttpException(error['detail']);
      }

      List<Manga> mangas = [];
      for (var manga in mangasData['data']) {
        mangas.add(MangaManager().getManga(MDHelper.toMangaUri(manga['id'])) ??
            await getMinMangaData(manga));
      }

      return mangas;
    } catch (identifier) {
      rethrow;
    }
  }

  @override
  Future<List<Manga>> searchMangaRequest(String title) async {
    final Map<String, dynamic> query = {};
    query.addAll(MDQueries.title(title));

    return parseMangaSearch(
        get(Uri.https(MDDomains.api, MDPaths.manga, query)));
  }

  @override
  Future<List<Manga>> latestUpdatesRequest([int page = 1]) async {
    final Map<String, dynamic> query = {};
    final limit = int.parse(MDQueries.latestChapterLimit.values.first);

    query.addAll(MDQueries.offset(limit * (page - 1)));
    query.addAll(MDQueries.limit(limit));
    query.addAll(MDQueries.includes(['user', 'scanlation_group', 'manga']));
    query.addAll(MDQueries.contentRating(['safe', 'suggestive']));
    query.addAll(MDQueries.originalLanguage(['en', 'ja', 'ko']));
    query.addAll(MDQueries.translatedLanguage(['en']));
    query.addAll(MDQueries.order('readableAt', 'desc'));
    query.addAll(MDQueries.notIncludeFutureUpdates);

    return parseLatestUpdates(get(Uri.parse(MDHelper.toChapterUri(query))));
  }

  @override
  Future<List<Manga>> popularMangasRequest([int page = 1]) async {
    final Map<String, dynamic> query = {};
    const limit = 50;

    query.addAll(MDQueries.offset(limit * (page - 1)));
    query.addAll(MDQueries.limit(limit));
    query.addAll(MDQueries.includes(['user', 'scanlation_group', 'manga']));
    query.addAll(MDQueries.contentRating(['safe', 'suggestive']));
    query.addAll(MDQueries.originalLanguage(['en', 'ja', 'ko']));
    query.addAll(MDQueries.order('rating', 'desc'));
    return parsePopularMangas(
        get(Uri.https(MDDomains.api, MDPaths.manga, query)));
  }

  Future<List<Chapter>> parseChapters(String url) async {
    final List<Chapter> chapters = [];
    final Map<String, dynamic> query = {};
    final groupsAndUser = <String, String>{};
    final id = MDHelper.getMangaId(url);
    int offset = 0;

    query.addAll(MDQueries.translatedLanguage(['en']));
    query.addAll(MDQueries.order('chapter', 'asc'));
    query.addAll(MDQueries.limit(500));
    query.addAll(MDQueries.notIncludeFutureUpdates);

    final now = DateTime.now();
    final today = DateFormat('yyyy/MM/dd').format(now);
    final yesterday =
        DateFormat('yyyy/MM/dd').format(now.subtract(const Duration(days: 1)));

    final client = Client();

    int i = 0;
    try {
      while (true) {
        query.addAll(MDQueries.offset(500 * offset++));

        final uri =
            Uri.https(MDDomains.api, '${MDPaths.manga}/$id/feed/', query);
        final body = (await client.get(uri)).body;
        i++;
        final json = jsonDecode(body);
        final chaptersData = json['data'];
        final total = json['total'];

        if (chaptersData.isNotEmpty) {
          for (var chapter in chaptersData) {
            bool isGroup = true;
            final uploader = chapter['relationships'].firstWhere((e) {
              isGroup = e['type'] == 'scanlation_group';
              return isGroup || e['type'] == 'user';
            })['id'];

            if (groupsAndUser[uploader] == null) {
              final groupUri = Uri.https(MDDomains.api,
                  '${isGroup ? MDPaths.group : MDPaths.user}/$uploader');
              final groupData = jsonDecode((await client.get(groupUri)).body);

              groupsAndUser[uploader] = groupData['data']['attributes']
                  [isGroup ? 'name' : 'username'];
            }

            final dateToCompare = DateFormat('yyyy/MM/dd')
                .format(DateTime.parse(chapter['attributes']['updatedAt']));

            String dateUploaded = '';
            if (dateToCompare == today) {
              dateUploaded = 'Today';
            } else if (dateToCompare == yesterday) {
              dateUploaded = 'Yesterday';
            } else {
              dateUploaded = dateToCompare;
            }

            final attr = chapter['attributes'];
            chapters.add(Chapter(
                url: MDHelper.toServerUri(chapter['id']),
                chapter: attr['chapter']?.trim() ?? '-1',
                title: attr['title'] ?? '',
                dateUploaded: dateUploaded,
                pages: attr['pages'],
                scanlationGroup: groupsAndUser[uploader] ?? 'Anonymous'));
          }
        } else {
          break;
        }

        if (total < 500) {
          break;
        }
      }
    } finally {
      client.close();
    }

    return chapters;
  }

  @override
  Future<List<Chapter>> getChapters(String url) async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      return [];
    }

    return compute(parseChapters, url);
  }

  @override
  Future<List<String>> readChapter(Chapter chapter) async {
    final List<String> pages = [];
    final pagesData = jsonDecode((await get(Uri.parse(chapter.url))).body);

    for (int i = 0; i < chapter.pages; ++i) {
      final data = PageData(pagesData);
      final url =
          '${data.baseUrl}/data/${data.hash}/${data.images['data']![i]}';
      pages.add(url);
    }

    return pages;
  }

  Manga parseFullMangaData(Map<String, dynamic> message) {
    final data = jsonDecode(message['body'])['data'];
    String? description = '';

    if (data['attributes']['description']?.isNotEmpty) {
      description = data['attributes']['description'].values.first;
    }

    List<String> tags = [];
    if (data['attributes']['tags'].isNotEmpty) {
      tags = (data['attributes']['tags'] as List<dynamic>)
          .map<String>((e) => e['attributes']['name']['en'])
          .toList();
    }

    final authorsData = jsonDecode(message['authorsBody'])['data'];
    String authors = (authorsData as List<dynamic>)
        .map((e) => e['attributes']['name'])
        .join(", ");

    message['manga'].tags = tags;
    message['manga'].description = description;
    message['manga'].authors = authors;

    return message['manga'];
  }

  @override
  Future<void> getFullMangaData(Manga manga) async {
    final uri = Uri.parse(manga.url);
    final client = Client();

    try {
      final body = (await get(uri)).body;

      final ids = manga.authors!.split(", ");
      final authorsUri =
          Uri.https(MDDomains.api, MDPaths.author, MDQueries.ids(ids));
      final authorsBody = (await get(authorsUri)).body;

      final message = {
        'manga': manga,
        'body': body,
        'authorsBody': authorsBody
      };

      final fullManga = await compute(parseFullMangaData, message);
      manga.tags = fullManga.tags;
      manga.description = fullManga.description;
      manga.authors = fullManga.authors;
    } finally {
      client.close();
    }
  }

  Future<Manga> getMinMangaData(dynamic data) async {
    final fileName = ((data['relationships'] as List<dynamic>).firstWhereOrNull(
            (element) => element['type'] == 'cover_art'))?['attributes']
        ['fileName'];

    final ids = (data['relationships'] as List<dynamic>)
        .where((element) => element['type'] == 'author')
        .map((e) => e['id'])
        .toList(growable: false);

    String url = MDHelper.toMangaUri(data['id']);
    String title = data['attributes']['title'].values.first;
    String status = toBeginningOfSentenceCase(data['attributes']['status'])!;
    String cover = MDHelper.toCoverUrl(data['id'], fileName);
    String authors = ids.join(", ");

    return Manga(
        url: url,
        title: title,
        status: status,
        cover: cover,
        source: 'MangaDex',
        authors: authors);
  }
}
