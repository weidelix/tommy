import 'package:http/http.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import 'package:xview/tabs.dart';
import 'package:xview/theme.dart';

class Manga {
  Manga(
      {required this.id,
      required this.title,
      required this.source,
      required this.cover,
      required this.description,
      required this.status});

  String id;
  String title;
  String source;
  String cover;
  String description;
  String status;

  List<Chapter> chapters = [];
  // Future<List<Chapter>> Function()? fetchChapters;
}

class Chapter {
  Chapter(
      {required this.id,
      required this.title,
      required this.uploader,
      required this.chapter,
      required this.dateUploaded,
      required this.scanlationGroup});

  final String id;
  final String title;
  final String uploader;
  final String chapter;
  final String dateUploaded;
  final String scanlationGroup;
  bool isRead = false;
}

abstract class MangaSource {
  String title = 'Source';
  Future<List<Manga>> parseLatestUpdates(Future<Response> res);
  Future<Response> latestUpdatesRequest([int page = 1]);
  Future<List<Chapter>> fetchChapters(String id);
  // Future<Chapter> readChapter(Chapter chapter);
}

class MangaData {}

class MangaItem extends StatelessWidget {
  const MangaItem({
    required this.manga,
    Key? key,
  }) : super(key: key);

  final Manga manga;

  @override
  Widget build(BuildContext context) {
    final tabs = context.read<TabsState>();

    return SizedBox(
        width: 160,
        child: GestureDetector(
            onTap: () => tabs.openManga(manga),
            child: Column(
              children: [
                Container(
                    clipBehavior: Clip.hardEdge,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(4.0)),
                    child: Image.network(
                      manga.cover,
                      width: 160,
                      height: 240,
                      fit: BoxFit.cover,
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(manga.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 13)),
                ),
              ],
            )));
  }
}
