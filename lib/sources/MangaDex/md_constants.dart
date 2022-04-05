abstract class MDPaths {
  static const manga = '/manga';
  static const chapter = '/chapter';
}

abstract class MDQueries {
  static Map<String, dynamic> manga(String manga) => {'manga': manga};
  static Map<String, dynamic> offset(int page) => {'offset': page.toString()};
  static Map<String, dynamic> limit(int limit) => {'limit': limit.toString()};
  static Map<String, List<dynamic>> includes(List<String> includes) =>
      {'includes[]': includes};
  static Map<String, List<dynamic>> contentRating(List<String> ratings) =>
      {'contentRating[]': ratings};
  static Map<String, List<dynamic>> originalLanguage(List<String> language) =>
      {'originalLanguage[]': language};
  static Map<String, List<dynamic>> translatedLanguage(List<String> language) =>
      {'translatedLanguage[]': language};
  static Map<String, List<dynamic>> ids(List<dynamic> ids) => {'ids[]': ids};

  static Map<String, dynamic> order(String option, String order) =>
      {'order[$option]': order};
  static const notIncludeFutureUpdates = {'includeFutureUpdates': '0'};
}

abstract class MDConstants {
  static const host = 'api.mangadex.org';
  static const limit = 35;
  static const latestChapterlimit = 100;
  static String coverUri({required String id, required String fileName}) =>
      'https://uploads.mangadex.org/covers/$id/$fileName.256.jpg';
}
