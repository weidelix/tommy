import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:system_theme/system_theme.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:navigation_history_observer/navigation_history_observer.dart';
import 'package:xview/custom_tabbed_view/custom_tabbed_view.dart';
import 'dart:async';

import 'package:xview/page/library.dart';
import 'package:xview/page/browse.dart';
import 'package:xview/page/history.dart';
import 'package:xview/page/settings.dart';
import 'package:xview/page/source.dart';

import 'package:xview/tabs.dart';
import 'package:xview/theme.dart';

const routeSubPageSuffix = 'Sub';
const routeLibrary = 'Library';
const routeHistory = 'History';
const routeBrowse = 'Browse';
const routeSettings = 'Settings';

// Browse routes
const routeBrowseSource = 'BrowseSub/Source';

// Settings routes
const routeSettingsGeneral = 'SettingsSub/General';
const routeSettingsPersonalization = 'SettingsSub/Personalization';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemTheme.accentInstance.load();
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

  final PageStorageBucket _bucket = PageStorageBucket();
  final pages = [
    RootPage(
        key: const PageStorageKey<String>('pageOne'),
        onChange: () {
          // setState(() {
          //   _canGoBack = true;
          // });
        }),
    ScaffoldPage(
      key: const PageStorageKey<String>('pageTwo'),
      content: Scrollbar(
          child: ListView(children: const [
        SizedBox(width: double.infinity, height: 2000)
      ])),
    )
    // ...tabs.tabs.map((e) => e.body)
  ];
  bool _canGoBack = false;
  Key uniqueKey = UniqueKey();

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TabsState()),
          ChangeNotifierProvider(create: (_) => SourceState()),
        ],
        builder: (context, _) {
          final tabs = context.watch<TabsState>();
          return Mica(
            child: Stack(
              children: [
                // ignore: sized_box_for_whitespace
                Container(
                    height: appWindow.titleBarHeight + 10, child: MoveWindow()),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  MinimizeWindowButton(colors: _buttonColors),
                  MaximizeWindowButton(colors: _buttonColors),
                  CloseWindowButton(colors: _closeButtonColors),
                ]),
                CustomTabView(
                    // TODO: Remove bucket
                    bucket: _bucket,
                    header: IconButton(
                        iconButtonMode: IconButtonMode.large,
                        icon: const Icon(fui.FluentIcons.arrow_left_24_filled),
                        onPressed: _canGoBack
                            ? () async {
                                _canGoBack = await RootNavigation().back();
                                context.read<SourceState>().reset();
                                setState(() => _canGoBack);
                              }
                            : null),
                    currentIndex: tabs.index,
                    onChanged: (value) {
                      tabs.index = value;
                    },
                    tabs: [
                      const Tab(
                          text: Text('Home'),
                          icon: Icon(fui.FluentIcons.home_24_regular, size: 14),
                          closeIcon: null),
                      ...tabs.tabs.map((e) => e.tab)
                    ],
                    bodies: [
                      RootPage(onChange: _onChange),
                      ...tabs.tabs.map((e) => e.body)
                    ]),
              ],
            ),
          );
        });
  }

  void _onChange() {
    // () {
    setState(() => _canGoBack = true);
    // }
  }
}

class RootPage extends StatefulWidget {
  const RootPage({required this.onChange, Key? key}) : super(key: key);

  final Function onChange;
  final rootIndices = const {
    routeLibrary: 0,
    routeBrowse: 1,
    routeHistory: 2,
    routeSettings: 3,
  };

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  late StreamSubscription<dynamic> listen;
  final ValueNotifier<String> _title = ValueNotifier<String>('');
  final List<int> _selectedHistory = [0];
  int _selected = 0;

