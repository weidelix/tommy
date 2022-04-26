import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:xview/tabs.dart';
import 'package:xview/theme.dart';

const routeSettings = 'Settings';
const routeGeneral = 'General';
const routePersonalization = 'Personalization';

class SettingsState extends ChangeNotifier {
  final navigatorKey = GlobalKey<NavigatorState>();
  int depth = 0;
  String _currentRoute = routeSettings;
  String get currentRoute => _currentRoute;
  set currentRoute(String value) {
    _currentRoute = value;
    notifyListeners();
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();

    return ChangeNotifierProvider(
      create: (_) => SettingsState(),
      builder: (context, _) {
        final settings = context.watch<SettingsState>();

        return ScaffoldPage.withPadding(
          header: PageHeader(
            title: Row(children: [
              AnimatedSize(
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 150),
                  child: settings.depth != 0
                      ? Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                              icon: const Icon(
                                fui.FluentIcons.arrow_left_24_regular,
                                size: 20,
                              ),
                              onPressed: () {
                                settings.depth--;
                                settings.navigatorKey.currentState!.pop();

                                setState(() {
                                  settings.currentRoute = settings.depth == 0
                                      ? routeSettings
                                      : settings.currentRoute;
                                });
                              }),
                        )
                      : const SizedBox.shrink()),
              Text((settings.currentRoute), style: appTheme.title)
            ]),
          ),
          content: Navigator(
            key: settings.navigatorKey,
            initialRoute: routeSettings,
            onGenerateRoute: _onGenerateRoute,
          ),
        );
      },
    );
  }

  Route _onGenerateRoute(RouteSettings settings) {
    late Widget page;

    switch (settings.name) {
      case routeSettings:
        page = const SettingsOptions();
        break;
      case routeGeneral:
        page = const General();
        break;
      case routePersonalization:
        page = const Personalization();
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
}

class SettingsOptions extends StatefulWidget {
  const SettingsOptions({Key? key}) : super(key: key);

  @override
  State<SettingsOptions> createState() => _SettingsOptionsState();
}

class _SettingsOptionsState extends State<SettingsOptions> {
  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();
    final settings = context.read<SettingsState>();

    return Wrap(runSpacing: appTheme.itemSpacing, children: [
      // General
      navigationItemBuilder(
          context: context,
          title: 'General',
          subtitle: 'Max tab count & more',
          icon: const Icon(fui.FluentIcons.app_generic_24_regular, size: 21),
          cb: () {
            settings.depth++;
            settings.navigatorKey.currentState!.pushNamed(routeGeneral);
            setState(() {
              settings.currentRoute = routeGeneral;
            });
          }),
      // Personalization
      navigationItemBuilder(
          context: context,
          title: 'Personalization',
          subtitle: 'Dark mode & themes',
          icon: const Icon(fui.FluentIcons.paint_brush_24_regular, size: 21),
          cb: () {
            settings.depth++;
            settings.navigatorKey.currentState!.pushNamed(routePersonalization);
            setState(() {
              settings.currentRoute = routePersonalization;
            });
          }),
    ]);
  }
}

class General extends StatefulWidget {
  const General({Key? key}) : super(key: key);

  @override
  _GeneralState createState() => _GeneralState();
}

class _GeneralState extends State<General> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = context.read<TabsState>();

    return Wrap(runSpacing: 4.0, children: [
      // Text('Tabs', style: appTheme.bodyStrongAccent),
      itemBuilder(
          context: context,
          title: 'Max tab count',
          icon: const Icon(fui.FluentIcons.tabs_24_regular, size: 21),
          footer: SizedBox(
            width: 55,
            child: Combobox<int>(
                value: tabs.maxTabCount,
                items: const [
                  ComboboxItem<int>(child: Text('8'), value: 8),
                  ComboboxItem<int>(child: Text('12'), value: 12),
                  ComboboxItem<int>(child: Text('16'), value: 16),
                ],
                onChanged: (value) {
                  setState(() {
                    tabs.maxTabCount = value!;
                  });
                }),
          )),
      itemBuilder(
        context: context,
        title: 'Clear tabs on exit',
        icon: const Icon(fui.FluentIcons.delete_24_regular, size: 21),
        footer: ToggleSwitch(checked: true, onChanged: (value) {}),
      )
    ]);
  }
}

class Personalization extends StatefulWidget {
  const Personalization({Key? key}) : super(key: key);

  @override
  _PersonalizationState createState() => _PersonalizationState();
}

class _PersonalizationState extends State<Personalization> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();

    return Wrap(
      runSpacing: appTheme.itemSpacing,
      children: [
        itemBuilder(
          context: context,
          title: 'Dark mode',
          icon: const Icon(fui.FluentIcons.weather_moon_24_regular, size: 21),
          footer: SizedBox(
            width: 170,
            // height: 28,
            child: Combobox<ThemeMode>(
              comboboxColor: Colors.magenta,
              value: appTheme.mode,
              items: const [
                ComboboxItem<ThemeMode>(
                    child: Text('System default'), value: ThemeMode.system),
                ComboboxItem<ThemeMode>(
                    child: Text('Light'), value: ThemeMode.light),
                ComboboxItem<ThemeMode>(
                    child: Text('Dark'), value: ThemeMode.dark),
              ],
              onChanged: (value) {
                setState(() {
                  appTheme.mode = value!;
                });
              },
            ),
          ),
        ),
        itemBuilder(
          context: context,
          title: 'Theme',
          icon: const Icon(fui.FluentIcons.color_24_regular, size: 21),
          content: SizedBox(
            // width: 800,
            height: 205,
            child: Scrollbar(
              controller: _controller,
              child: ListView.builder(
                controller: _controller,
                padding: const EdgeInsets.only(bottom: 10.0),
                scrollDirection: Axis.horizontal,
                itemCount: appTheme.themes.length,
                itemBuilder: (context, index) {
                  String key = appTheme.themes.keys.elementAt(index);

                  if (appTheme.accentColorPrimary == appTheme.themes[key]![0]) {
                    return Row(children: [
                      _themeCard(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(key, style: appTheme.caption),
                              const SizedBox(
                                width: 4.0,
                              ),
                              const Icon(FluentIcons.circle_fill,
                                  size: 6,
                                  color: Color.fromARGB(255, 24, 211, 24))
                            ],
                          ),
                          appTheme,
                          appTheme.themes[key]!),
                      gapWidth()
                    ]);
                  }

                  return Row(children: [
                    _themeCard(Text(key, style: appTheme.caption), appTheme,
                        appTheme.themes[key]!),
                    gapWidth()
                  ]);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _themeCard(Widget title, AppTheme appTheme, List<AccentColor> accent) {
    return SizedBox(
      width: 210,
      child: Button(
        onPressed: () {
          setState(() {
            appTheme.accentColorPrimary = accent[0];
            appTheme.accentColorSecondary = accent[1];
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Mica(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Mica(
                              backgroundColor: accent[0],
                              borderRadius: appTheme.brInner,
                              child: const SizedBox(width: 50, height: 20)),
                          const Text(
                              '________________\n________________\n________________\n________',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  height: 1, fontWeight: FontWeight.w900)),
                          // gapHeight(),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Mica(
                                backgroundColor: accent[1],
                                borderRadius: BorderRadius.circular(9999),
                                child: const SizedBox(width: 20, height: 20)),
                          ),
                        ]),
                  ),
                ),
              ),
              // const SizedBox(height: 8.0),
              title
            ],
          ),
        ),
      ),
    );
  }
}
