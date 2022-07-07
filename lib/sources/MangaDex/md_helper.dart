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
    return 'https://' + MDBase.uploads + '/covers/$id/$fileName.256.jpg';
  }

  static Uri toServerUri(chapterId) {
    return Uri.https(MDBase.api, MDPaths.server + '/$chapterId');
  }
}
