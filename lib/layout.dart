import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;

import 'package:xview/constants/route_names.dart';
import 'package:xview/root.dart';
import 'package:xview/routes/manga/manga.dart';
import 'package:xview/routes/manga/manga_reader.dart';
import 'package:xview/routes/navigation_manager.dart';
import 'package:xview/sources/manga_source.dart';
import 'package:xview/sources/source_provider.dart';
import 'package:xview/theme.dart';

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
        create: (_) => SourceProvider(),
        builder: (context, _) {
          return Mica(
              child: Stack(children: [
            SizedBox(
              height: appWindow.titleBarHeight + 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, left: 6.0),
                    child: ValueListenableBuilder(
                      valueListenable: _canGoBack,
                      builder: (context, bool value, child) => IconButton(
                        icon: const Icon(fui.FluentIcons.arrow_left_24_regular,
                            size: 14),
                        style: ButtonStyle(
                            padding: ButtonState.all(const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 10.0)),
                            backgroundColor: ButtonState.resolveWith((states) {
                              final brightness =
                                  FluentTheme.of(context).brightness;
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
                  Align(
                    alignment: Alignment.center,
                    child: Text('Tommy',
                        textAlign: TextAlign.center, style: appTheme.caption),
                  ),
                  Expanded(
                    child: MoveWindow(),
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
            ),
            Padding(
              padding: EdgeInsets.only(top: appWindow.titleBarHeight + 12),
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

      case routeMangaRead:
        page = MangaReaderPage(chapter: settings.arguments as Chapter);
        break;
    }

    return createPageAnimation(page, settings);
  }

  Route createPageAnimation(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
        maintainState: settings.name == routeRoot ? true : false,
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
