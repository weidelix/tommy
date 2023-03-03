class Manga {
  Manga(
      {required this.url,
      required this.title,
      required this.cover,
      required this.source,
      this.authors,
      this.description,
      this.status});

  Manga.fromJSON(Map<String, dynamic> json)
      : url = json['url'],
        title = json['title'],
        cover = json['cover'],
        source = json['source'],
        authors = json['authors'],
        description = json['description'],
        status = json['status'],
        inLibrary = json['inLibrary'],
        tags =
            (json['tags'] as List<dynamic>).map((e) => e.toString()).toList(),
        chapters = (json['chapters'] as List<dynamic>)
            .map((e) => Chapter.fromJSON(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'url': url,
        'title': title,
        'cover': cover,
        'source': source,
        'authors': authors,
        'description': description,
        'status': status,
        'tags': tags,
        'inLibrary': inLibrary,
        'chapters': chapters.map((e) => e.toJson()).toList(),
      };

  String url;
  String title;
  String cover;
  String source;
  String? authors;
  String? description;
  String? status;
  String? lastRead;
  List<String> tags = [];
  List<Chapter> chapters = [];
  bool hasCompleteData = false;
  bool inLibrary = false;
}

class Chapter {
  Chapter(
      {required this.url,
      required this.title,
      required this.chapter,
      required this.dateUploaded,
      required this.pages,
      this.uploader,
      this.scanlationGroup});

  Chapter.fromJSON(Map<String, dynamic> json)
      : url = json['url'],
        title = json['title'],
        uploader = json['uploader'],
        chapter = json['chapter'],
        dateUploaded = json['dateUploaded'],
        pages = json['pages'],
        read = json['read'],
        scanlationGroup = json['scanlationGroup'];

  Map<String, dynamic> toJson() => {
        'url': url,
        'title': title,
        'uploader': uploader,
        'chapter': chapter,
        'dateUploaded': dateUploaded,
        'pages': pages,
        'read': read,
        'scanlationGroup': scanlationGroup,
      };

  final String url;
  final String title;
  final String chapter;
  final String dateUploaded;
  final int pages;
  String? uploader;
  String? scanlationGroup;
  bool read = false;
}

abstract class MangaSource {
  String title = 'Source';
  Future<List<Manga>> searchMangaRequest(String title);
  Future<List<Manga>> latestUpdatesRequest([int page = 1]);
  Future<List<Chapter>> fetchChapters(String url);
  Future<List<String>> readChapter(Chapter chapter);
  Future<void> getFullMangaData(Manga manga) async {
    manga.hasCompleteData = true;
  }
}
