import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:xview/manga_manager.dart';

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

  @override
  Future<List<Manga>> searchMangaRequest(String title) async {
    final Map<String, dynamic> query = {};
    query.addAll(MDQueries.title(title));

    final uri = Uri.https(MDDomains.api, MDPaths.manga, query);
    var data = await get(uri);
    var mangasData = jsonDecode(data.body);

    List<Manga> mangas = [];
    for (var manga in mangasData['data']) {
      mangas.add(MangaManager().getManga(MDHelper.toMangaUri(manga['id'])) ??
          await getMinMangaData(manga));
    }

    return mangas;
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
  Future<List<Chapter>> fetchChapters(String url) async {
    final Map<String, dynamic> query = {};
    final List<Chapter> chapters = [];
    int offset = 0;
    bool stop = false;

    while (!stop) {
      query.addAll(MDQueries.offset(100 * offset++));
      query.addAll(MDQueries.manga(MDHelper.getMangaId(url)));
      query.addAll(MDQueries.translatedLanguage(['en']));
      query.addAll(MDQueries.order('chapter', 'asc'));
      query.addAll(MDQueries.latestChapterLimit);
      query.addAll(MDQueries.notIncludeFutureUpdates);

      final uri = Uri.https(MDDomains.api, MDPaths.chapter, query);

      final chaptersData = jsonDecode((await get(uri)).body);

      // TODO: Optimize checking of the last chapter
      if (chaptersData['data'].isNotEmpty) {
        for (var chapter in chaptersData['data']) {
          if (!chapters.any((element) => element.url == chapter['api'])) {
            chapters.add(Chapter(
                url: MDHelper.toServerUri(chapter['id']),
                chapter: chapter['attributes']['chapter']?.trim() ?? '-1',
                title: chapter['attributes']['title'] ?? '',
                dateUploaded: chapter['attributes']['updatedAt']
                    .split('T')[0]
                    .replaceAll('-', '/'),
                pages: chapter['attributes']['pages']));
          } else {
            stop = true;
          }
        }
      } else {
        stop = true;
      }
    }

    return chapters;
  }

  @override
  Future<List<String>> readChapter(Chapter chapter) async {
    final List<String> pages = [];
    final pagesData = jsonDecode((await get(Uri.parse(chapter.url))).body);

    for (int i = 0; i < chapter.pages; ++i) {
      final data = PageData(pagesData);
      final url =
          '${data.baseUrl}/data-saver/${data.hash}/${data.images['data-saver']![i]}';
      pages.add(url);
    }

    return pages;
  }

  @override
  Future<void> getFullMangaData(Manga manga) async {
    final uri = Uri.parse(manga.url);
    final data = jsonDecode((await get(uri)).body)['data'];
    String? description;

    if (data['attributes']['description'].isNotEmpty) {
      description = data['attributes']['description'].values.first;
    }

    List<String> tags = [];
    if (data['attributes']['tags'].isNotEmpty) {
      tags = (data['attributes']['tags'] as List<dynamic>)
          .map<String>((e) => e['attributes']['name']['en'])
          .toList();
    }

    final ids = (data['relationships'] as List<dynamic>)
        .where((element) => element['type'] == 'author')
        .map((e) => e['id'])
        .toList(growable: false);

    final authorsUri =
        Uri.https(MDDomains.api, MDPaths.author, MDQueries.ids(ids));
    final authorsData = jsonDecode((await get(authorsUri)).body)['data'];
    String authors = (authorsData as List<dynamic>)
        .map((e) => e['attributes']['name'])
        .join(", ");

    manga.tags = tags;
    manga.description = description;
    manga.authors = authors;
  }

  Future<Manga> getMinMangaData(dynamic data) async {
    final fileName = (data['relationships'].firstWhere(
        (element) => element['type'] == 'cover_art'))['attributes']['fileName'];

    String url = MDHelper.toMangaUri(data['id']);
    String title = data['attributes']['title'].values.first;
    String status = toBeginningOfSentenceCase(data['attributes']['status'])!;
    String cover = MDHelper.toCoverUrl(data['id'], fileName);

    return Manga(
        url: url,
        title: title,
        status: status,
        cover: cover,
        source: 'MangaDex');
  }
}
