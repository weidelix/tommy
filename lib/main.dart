import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:system_theme/system_theme.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:navigation_history_observer/navigation_history_observer.dart';
import 'dart:async';

import 'package:xview/page/library.dart';
import 'package:xview/page/browse.dart';
import 'package:xview/page/history.dart';
import 'package:xview/page/manga/manga.dart';
import 'package:xview/page/settings.dart';
import 'package:xview/page/source.dart';
import 'package:xview/sources/manga_source.dart';
import 'package:xview/theme.dart';

const routeRoot = 'Root';
const routeManga = 'Manga';

// Root routes
const routeSubPageSuffix = 'Sub';
const routeLibrary = 'Library';
const routeHistory = 'History';
const routeBrowse = 'Browse';
const routeSettings = 'Settings';

// Browse routes
const routeBrowseSource = 'BrowseSub/Source';

// Manga routes
const routeMangaHome = 'MangaSub/Home';
const routeMangaRead = 'MangaSub/Read';

// Settings routes
const routeSettingsGeneral = 'SettingsSub/General';
const routeSettingsPersonalization = 'SettingsSub/Personalization';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemTheme.accentColor.load();

  runApp(const MyApp());
  doWhenWindowReady(() async {
    const initialSize = Size(1280, 720);
    appWindow.title = 'Dice';
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => AppTheme(),
        builder: (context, _) {
          final appTheme = context.watch<AppTheme>();

          return FluentApp(
            title: 'Dice',
            themeMode: appTheme.mode,
            darkTheme: ThemeData(
              animationCurve: Curves.easeInOutCubic,
              typography: appTheme.typography.apply(displayColor: Colors.white),
              visualDensity: VisualDensity.standard,
              fontFamily: appTheme.fontFamily,
              accentColor: appTheme.accentColorPrimary,
              brightness: Brightness.dark,
            ),
            theme: ThemeData(
                animationCurve: Curves.easeInOutCubic,
                typography:
                    appTheme.typography.apply(displayColor: Colors.black),
                visualDensity: VisualDensity.standard,
                fontFamily: appTheme.fontFamily,
                accentColor: appTheme.accentColorPrimary,
                brightness: Brightness.light),
            home: const Layout(),
            debugShowCheckedModeBanner: false,
          );
        });
  }
}

class Layout extends StatefulWidget {
  const Layout({Key? key}) : super(key: key);

  final rootIndices = const {
    routeLibrary: 0,
    routeBrowse: 1,
    routeHistory: 2,
    routeSettings: 3,
  };

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final _buttonColors = WindowButtonColors(
      iconNormal: const Color.fromARGB(255, 145, 145, 145),
      mouseOver: const Color.fromARGB(43, 117, 117, 117),
      mouseDown: const Color.fromARGB(59, 117, 117, 117),
      iconMouseOver: Colors.white,
      iconMouseDown: Colors.white);

  final _closeButtonColors = WindowButtonColors(
      mouseOver: const Color(0xFFD32F2F),
      mouseDown: const Color(0xFFB71C1C),
      iconNormal: const Color.fromARGB(255, 145, 145, 145),
      iconMouseOver: Colors.white);

  final _canGoBack = ValueNotifier<bool>(false);
  late StreamSubscription<dynamic> listen;

  @override
  void initState() {
    listen = NavigationHistoryObserver().historyChangeStream.listen((_) {
      _canGoBack.value =
          NavigationManager().mainNavigator.currentState!.canPop();
    });
    super.initState();
  }

