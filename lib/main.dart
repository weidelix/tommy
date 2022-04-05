import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:system_theme/system_theme.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as acrylic;
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;

import 'package:xview/page/library.dart';
import 'package:xview/page/browse.dart';
import 'package:xview/page/history.dart';
import 'package:xview/page/settings.dart';
import 'package:xview/page/source.dart';

import 'package:xview/tabs.dart';
import 'package:xview/theme.dart';

const routeHome = '/';

// TODO: Refactor navigation

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await acrylic.Window.initialize();
  await SystemTheme.accentInstance.load();
  runApp(const MyApp());

  doWhenWindowReady(() async {
    // await acrylic.Window.setEffect(
    //   effect: acrylic.WindowEffect.acrylic,
    //   color: const Color(0xCC222222),
    // );
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
            // onGenerateRoute: (config) {
            //   late Widget page;
            //   if (config.name == routeHome) {
            //     page = const MyHomePage();
            //     // } else if (settings.name == routeSettings) {
            //     //   page = const SettingsScreen();
            //     // } else if (settings.name!.startsWith(routePrefixDeviceSetup)) {
            //     //   final subRoute =
            //     //       settings.name!.substring(routePrefixDeviceSetup.length);
            //     //   page = SetupFlow(
            //     //     setupPageRoute: subRoute,
            //     //   );
            //   } else {
            //     throw Exception('Unknown route: ${config.name}');
            //   }

            //   return FluentPageRoute<dynamic>(
            //     builder: (context) {
            //       return page;
            //     },
            //     settings: config,
            //   );
            // },
            darkTheme: ThemeData(
              animationCurve: Curves.easeInOut,
              typography: appTheme.typography.apply(displayColor: Colors.white),
              // activeColor: Colors.blue,
              // micaBackgroundColor: Colors.transparent,
              // scaffoldBackgroundColor: Colors.transparent,

              // theme
              // cardColor: Colors.blue,
              // micaBackgroundColor: Colors.blue,
              // menuColor: Colors.blue,
              // activeColor: Color.fromARGB(255, 44, 38, 68),
              // inactiveBackgroundColor: Color.fromARGB(255, 44, 38, 68),
              // chipTheme: ,
              // borderInputColor: const Color.fromARGB(255, 1, 26, 39),
              // micaBackgroundColor: const Color.fromARGB(255, 1, 26, 39),
              // scaffoldBackgroundColor: const Color.fromARGB(255, 6, 56, 82),
              // buttonTheme: ButtonThemeData(
              // defaultButtonStyle: ButtonStyle(
              // backgroundColor: ButtonState.all(
              // const Color.fromARGB(255, 1, 26, 39)))),
              visualDensity: VisualDensity.standard,
              fontFamily: appTheme.fontFamily,
              accentColor: appTheme.accentColorPrimary,
              brightness: Brightness.dark,
            ),
            theme: ThemeData(
                animationCurve: Curves.easeInOut,
                typography:
                    appTheme.typography.apply(displayColor: Colors.black),
                visualDensity: VisualDensity.standard,
                fontFamily: appTheme.fontFamily,
                accentColor: appTheme.accentColorPrimary,
                brightness: Brightness.light),
            home: const MyHomePage(),
            debugShowCheckedModeBanner: false,
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selected = 0;
  int _prevSelected = 0;

  final buttonColors = WindowButtonColors(
      iconNormal: const Color.fromARGB(255, 145, 145, 145),
      mouseOver: const Color.fromARGB(43, 117, 117, 117),
      mouseDown: const Color.fromARGB(59, 117, 117, 117),
      iconMouseOver: Colors.white,
      iconMouseDown: Colors.white);

  final closeButtonColors = WindowButtonColors(
      mouseOver: const Color(0xFFD32F2F),
      mouseDown: const Color(0xFFB71C1C),
      iconNormal: const Color.fromARGB(255, 145, 145, 145),
      iconMouseOver: Colors.white);

  final library = const LibraryPage();
  final browse = const BrowsePage();
  final history = const HistoryPage();
  final settings = const SettingsPage();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Mica(
      child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => TabsState()),
            ChangeNotifierProvider(create: (_) => BrowseState()),
            ChangeNotifierProvider(create: (_) => SourceState()),
          ],
          builder: (context, _) {
            final tabs = context.watch<TabsState>();

            return Stack(
              children: [
                SizedBox(height: appWindow.titleBarHeight, child: MoveWindow()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [
                    // Opacity(
                    //   opacity: 0.8,
                    //   child: IconButton(
                    //       icon: const Icon(
                    //           fui.FluentIcons.arrow_left_24_regular,
                    //           size: 14),
                    //       onPressed: () {}),
                    // ),
                    // gapWidth(),
                    const Text('Dice')
                  ]),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  MinimizeWindowButton(colors: buttonColors),
                  MaximizeWindowButton(colors: buttonColors),
                  CloseWindowButton(colors: closeButtonColors),
                ]),
                Padding(
                  padding: EdgeInsets.only(top: appWindow.titleBarHeight + 10),
                  child: TabView(
                      currentIndex: tabs.index,
                      onChanged: (value) => tabs.index = value,
                      tabs: [
                        const Tab(
                            text: Text('Home'),
                            icon:
                                Icon(fui.FluentIcons.home_24_regular, size: 14),
                            closeIcon: null),
                        ...tabs.tabs.map((e) => e.tab)
                      ],
                      bodies: [
                        NavigationView(
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
                                _prevSelected = _selected;
                                setState(() => _selected = i);
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
                                            : fui
                                                .FluentIcons.library_24_regular,
                                        size: 20),
                                    title: const Text(
                                      'Library',
                                    )),
                                PaneItem(
                                    icon: Icon(
                                        _selected == 1
                                            ? fui.FluentIcons
                                                .compass_northwest_24_filled
                                            : fui.FluentIcons
                                                .compass_northwest_24_regular,
                                        size: 20),
                                    title: const Text('Browse')),
                                PaneItem(
                                    icon: Icon(
                                        _selected == 2
                                            ? fui.FluentIcons.history_24_filled
                                            : fui
                                                .FluentIcons.history_24_regular,
                                        size: 20),
                                    title: const Text('History')),
                              ],
                              footerItems: [
                                PaneItem(
                                    icon: Icon(
                                        _selected == 3
                                            ? fui.FluentIcons.settings_24_filled
                                            : fui.FluentIcons
                                                .settings_24_regular,
                                        size: 20),
                                    title: const Text('Settings'))
                              ],
                            ),
                            content: NavigationBody(
                                transitionBuilder: (child, animation) {
                                  return EntrancePageTransition(
                                      child: child,
                                      animation: animation,
                                      reverse: _prevSelected > _selected);
                                },
                                index: _selected,
                                children: [
                                  library,
                                  browse,
                                  history,
                                  settings
                                ])),
                        // tabs
                        ...tabs.tabs.map((e) => e.body)
                      ]),
                ),
              ],
            );
          }),
    );
  }
}
