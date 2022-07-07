import 'dart:convert';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

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

      final uri = Uri.https(MDBase.api, MDPaths.manga, query);
      var mangasData = jsonDecode((await get(uri)).body);

      List<Manga> mangas = [];
      for (var manga in mangasData['data']) {
        mangas.add(await getMinMangaData(manga));
      }

      return mangas;
    } catch (identifier) {
      return [];
    }
  }

  @override
  Future<List<Manga>> latestUpdatesRequest([int page = 1]) async {
    final Map<String, dynamic> query = {};

    query.addAll(
        MDQueries.offset(MDConstantQuery.latestChapterlimit * (page - 1)));
    query.addAll(MDQueries.limit(MDConstantQuery.latestChapterlimit));
    query.addAll(MDQueries.includes(['user', 'scanlation_group', 'manga']));
    query.addAll(MDQueries.contentRating(['safe', 'suggestive']));
    query.addAll(MDQueries.originalLanguage(['en', 'ja', 'ko']));
    query.addAll(MDQueries.translatedLanguage(['en']));
    query.addAll(MDQueries.order('readableAt', 'desc'));
    query.addAll(MDConstantQuery.notIncludeFutureUpdates);

    return parseLatestUpdates(
        get(Uri.https(MDBase.api, MDPaths.chapter, query)));
  }

  @override
  Future<List<Chapter>> fetchChapters(String id) async {
    final Map<String, dynamic> query = {};
    final List<Chapter> chapters = [];
    int offset = 0;
    bool stop = false;

    while (!stop) {
      query.addAll(MDQueries.offset(100 * offset++));
      query.addAll(MDQueries.manga(id));
      query.addAll(MDQueries.limit(MDConstantQuery.latestChapterlimit));
      query.addAll(MDQueries.translatedLanguage(['en']));
      query.addAll(MDConstantQuery.notIncludeFutureUpdates);
      query.addAll(MDQueries.order('chapter', 'asc'));

      final uri = Uri.https(MDBase.api, MDPaths.chapter, query);
      final chaptersData = jsonDecode((await get(uri)).body);

      // TODO: Optimize checking of the last chapter
      if (chaptersData['data'].isNotEmpty) {
        for (var chapter in chaptersData['data']) {
          if (!chapters.any((element) => element.id == chapter['id'])) {
            chapters.add(Chapter(
                id: chapter['id'],
                chapter: chapter['attributes']['chapter']?.trim() ?? '-1',
                title: chapter['attributes']['title'] ?? '',
                // TODO: Get uploader
                uploader: '',
                dateUploaded: chapter['attributes']['updatedAt']
                    .split('T')[0]
                    .replaceAll('-', '/'),
                scanlationGroup: 'Scanlation Group',
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
    final uri = MDHelper.toServerUri(chapter.id);
    final pagesData = jsonDecode((await get(uri)).body);

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
    final uri = Uri.https(MDBase.api, MDPaths.manga + '/${manga.id}');
    final data = jsonDecode((await get(uri)).body)['data'];

    String? description;

    if (data['attributes']['description'].isNotEmpty) {
      description = data['attributes']['description'].values.first;

      if (description!.indexOf('---') > 0) {
        description = description.substring(1, description.indexOf('---'));
      }
    }

    final ids = (data['relationships'] as List<dynamic>)
        .where((element) => element['type'] == 'author')
        .map((e) => e['id'])
        .toList(growable: false);

    final authorsUri =
        Uri.https(MDBase.api, MDPaths.author, MDQueries.ids(ids));
    final authorsData = jsonDecode((await get(authorsUri)).body)['data'];
    String authors = (authorsData as List<dynamic>)
        .map((e) => e['attributes']['name'])
        .join(", ");

    manga.description = description;
    manga.authors = authors;
  }

  Future<Manga> getMinMangaData(dynamic data) async {
    String id = data['id'];
    String title = data['attributes']['title'].values.first;

    String status = toBeginningOfSentenceCase(data['attributes']['status'])!;

    final fileName = (data['relationships'].firstWhere(
        (element) => element['type'] == 'cover_art'))['attributes']['fileName'];
    String cover = MDHelper.toCoverUrl(id, fileName);

    return Manga(
        id: id, title: title, status: status, cover: cover, source: 'MangaDex');
  }
}
