import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;

import 'package:xview/constants/route_names.dart';
import 'package:xview/routes/navigation_manager.dart';
import 'package:xview/theme.dart';
import 'package:xview/utils/utils.dart';
import 'package:xview/sources/source_provider.dart';
import 'package:xview/widgets/manga_item.dart';

import '../sources/manga_source.dart';

class SourcePage extends StatefulWidget {
  const SourcePage({Key? key}) : super(key: key);

  @override
  State<SourcePage> createState() => _SourcePageState();
}

class _SourcePageState extends State<SourcePage> {
  final controller = ScrollController();
  bool _isLatest = true;
  String _query = '';
  List<Manga> _manga = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    checkMemory();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final source = context.read<SourceProvider>();
    final appTheme = context.read<AppTheme>();

    return WillPopScope(
      onWillPop: () async {
        source.reset();
        checkMemory();
        return true;
      },
      child: NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (notification) {
          WidgetsBinding.instance.addPostFrameCallback(_checkIfCanScroll);
          return true;
        },
        child: SizeChangedLayoutNotifier(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              source.scrollOffset = notification.metrics.pixels;

              if (notification.metrics.maxScrollExtent ==
                      notification.metrics.pixels &&
                  _isLatest) {
                if (source.isFinishedLoading) {
                  showSnackbar(
                      context,
                      SizedBox(
                        width: 120,
                        child: Mica(
                            borderRadius: appTheme.brOuter,
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Loading',
                                    style: appTheme.bodyStrong,
                                  ),
                                  gapWidth(8.0),
                                  const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: ProgressRing(strokeWidth: 2.5))
                                ],
                              ),
                            )),
                      ));
                  source.latestUpdates().whenComplete(() => setState(() {}));
                }
              }
              return true;
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0, left: 16.0),
                  child: Wrap(
                    spacing: 8.0,
                    children: [
                      SizedBox(
                        width: 250,
                        child: TextBox(
                            placeholder: "Search for manga",
                            onSubmitted: (value) => setState(() {
                                  _query = value;
                                  _isLatest = false;
                                })),
                      ),
                      ToggleButton(
                        checked: _isLatest,
                        child: const Text("Latest"),
                        onChanged: (value) => setState(() {
                          _isLatest = true;
                          // source.reset();
                        }),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: _isLatest
                        ? source.latestList.isEmpty
                            ? source.latestUpdates()
                            : null
                        : source.searchManga(_query),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              snapshot.error.toString(),
                              style: appTheme.bodyStrong,
                            ),
                            gapHeight(32),
                            IconButton(
                                icon: const Icon(
                                  fui.FluentIcons.arrow_clockwise_24_regular,
                                  size: 24,
                                ),
                                onPressed: () {
                                  setState(() {
                                    source.reset();
                                  });
                                }),
                            Text(
                              'Refresh',
                              style: appTheme.caption,
                            )
                          ],
                        ));
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return WillPopScope(
                          child: const Center(child: ProgressRing()),
                          onWillPop: () async {
                            source.reset();
                            return true;
                          },
                        );
                      }

                      if (_isLatest) {
                        _manga = source.latestList;
                      } else {
                        _manga = source.mangaSearchList;
                      }

                      WidgetsBinding.instance
                          .addPostFrameCallback(_checkIfCanScroll);
                      return GridView.builder(
                          padding:
                              const EdgeInsets.only(left: 16.0, right: 16.0),
                          controller: controller,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  mainAxisSpacing: 30.0,
                                  crossAxisSpacing: 24.0,
                                  maxCrossAxisExtent: 150.0,
                                  mainAxisExtent: 225.0 + 40),
                          itemCount: _manga.length,
                          itemBuilder: (context, count) => MangaItem(
                              manga: _manga[count],
                              onPressed: () => NavigationManager()
                                  .push(routeManga, _manga[count])
                                  .then((value) => setState(
                                        () {},
                                      ))));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkIfCanScroll(Duration timestamp) {
    if (controller.position.maxScrollExtent <= 0 && _isLatest) {
      final source = context.read<SourceProvider>();
      source.latestUpdates().whenComplete(() => setState(() {
            WidgetsBinding.instance.addPostFrameCallback(_checkIfCanScroll);
          }));
    }
  }
}