  @override
  void dispose() {
    listen.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    listen = NavigationHistoryObserver().historyChangeStream.listen((change) {
      final HistoryChange data = (change as HistoryChange);
      late String name;

      if (data.action == NavigationStackAction.push) {
        name = data.newRoute!.settings.name!;
      } else if (data.action == NavigationStackAction.pop) {
        name = data.oldRoute!.settings.name!;
        _selected = _selectedHistory.last;
        if (!RootNavigation().currentRoute.contains(routeSubPageSuffix)) {
          _selectedHistory.removeLast();
          setState(() {
            _selected = _selectedHistory.last;
          });
        }
      }

      if (name.contains(routeSubPageSuffix)) {
        _title.value = name.substring(name.lastIndexOf('/') + 1);
      } else {
        _title.value = name;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
        contentShape: const RoundedRectangleBorder(),
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
              widget.onChange();
              setState(() {
                // _canGoBack = true;
                _selectedHistory.add(i);
                _selected = i;
              });
              switch (i) {
                case 0:
                  RootNavigation().push(routeLibrary);
                  break;
                case 1:
                  RootNavigation().push(routeBrowse);
                  break;
                case 2:
                  RootNavigation().push(routeHistory);
                  break;
                case 3:
                  RootNavigation().push(routeSettings);
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
            key: RootNavigation().rootNavigator,
            initialRoute: RootNavigation().currentRoute,
            onGenerateRoute: _onGenerateRoute,
            observers: [NavigationHistoryObserver()],
          ),
        ));
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
          bool rootToRoot =
              !RootNavigation().currentRoute.contains(routeSubPageSuffix) &&
                  !RootNavigation().previousRoute.contains(routeSubPageSuffix);

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
          bool rootToSub =
              RootNavigation().currentRoute.contains(routeSubPageSuffix) &&
                  !RootNavigation().previousRoute.contains(routeSubPageSuffix);

          bool subToRoot =
              !RootNavigation().currentRoute.contains(routeSubPageSuffix) &&
                  RootNavigation().previousRoute.contains(routeSubPageSuffix);

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

class RootNavigation {
  static final _instance = RootNavigation._();

  factory RootNavigation() {
    return _instance;
  }

  RootNavigation._() {
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

  final rootNavigator = GlobalKey<NavigatorState>();

  /// Returns true if the page after pop can pop
  Future<bool> back() async {
    await _instance.rootNavigator.currentState!.maybePop();
    return _instance.rootNavigator.currentState!.canPop();
  }

  void push(String route) {
    _instance.rootNavigator.currentState!.pushNamed(route);
  }
}

/*
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
import 'package:xview/page/settings.dart';
import 'package:xview/page/source.dart';

import 'package:xview/tabs.dart';
import 'package:xview/theme.dart';

const routeSubPageSuffix = 'Sub';
const routeLibrary = 'Library';
const routeHistory = 'History';
const routeBrowse = 'Browse';
const routeSettings = 'Settings';

// Browse routes
const routeBrowseSource = 'BrowseSub/Source';

// Settings routes
const routeSettingsGeneral = 'SettingsSub/General';
const routeSettingsPersonalization = 'SettingsSub/Personalization';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemTheme.accentInstance.load();
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

  bool _canGoBack = false;
  Key uniqueKey = UniqueKey();

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TabsState()),
          ChangeNotifierProvider(create: (_) => SourceState()),
        ],
        builder: (context, _) {
          final tabs = context.watch<TabsState>();
          return Mica(
            child: Stack(
              children: [
                // ignore: sized_box_for_whitespace
                Container(
                    height: appWindow.titleBarHeight + 10, child: MoveWindow()),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  MinimizeWindowButton(colors: _buttonColors),
                  MaximizeWindowButton(colors: _buttonColors),
                  CloseWindowButton(colors: _closeButtonColors),
                ]),
                TabView(
                    header: IconButton(
                        iconButtonMode: IconButtonMode.large,
                        icon: const Icon(fui.FluentIcons.arrow_left_24_filled),
                        onPressed: _canGoBack
                            ? () async {
                                _canGoBack = await RootNavigation().back();
                                context.read<SourceState>().reset();
                              }
                            : null),
                    currentIndex: tabs.index,
                    onChanged: (value) {
                      // setState(() => _canGoBack = true);
                      _canGoBack = true;
                      tabs.index = value;
                    },
                    tabs: const [
                      Tab(
                          text: Text('Home'),
                          icon: Icon(fui.FluentIcons.home_24_regular, size: 14),
                          closeIcon: null),
                      Tab(
                          text: Text('Dummy'),
                          icon: Icon(fui.FluentIcons.home_24_regular, size: 14),
                          closeIcon: null)
                      // ...tabs.tabs.map((e) => e.tab)
                    ],
                    bodies: [
                      RootPage(key: uniqueKey),
                      const ScaffoldPage(
                        content: Center(child: ProgressRing()),
                      )
                      // ...tabs.tabs.map((e) => e.body)
                    ]),
              ],
            ),
          );
        });
  }
}

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  final rootIndices = const {
    routeLibrary: 0,
    routeBrowse: 1,
    routeHistory: 2,
    routeSettings: 3,
  };

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  late StreamSubscription<dynamic> listen;
  final ValueNotifier<String> _title = ValueNotifier<String>('');
  final List<int> _selectedHistory = [0];
  int _selected = 0;

  @override
  void dispose() {
    listen.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    listen = NavigationHistoryObserver().historyChangeStream.listen((change) {
      final HistoryChange data = (change as HistoryChange);
      late String name;

      if (data.action == NavigationStackAction.push) {
        name = data.newRoute!.settings.name!;
      } else if (data.action == NavigationStackAction.pop) {
        name = data.oldRoute!.settings.name!;
        _selected = _selectedHistory.last;
        if (!RootNavigation().currentRoute.contains(routeSubPageSuffix)) {
          _selectedHistory.removeLast();
          setState(() {
            _selected = _selectedHistory.last;
          });
        }
      }

      if (name.contains(routeSubPageSuffix)) {
        _title.value = name.substring(name.lastIndexOf('/') + 1);
      } else {
        _title.value = name;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
        contentShape: const RoundedRectangleBorder(),
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
                // _canGoBack = true;
                _selectedHistory.add(i);
                _selected = i;
              });
              switch (i) {
                case 0:
                  RootNavigation().push(routeLibrary);
                  break;
                case 1:
                  RootNavigation().push(routeBrowse);
                  break;
                case 2:
                  RootNavigation().push(routeHistory);
                  break;
                case 3:
                  RootNavigation().push(routeSettings);
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
            key: RootNavigation().rootNavigator,
            initialRoute: RootNavigation().currentRoute,
            onGenerateRoute: _onGenerateRoute,
            observers: [NavigationHistoryObserver()],
          ),
        ));
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
          bool rootToRoot =
              !RootNavigation().currentRoute.contains(routeSubPageSuffix) &&
                  !RootNavigation().previousRoute.contains(routeSubPageSuffix);

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
          bool rootToSub =
              RootNavigation().currentRoute.contains(routeSubPageSuffix) &&
                  !RootNavigation().previousRoute.contains(routeSubPageSuffix);

          bool subToRoot =
              !RootNavigation().currentRoute.contains(routeSubPageSuffix) &&
                  RootNavigation().previousRoute.contains(routeSubPageSuffix);

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

class RootNavigation {
  static final _instance = RootNavigation._();

  factory RootNavigation() {
    return _instance;
  }

  RootNavigation._() {
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

  final rootNavigator = GlobalKey<NavigatorState>();

  /// Returns true if the page after pop can pop
  Future<bool> back() async {
    await _instance.rootNavigator.currentState!.maybePop();
    return _instance.rootNavigator.currentState!.canPop();
  }

  void push(String route) {
    _instance.rootNavigator.currentState!.pushNamed(route);
  }
}

 */