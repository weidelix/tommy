import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import 'package:xview/theme.dart';
import 'package:xview/sources/source_provider.dart';
import 'package:xview/routes/navigation_manager.dart';
import 'package:xview/constants/route_names.dart';
import 'package:xview/utils/utils.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({Key? key}) : super(key: key);

  @override
  BrowsePageState createState() => BrowsePageState();
}

class BrowsePageState extends State<BrowsePage> {
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
            style: appTheme.bodyStrong,
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
    final source = context.read<SourceProvider>();
    final appTheme = context.read<AppTheme>();

    return Card(
      padding: const EdgeInsets.all(16.0),
      borderRadius: appTheme.brOuter,
      child: SizedBox(
        height: 150,
        width: 250,
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
                        Text(widget.title, style: appTheme.subtitle),
                      ]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: FilledButton(
                        child: const Text('Browse'),
                        onPressed: () {
                          source.activeSource = source.sources[widget.title]!;
                          NavigationManager().push(routeBrowseSource, context);
                        }),
                  ),
                  gapWidth(8.0),
                  IconButton(
                      icon: const Icon(fui.FluentIcons.globe_24_regular,
                          size: 20),
                      onPressed: () {}),
                  IconButton(
                      icon: const Icon(fui.FluentIcons.settings_24_regular,
                          size: 20),
                      onPressed: () {})
                ],
              ),
            ]),
      ),
    );
  }
}
