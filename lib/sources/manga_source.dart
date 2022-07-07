class Manga {
  Manga(
      {required this.id,
      required this.title,
      required this.cover,
      required this.source,
      this.authors,
      this.description,
      this.status});

  String id;
  String title;
  String cover;
  String source;
  String? authors;
  String? description;
  String? status;
  bool hasCompleteData = false;

  List<Chapter> chapters = [];
}

class Chapter {
  Chapter(
      {required this.id,
      required this.title,
      required this.uploader,
      required this.chapter,
      required this.dateUploaded,
      required this.scanlationGroup,
      required this.pages});

  final String id;
  final String title;
  final String uploader;
  final String chapter;
  final String dateUploaded;
  final String scanlationGroup;
  final int pages;
  bool isRead = false;
}

abstract class MangaSource {
  String title = 'Source';
  Future<List<Manga>> latestUpdatesRequest([int page = 1]);
  Future<List<Chapter>> fetchChapters(String id);
  Future<List<String>> readChapter(Chapter chapter);
  Future<void> getFullMangaData(Manga manga) async {
    manga.hasCompleteData = true;
  }
}