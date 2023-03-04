import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:provider/provider.dart';
import 'package:xview/constants/route_names.dart';
import 'package:xview/manga_manager.dart';
import 'package:xview/routes/navigation_manager.dart';
import 'package:xview/sources/manga_source.dart';
import 'package:xview/sources/manga_updater.dart';
import 'package:xview/theme.dart';
import 'package:xview/user_preference.dart';
import 'package:xview/utils/utils.dart';
import 'package:xview/widgets/manga_item.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final controller = ScrollController();
  late List<Manga> mangas = [];
  late Map<String, bool?> filter = {};

  @override
  void initState() {
    filter = UserPreference().filter;
    _sort(UserPreference().sort);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SizedBox(
                width: 250,
                child: TextBox(
                    placeholder: 'Search',
                    onChanged: (value) {
                      setState(() {
                        mangas = MangaManager()
                            .mangas
                            .where((e) => e.title
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    })),
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(borderRadius: appTheme.brInner),
              child: OutlinedButton(
                onPressed: () {
                  showMangaUpdater(context);
                },
                style: ButtonStyle(
                    border: ButtonState.all(BorderSide.none),
                    padding: ButtonState.all(const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 10.0)),
                    backgroundColor: ButtonState.resolveWith((states) {
                      final brightness = FluentTheme.of(context).brightness;
                      late Color color;
                      if (brightness == Brightness.light) {
                        if (states.isPressing) {
                          color = const Color(0xFFf2f2f2);
                        } else if (states.isHovering) {
                          color = const Color(0xFFF6F6F6);
                        } else {
                          color = Colors.white.withOpacity(0.0);
                        }
                        return color;
                      } else {
                        if (states.isPressing) {
                          color = const Color(0xFF272727);
                        } else if (states.isHovering) {
                          color = const Color(0xFF323232);
                        } else {
                          color = Colors.black.withOpacity(0.0);
                        }
                        return color;
                      }
                    })),
                child: Row(children: [
                  Icon(fui.FluentIcons.arrow_sync_24_filled,
                      size: 20, color: appTheme.accentColorSecondary),
                  gapWidth(8.0),
                  const Text('Update library'),
                ]),
              ),
            ),
            // Row(children: [
            //   gapWidth(8.0),
            //   _filterDialogBuilder(context),
            //   gapWidth(8.0),
            //   _sortDialogBuilder(context)
            // ])
          ]),
        ),
        Expanded(
          child: mangas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('ᕕ( ╯°□° )ᕗ', style: appTheme.titleLarge),
                      gapHeight(),
                      Text('No manga found.', style: appTheme.subtitle),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.only(right: 4.0),
                  controller: controller,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      mainAxisSpacing: 30.0,
                      crossAxisSpacing: 24.0,
                      maxCrossAxisExtent: 150.0,
                      mainAxisExtent: 225.0 + 40),
                  itemCount: mangas.length,
                  itemBuilder: (context, count) => MangaItem(
                        manga: mangas[count],
                        onPressed: () => NavigationManager()
                            .push(routeManga, mangas[count])
                            .then((value) => setState(() {})),
                      )),
        ),
      ],
    );
  }

  Widget _filterDialogBuilder(BuildContext context) {
    return DropDownButton(
        closeAfterClick: false,
        title: const Text('Filter'),
        items: [
          _flyoutItemBuilder('Completed'),
          _flyoutItemBuilder('Unread'),
          _flyoutItemBuilder('Downloaded'),
          _flyoutItemBuilder('Started')
        ]);
  }

  MenuFlyoutItem _flyoutItemBuilder(String title) {
    return MenuFlyoutItem(
        text: Text(title),
        onPressed: () {},
        leading: StatefulBuilder(
          builder: (context, change) => Checkbox(
            checked: UserPreference().filter[title],
            onChanged: (v) {
              change(() {
                UserPreference().filter[title] = (v == true
                    ? true
                    : v == false
                        ? null
                        : v == null
                            ? false
                            : true);
                UserPreference().save();
              });
            },
          ),
        ));
  }

  Widget _sortDialogBuilder(BuildContext context) {
    final appTheme = context.read<AppTheme>();

    return DropDownButton(
        title: Row(
          children: [
            const Text('Sort by:'),
            Text(' ${UserPreference().sort}',
                style: TextStyle(
                    color: appTheme.accentColorSecondary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        items: [
          MenuFlyoutItem(
            onPressed: () {
              setState(() {
                UserPreference().sort = 'A-Z';
                _sort(UserPreference().sort);
              });
            },
            text: const Text('A-Z'),
          ),
          MenuFlyoutItem(
            onPressed: () {
              setState(() {
                UserPreference().sort = 'Z-A';
                _sort(UserPreference().sort);
              });
            },
            text: const Text('Z-A'),
          ),
          MenuFlyoutItem(
            onPressed: () {
              setState(() {
                UserPreference().sort = 'Source';
                _sort(UserPreference().sort);
              });
            },
            text: const Text('Source'),
          ),
        ]);
  }

  void _sort(String sortMethod) {
    switch (sortMethod) {
      case 'A-Z':
        mangas = MangaManager().mangas
          ..sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Z-A':
        mangas = MangaManager().mangas
          ..sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'Source':
        mangas = MangaManager().mangas
          ..sort((a, b) => a.source.compareTo(b.source));
        break;
    }
  }
}
