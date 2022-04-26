import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

import 'package:xview/theme.dart';
import 'package:xview/page/source.dart';

const _routeBrowseHome = '/';
const _routeBrowseSource = '/source';

// TODO: Refactor
class BrowseState extends ChangeNotifier {
  String title = 'Browse';
  String _currentRoute = _routeBrowseHome;
  String get currentRoute => _currentRoute;
  set currentRoute(String value) {
    if (value == _routeBrowseHome) {
      navigatorKey.currentState!.pop();
    } else if (value == _routeBrowseSource) {
      navigatorKey.currentState!.pushNamed(_routeBrowseSource);
    }

    _currentRoute = value;
    notifyListeners();
  }

  final navigatorKey = GlobalKey<NavigatorState>();
}

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
    final browse = context.watch<BrowseState>();
    final source = context.read<SourceState>();

    return ScaffoldPage.withPadding(
        header: PageHeader(
            title: Row(children: [
          AnimatedSize(
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 150),
              child: browse.currentRoute != _routeBrowseHome
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
                              browse.currentRoute = _routeBrowseHome;
                            });
                          }),
                    )
                  : const SizedBox.shrink()),
          Text(browse.title, style: appTheme.title)
        ])),
        content: Navigator(
          key: browse.navigatorKey,
          initialRoute: browse._currentRoute,
          onGenerateRoute: _onGenerateRoute,
        ));
  }

  Route _onGenerateRoute(RouteSettings settings) {
    late Widget page;
    switch (settings.name) {
      case _routeBrowseHome:
        page = const BrowseHomePage();
        break;
      case _routeBrowseSource:
        page = const SourcePage();
        break;
    }

    return PageRouteBuilder(
        transitionDuration: FluentTheme.of(context).mediumAnimationDuration,
        reverseTransitionDuration: const Duration(milliseconds: 10),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          if (animation.status == AnimationStatus.forward) {
            return FadeTransition(
                opacity: animation,
                child:
                    SlideTransition(position: offsetAnimation, child: child));
          }

          return FadeTransition(
              opacity: Tween(begin: 1.0, end: 0.0).animate(secondaryAnimation),
              child: child);
        });
  }
}

class BrowseHomePage extends StatefulWidget {
  const BrowseHomePage({Key? key}) : super(key: key);

  @override
  State<BrowseHomePage> createState() => _BrowseHomePageState();
}

class _BrowseHomePageState extends State<BrowseHomePage> {
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
    final browse = context.read<BrowseState>();
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
                                        // index = 1;
                                        browse.title = widget.title;
                                        browse.currentRoute =
                                            _routeBrowseSource;
                                        source.activeSource =
                                            source.sources[widget.title]!;
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