  @override
  void dispose() {
    listen.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();
    return ChangeNotifierProvider(
        create: (_) => SourceState(),
        builder: (context, _) {
          return Mica(
              child: Stack(children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                  child: ValueListenableBuilder(
                    valueListenable: _canGoBack,
                    builder: (context, bool value, child) => IconButton(
                      icon: const Icon(fui.FluentIcons.arrow_left_24_regular,
                          size: 16),
                      style: ButtonStyle(
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
                      onPressed:
                          value ? () => NavigationManager().back() : null,
                    ),
                  ),
                ),
                gapWidth(16.0),
                Text('xView', style: appTheme.caption),
                Expanded(
                  // ignore: sized_box_for_whitespace
                  child: Container(
                    height: appWindow.titleBarHeight,
                    child: MoveWindow(),
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  MinimizeWindowButton(colors: _buttonColors),
                  WindowButton(
                    colors: _buttonColors,
                    iconBuilder: (buttonContext) => appWindow.isMaximized
                        ? RestoreIcon(color: buttonContext.iconColor)
                        : MaximizeIcon(color: buttonContext.iconColor),
                    onPressed: () => appWindow.maximizeOrRestore(),
                  ),
                  CloseWindowButton(colors: _closeButtonColors),
                ])
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: appWindow.titleBarHeight + 10),
              child: Navigator(
                key: NavigationManager().rootToMangaNavigator,
                onGenerateRoute: _onGenerateRoute,
                initialRoute: routeRoot,
              ),
            )
          ]));
        });
  }

  Route _onGenerateRoute(RouteSettings settings) {
    late Widget page;

    switch (settings.name) {
      case routeRoot:
        page = const RootPage();
        break;
      case routeManga:
        page = MangaPage(manga: settings.arguments as Manga);
        break;
    }

    return createPageAnimation(page, settings);
  }

  Route createPageAnimation(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
        maintainState: true,
        settings: settings,
        transitionDuration: FluentTheme.of(context).mediumAnimationDuration,
        reverseTransitionDuration:
            FluentTheme.of(context).mediumAnimationDuration,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurveTween(curve: Curves.easeInOutExpo);
          final tweenForward =
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(curve);

          if (animation.status == AnimationStatus.forward ||
              animation.status == AnimationStatus.reverse) {
            return SlideTransition(
                position: animation.drive(tweenForward), child: child);
          }

          return SlideTransition(
              position: Tween(begin: Offset.zero, end: const Offset(-1.0, 0.0))
                  .chain(curve)
                  .animate(secondaryAnimation),
              child: child);
        });
  }
}

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  late StreamSubscription<dynamic> listen;
  final _title = ValueNotifier<String>('');
  final List<int> _selectedHistory = [0];
  int _selected = 0;

  @override
  void initState() {
    listen = NavigationHistoryObserver().historyChangeStream.listen((change) {
      final HistoryChange data = (change as HistoryChange);
      String name = NavigationManager().currentRoute;

      if (data.action == NavigationStackAction.pop) {
        if (!NavigationManager().previousRoute.contains(routeSubPageSuffix)) {
          if (_selectedHistory.length > 1) _selectedHistory.removeLast();
          setState(() {
            _selected = _selectedHistory.last;
          });
        }
      }

      if (!name.contains(routeSubPageSuffix)) {
        _title.value = name;
        return;
      }

      if (!name.contains('Source')) {
        _title.value = name.substring(name.lastIndexOf('/') + 1);
        return;
      }

      _title.value = context.read<SourceState>().activeSource.title;
    });
    super.initState();
  }

  @override
  void dispose() {
    listen.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
        header: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Dice',
              textAlign: TextAlign.center,
            )),
        displayMode: PaneDisplayMode.compact,
        selected: _selected,
        onChanged: (i) {
          if (i != _selected) {
            setState(() {
              _selectedHistory.add(i);
              _selected = i;
            });
            switch (i) {
              case 0:
                NavigationManager().push(routeLibrary);
                break;
              case 1:
                NavigationManager().push(routeBrowse);
                break;
              case 2:
                NavigationManager().push(routeHistory);
                break;
              case 3:
                NavigationManager().push(routeSettings);
                break;
            }
          }
        },
        size: const NavigationPaneSize(
          openWidth: 250,
          openMinWidth: 200,
          openMaxWidth: 250,
        ),
        items: [
          PaneItem(
              icon: Icon(
                  _selected == 0
                      ? fui.FluentIcons.library_24_filled
                      : fui.FluentIcons.library_24_regular,
                  size: 20),
              title: const Text(
                'Library',
              )),
          PaneItem(
              icon: Icon(
                  _selected == 1
                      ? fui.FluentIcons.compass_northwest_24_filled
                      : fui.FluentIcons.compass_northwest_24_regular,
                  size: 20),
              title: const Text('Browse')),
          PaneItem(
              icon: Icon(
                  _selected == 2
                      ? fui.FluentIcons.history_24_filled
                      : fui.FluentIcons.history_24_regular,
                  size: 20),
              title: const Text('History')),
        ],
        footerItems: [
          PaneItem(
              icon: Icon(
                  _selected == 3
                      ? fui.FluentIcons.settings_24_filled
                      : fui.FluentIcons.settings_24_regular,
                  size: 20),
              title: const Text('Settings'))
        ],
      ),
      content: ScaffoldPage.withPadding(
        header: PageHeader(
            title: ValueListenableBuilder(
                valueListenable: _title,
                builder: (content, title, child) => Text(title as String))),
        content: Navigator(
          key: NavigationManager().mainNavigator,
          initialRoute: routeLibrary,
          onGenerateRoute: _onGenerateRoute,
          observers: [NavigationHistoryObserver()],
        ),
      ),
    );
  }

  Route _onGenerateRoute(RouteSettings settings) {
    late Widget page;

    switch (settings.name) {
      // Root
      case routeLibrary:
        page = const LibraryPage();
        break;
      case routeBrowse:
        page = const BrowsePage();
        break;
      case routeHistory:
        page = const HistoryPage();
        break;
      case routeSettings:
        page = const SettingsPage();
        break;
      // Settings
      case routeSettingsGeneral:
        page = const SettingsGeneral();
        break;
      case routeSettingsPersonalization:
        page = const SettingsPersonalization();
        break;
      // Browse
      case routeBrowseSource:
        page = const SourcePage();
        break;
    }

    if (!settings.name!.contains(routeSubPageSuffix)) {
      return createRootPageAnimation(page, settings);
    }

    // return FluentPageRoute(builder: (context) => page);
    return createSubPageAnimation(page, settings);
  }

  Route createRootPageAnimation(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
        maintainState: false,
        settings: settings,
        transitionDuration: FluentTheme.of(context).mediumAnimationDuration,
        reverseTransitionDuration:
            FluentTheme.of(context).mediumAnimationDuration,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          bool rootToRoot = !NavigationManager()
                  .currentRoute
                  .contains(routeSubPageSuffix) &&
              !NavigationManager().previousRoute.contains(routeSubPageSuffix);

          final curve = CurveTween(
              curve: rootToRoot ? Curves.easeOutExpo : Curves.easeInOutCubic);
          final tweenForward = (rootToRoot
                  ? Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                  : Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero))
              .chain(curve);

          // Enter animation for pushing page
          // and exit animation when popping page
          if (animation.status == AnimationStatus.forward ||
              animation.status == AnimationStatus.reverse) {
            return FadeTransition(
              opacity:
                  Tween(begin: 0.0, end: 1.0).chain(curve).animate(animation),
              child: SlideTransition(
                  position: animation.drive(tweenForward), child: child),
            );
          }

          // Exit animation when pushing a new page
          // adnd enter animation when popping page
          return rootToRoot
              ? FadeTransition(
                  opacity: Tween(begin: 1.0, end: 0.0)
                      .chain(curve)
                      .animate(secondaryAnimation),
                  child: child)
              : FadeTransition(
                  opacity: Tween(begin: 1.0, end: 0.0)
                      .chain(curve)
                      .animate(secondaryAnimation),
                  child: SlideTransition(
                      position: secondaryAnimation.drive(Tween(
                              begin: Offset.zero, end: const Offset(-1.0, 0.0))
                          .chain(curve)),
                      child: child));
        });
  }

  Route createSubPageAnimation(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
        maintainState: false,
        settings: settings,
        transitionDuration: FluentTheme.of(context).mediumAnimationDuration,
        reverseTransitionDuration:
            FluentTheme.of(context).mediumAnimationDuration,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          bool rootToSub = NavigationManager()
                  .currentRoute
                  .contains(routeSubPageSuffix) &&
              !NavigationManager().previousRoute.contains(routeSubPageSuffix);

          bool subToRoot = !NavigationManager()
                  .currentRoute
                  .contains(routeSubPageSuffix) &&
              NavigationManager().previousRoute.contains(routeSubPageSuffix);

          final curve = CurveTween(curve: Curves.easeInOutExpo);
          final tweenForward =
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(curve);

          if (animation.status == AnimationStatus.forward ||
              animation.status == AnimationStatus.reverse) {
            return SlideTransition(
                position: animation.drive(tweenForward), child: child);
          }

          return SlideTransition(
              position: (subToRoot || rootToSub
                      ? Tween(begin: Offset.zero, end: const Offset(1.0, 0.0))
                      : Tween(begin: Offset.zero, end: const Offset(-1.0, 0.0)))
                  .chain(curve)
                  .animate(secondaryAnimation),
              child: child);
        });
  }
}

