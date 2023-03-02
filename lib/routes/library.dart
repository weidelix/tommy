import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';
import 'package:provider/provider.dart';
import 'package:xview/constants/route_names.dart';
import 'package:xview/manga_manager.dart';
import 'package:xview/routes/navigation_manager.dart';
import 'package:xview/routes/source.dart';
import 'package:xview/sources/manga_source.dart';
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
