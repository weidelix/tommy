import 'package:xview/sources/MangaDex/md_constants.dart';

class PageData {
  PageData(dynamic data)
      : baseUrl = data['baseUrl'],
        hash = data['chapter']['hash'],
        images = {
          'data': data['chapter']['data'],
          'data-saver': data['chapter']['dataSaver']
        };

  final String baseUrl;
  final String hash;
  final Map<String, List<dynamic>> images;
}

abstract class MDHelper {
  static String toCoverUrl(id, fileName) {
    return 'https://${MDDomains.uploads}/covers/$id/$fileName.256.jpg';
  }

  static String toServerUri(String chapterId) {
    return Uri.https(MDDomains.api, '${MDPaths.server}/$chapterId').toString();
  }

  static String toMangaUri(String mangaId) {
    return Uri.https(MDDomains.api, '${MDPaths.manga}/$mangaId').toString();
  }

  static String toChapterUri(Map<String, dynamic> query) {
    return Uri.https(MDDomains.api, MDPaths.chapter, query).toString();
  }

  static String getChapterId(String url) {
    return url.split('/').last;
  }

  static String getMangaId(String url) {
    return url.split('/').last;
  }
}
