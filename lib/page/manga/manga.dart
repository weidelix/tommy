import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;

import 'package:xview/theme.dart';
import 'package:xview/sources/manga_source.dart';
import 'mangahome.dart';
import 'mangareader.dart';

const routeMangaHome = '/';
const routeMangaRead = '/read';

// TODO: Refactor chapter selection
// TODO: Auto hide commandbar
// TODO: Implement goto next and previous chapter
// TODO: Add page number
// TODO: Add flyout text to commandbar buttons

class MangaState extends ChangeNotifier {
  double homeScrollOffset = 0.0;
  double readerScrollOffset = 0.0;
  int chapterIndex = -1;

  String _currentRoute = routeMangaHome;
  String get currentRoute => _currentRoute;
  void setRoute(String route) {
    if (route == routeMangaHome) {
      navigatorKey.currentState!.pop();
    } else if (route == routeMangaRead) {
      navigatorKey.currentState!.pushNamed(routeMangaRead);
    }

    _currentRoute = route;
    notifyListeners();
  }

  final navigatorKey = GlobalKey<NavigatorState>();
}

class MangaPage extends StatefulWidget {
  const MangaPage({required this.manga, Key? key}) : super(key: key);

  final Manga manga;

  @override
  _MangaPageState createState() => _MangaPageState();
}

class _MangaPageState extends State<MangaPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _checkMemory();
    final mangaState = context.watch<MangaState>();
    return Mica(
      child: Navigator(
        key: mangaState.navigatorKey,
        initialRoute: mangaState.currentRoute,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route _onGenerateRoute(RouteSettings settings) {
    late Widget page;

    switch (settings.name) {
      case routeMangaHome:
        page = MangaHomePage(manga: widget.manga);
        break;
      case routeMangaRead:
        page = ReaderPage(manga: widget.manga);
        break;
    }

    return PageRouteBuilder(
        transitionDuration: FluentTheme.of(context).mediumAnimationDuration,
        reverseTransitionDuration:
            FluentTheme.of(context).mediumAnimationDuration,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final curve = CurveTween(curve: Curves.easeInOut);
          final tweenForward = Tween(begin: begin, end: end).chain(curve);

          if (animation.status == AnimationStatus.forward) {
            return SlideTransition(
                position: animation.drive(tweenForward),
                child: FadeTransition(
                    opacity: Tween(begin: 0.0, end: 1.0).animate(animation),
                    child: child));
          } else if (animation.status == AnimationStatus.reverse) {
            return SlideTransition(
                position: animation.drive(tweenForward),
                child: FadeTransition(
                    opacity: Tween(begin: 0.0, end: 1.0).animate(animation),
                    child: child));
          }

          return SlideTransition(
              position: Tween(begin: Offset.zero, end: const Offset(-1.0, 0.0))
                  .chain(curve)
                  .animate(secondaryAnimation),
              child: FadeTransition(
                  opacity:
                      Tween(begin: 1.0, end: 0.0).animate(secondaryAnimation),
                  child: child));
        });
  }

  void _checkMemory() {
    var imageCache = PaintingBinding.instance!.imageCache;
    if (imageCache!.currentSizeBytes >= 55 << 20) {
      imageCache.clear();
      imageCache.clearLiveImages();
    }
  }
}
