import 'dart:async';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';
import 'package:provider/provider.dart';

import 'package:xview/constants/route_names.dart';
import 'package:xview/routes/browse.dart';
import 'package:xview/routes/history.dart';
import 'package:xview/routes/library.dart';
import 'package:xview/routes/navigation_manager.dart';
import 'package:xview/routes/settings.dart';
import 'package:xview/routes/source.dart';
import 'package:xview/sources/source_provider.dart';

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

  late Widget nav = ScaffoldPage.withPadding(
    header: PageHeader(
        title: ValueListenableBuilder(
            valueListenable: _title,
            builder: (content, title, child) => Text(title as String))),
    content: Navigator(
        key: NavigationManager().mainNavigator,
        initialRoute: routeLibrary,
        onGenerateRoute: _onGenerateRoute,
        observers: [NavigationHistoryObserver()]),
  );

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

      _title.value = context.read<SourceProvider>().activeSource.title;
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
        paneBodyBuilder: (selectedPaneItemBody) => nav,
        transitionBuilder: (child, animation) => child,
        pane: NavigationPane(
          displayMode: PaneDisplayMode.compact,
          selected: _selected,
          onChanged: (i) {
            if (i != _selected) {
              setState(() {
                _selectedHistory.add(i);
                _selected = i;
              });
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
                title: const Text('Library'),
                body: const SizedBox.shrink(),
                onTap: () => NavigationManager().push(routeLibrary)),
            PaneItem(
                icon: Icon(
                    _selected == 1
                        ? fui.FluentIcons.compass_northwest_24_filled
                        : fui.FluentIcons.compass_northwest_24_regular,
                    size: 20),
                title: const Text('Browse'),
                body: const SizedBox.shrink(),
                onTap: () => NavigationManager().push(routeBrowse)),
            PaneItem(
                icon: Icon(
                    _selected == 2
                        ? fui.FluentIcons.history_24_filled
                        : fui.FluentIcons.history_24_regular,
                    size: 20),
                title: const Text('History'),
                body: const SizedBox.shrink(),
                onTap: () => NavigationManager().push(routeHistory)),
          ],
          footerItems: [
            PaneItem(
                icon: Icon(
                    _selected == 3
                        ? fui.FluentIcons.settings_24_filled
                        : fui.FluentIcons.settings_24_regular,
                    size: 20),
                title: const Text('Settings'),
                body: const SizedBox.shrink(),
                onTap: () => NavigationManager().push(routeSettings)),
          ],
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
        page = const SettingsAbout();
        break;
      case routeSettingsPersonalization:
        page = const SettingsPersonalization();
        break;
      case routeSettingsAbout:
        page = const SettingsAbout();
        break;
      // Browse
      case routeBrowseSource:
        page = const SourcePage();
        break;
    }

    if (!settings.name!.contains(routeSubPageSuffix)) {
      return _createRootPage(page, settings);
    }

    return _createSubPage(page, settings);
  }

  Route _createRootPage(Widget page, RouteSettings settings) {
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
          // and enter animation when popping page
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

  Route _createSubPage(Widget page, RouteSettings settings) {
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
