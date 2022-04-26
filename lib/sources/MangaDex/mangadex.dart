import 'dart:convert';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import 'package:xview/sources/manga_source.dart';
import 'package:xview/sources/MangaDex/md_constants.dart';
import 'package:xview/sources/MangaDex/md_helper.dart';

/// Process [MangaDex] manga data to get required [Manga] data
class MDManga {
  const MDManga({this.data});

  final dynamic data;

  String get id => data['id'];

  String get title => data['attributes']['title'].values.first;

  String get description {
    // Return "Unknown" if theres no description
    if (data['attributes']['description'].isEmpty) {
      return 'Unknown';
    }

    // Return english version of the description
    // If it is null return "Unknown"
    // TODO Return description based on the preferred language of the user
    return (data['attributes']['description']['en'] as String?)
            ?.split('---')[0]
            .trim() ??
        'Unknown';
  }

  String get cover {
    final coverId = (data['relationships'].firstWhere(
        (element) => element['type'] == 'cover_art'))['attributes']['fileName'];

    return 'https://uploads.mangadex.org/covers/${data['id']}/$coverId.256.jpg';
  }

  String get status => toBeginningOfSentenceCase(data['attributes']['status'])!;
}

class MangaDex implements MangaSource {
  @override
  String title = 'MangaDex';

  @override
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

      final uri = Uri.https(MDConstants.host, MDPaths.manga, query);
      var mangasData = jsonDecode((await get(uri)).body);

      List<Manga> mangas = [];
      for (var manga in mangasData['data']) {
        final data = MDManga(data: manga);

        mangas.add(Manga(
            source: title,
            id: data.id,
            title: data.title,
            cover: data.cover,
            description: data.description,
            status: data.status));
      }

      return mangas;
    } catch (identifier) {
      return [];
    }
  }

  @override
  Future<Response> latestUpdatesRequest([int page = 1]) async {
    final Map<String, dynamic> query = {};

    query.addAll(MDQueries.offset(MDConstants.latestChapterlimit * (page - 1)));
    query.addAll(MDQueries.limit(MDConstants.latestChapterlimit));
    query.addAll(MDQueries.includes(['user', 'scanlation_group', 'manga']));
    query.addAll(MDQueries.contentRating(['safe', 'suggestive']));
    query.addAll(MDQueries.originalLanguage(['en', 'ja', 'ko']));
    query.addAll(MDQueries.translatedLanguage(['en']));
    query.addAll(MDQueries.order('readableAt', 'desc'));
    query.addAll(MDQueries.notIncludeFutureUpdates);

    return get(Uri.https(MDConstants.host, MDPaths.chapter, query));
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
      query.addAll(MDQueries.limit(MDConstants.latestChapterlimit));
      query.addAll(MDQueries.translatedLanguage(['en']));
      query.addAll(MDQueries.notIncludeFutureUpdates);
      query.addAll(MDQueries.order('chapter', 'asc'));

      final uri = Uri.https(MDConstants.host, MDPaths.chapter, query);
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
    final uri = Uri.https(MDConstants.host, MDPaths.server(id: chapter.id));
    final pagesData = jsonDecode((await get(uri)).body);

    for (int i = 0; i < chapter.pages; ++i) {
      final data = PageData(pagesData);
      pages.add(
          '${data.baseUrl}/data-saver/${data.hash}/${data.images['data-saver']![i]}');
    }

    return pages;
  }
}
