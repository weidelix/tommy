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
