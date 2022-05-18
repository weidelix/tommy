import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:xview/main.dart';

import 'package:xview/theme.dart';
import 'package:xview/page/source.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({Key? key}) : super(key: key);

  @override
  _BrowsePageState createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();

    return ListView(
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
              title: 'MangaDex')
        ]),
      ],
    );
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
    final appTheme = context.read<AppTheme>();

    return Mica(
      elevation: 10,
      borderRadius: appTheme.brInner,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 150,
          width: 250,
          child: FutureBuilder<PaletteGenerator>(
            future: PaletteGenerator.fromImageProvider(widget.icon.image),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const SizedBox.expand();
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
                                          backgroundColor: ButtonState
                                              .resolveWith((states) =>
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
                                        source.activeSource =
                                            source.sources[widget.title]!;
                                        NavigationManager()
                                            .push(routeBrowseSource);
                                      }),
                                ),
                                const SizedBox(width: 8.0),
                                IconButton(
                                    icon: const Icon(
                                        fui.FluentIcons.settings_24_regular,
                                        size: 20),
                                    onPressed: () {})
                              ],
                            ),
                          ]),
                    );
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
