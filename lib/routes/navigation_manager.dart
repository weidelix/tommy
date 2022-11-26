import 'package:xview/constants/route_names.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';

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
    if (route == _currentRoute) return;

    if (route.contains('Manga')) {
      _instance.rootToMangaNavigator.currentState!
          .pushNamed(route, arguments: arguments);
      return;
    }

    _instance.mainNavigator.currentState!
        .pushNamed(route, arguments: arguments);
  }
}
