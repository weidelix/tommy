import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

import 'package:xview/theme.dart';
import 'package:xview/page/source.dart';

class BrowseState extends ChangeNotifier {
  String title = 'Browse';

  int _index = 0;
  int get index => _index;
  set index(int value) {
    _index = value;
    notifyListeners();
  }
}

class BrowsePage extends StatefulWidget {
  const BrowsePage({Key? key}) : super(key: key);

  @override
  _BrowsePageState createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  int index = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();
    final browse = context.watch<BrowseState>();
    final source = context.read<SourceState>();

    return ScaffoldPage.withPadding(
        header: PageHeader(
            title: Row(children: [
          AnimatedSize(
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 150),
              child: browse.index != 0
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                          icon: const Icon(
                            fui.FluentIcons.arrow_left_24_regular,
                            size: 20,
                          ),
                          onPressed: () {
                            source.reset();

                            setState(() {
                              browse.title = 'Browse';
                              browse.index = 0;
                            });
                          }),
                    )
                  : const SizedBox.shrink()),
          Text(browse.title, style: appTheme.title)
        ])),
        content: NavigationBody(
            transitionBuilder: (child, animation) {
              return EntrancePageTransition(
                  vertical: false,
                  child: child,
                  animation: animation,
                  reverse: browse.index == 0);
            },
            index: browse.index,
            children: [
              ListView(
                children: [
                  Opacity(
                    opacity: 0.8,
                    child: Text(
                      'Active',
                      style: appTheme.bodyStrongAccent,
                    ),
                  ),
                  gapHeight(),
                  Wrap(spacing: 16.0, children: [
                    SourceCard(
                        icon: Image.asset(
                          'assets/logo/MangaDex/64x64.png',
                          scale: 2.0,
                        ),
                        title: 'MangaDex'),
                    SourceCard(
                        icon: Image.asset(
                          'assets/logo/MangaSee/64x64.png',
                          scale: 2.0,
                        ),
                        title: 'MangaSee'),
                    SourceCard(
                        icon: Image.asset(
                          'assets/logo/Guya/64x64.png',
                          scale: 2.0,
                        ),
                        title: 'Guya')
                  ]),
                ],
              ),
              // SizedBox(height: 500, width: 500),
              const SourcePage()
            ]));
  }
}

class SourceCard extends StatefulWidget {
  const SourceCard({
    required this.icon,
    required this.title,
    Key? key,
  }) : super(key: key);

  final Image icon;
  final String title;

  @override
  State<SourceCard> createState() => _SourceCardState();
}

class _SourceCardState extends State<SourceCard> {
  @override
  Widget build(BuildContext context) {
    final source = context.read<SourceState>();
    final browse = context.read<BrowseState>();
    final appTheme = context.read<AppTheme>();

    return Card(
      // padding: EdgeInsets.zero,
      child: SizedBox(
        height: 150,
        width: 250,
        child: FutureBuilder<PaletteGenerator>(
          future: PaletteGenerator.fromImageProvider(widget.icon.image),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: ProgressRing());
              default:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Center(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    widget.icon,
                                    const SizedBox(width: 8.0),
                                    Text(widget.title,
                                        style: appTheme.subtitle),
                                  ]),
                            ),
                          ),
                          // const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: FilledButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            ButtonState.resolveWith((states) =>
                                                FilledButton.backgroundColor(
                                                    ThemeData(
                                                        accentColor: snapshot
                                                            .data!
                                                            .vibrantColor!
                                                            .color
                                                            .toAccentColor()),
                                                    states))),
                                    child: const Text('Latest'),
                                    onPressed: () {
                                      // index = 1;
                                      browse.index = 1;
                                      browse.title = widget.title;
                                      source.activeSource =
                                          source.sources[widget.title]!;
                                    }),
                              ),
                              const SizedBox(width: 8.0),
                              IconButton(
                                  icon: const Icon(
                                      fui.FluentIcons.settings_24_regular,
                                      size: 20),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (_) => ContentDialog(
                                              title: Text('Settings',
                                                  style: appTheme.subtitle),
                                              content: const SizedBox(
                                                  child:
                                                      Text('Oops, wala pa!')),
                                              actions: [
                                                FilledButton(
                                                    child: const Text('Apply'),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    }),
                                                Button(
                                                    child: const Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    })
                                              ],
                                            ));
                                  })
                            ],
                          ),
                        ]),
                  );
                }
            }
          },
        ),
      ),
    );
  }
}