class NavigationManager {
  static final _instance = NavigationManager._();

  factory NavigationManager() {
    return _instance;
  }

  NavigationManager._() {
    NavigationHistoryObserver().historyChangeStream.listen((change) {
      final HistoryChange data = change;

      if (data.action == NavigationStackAction.pop) {
        _instance._previousRoute = _instance._currentRoute;
        _instance._currentRoute = data.oldRoute!.settings.name!;
        _instance._didPop = true;
      } else if (data.action == NavigationStackAction.push) {
        _instance._previousRoute = _instance._currentRoute;
        _instance._currentRoute = data.newRoute!.settings.name!;
        _instance._didPop = false;
      }
    });
  }

  String _previousRoute = routeLibrary;
  String get previousRoute => _previousRoute;
  String _currentRoute = routeLibrary;
  String get currentRoute => _currentRoute;
  bool _didPop = false;
  bool get didPop => _didPop;

  // For moving between root page and manga page
  final rootToMangaNavigator = GlobalKey<NavigatorState>();
  // For moving between pages inside root page
  final mainNavigator = GlobalKey<NavigatorState>();

  /// Returns true if the page after pop can pop
  Future<bool> back() async {
    if (_instance.rootToMangaNavigator.currentState!.canPop()) {
      await _instance.rootToMangaNavigator.currentState!.maybePop();
      return true;
    }

    await _instance.mainNavigator.currentState!.maybePop();
    return _instance.mainNavigator.currentState!.canPop();
  }

  void push(String route, [Object? arguments]) {
    if (route == routeManga) {
      _instance.rootToMangaNavigator.currentState!
          .pushNamed(route, arguments: arguments);
      return;
    }

    _instance.mainNavigator.currentState!
        .pushNamed(route, arguments: arguments);
  }
}
