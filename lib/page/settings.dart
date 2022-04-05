import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:xview/tabs.dart';
import 'package:xview/theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<String> routes = ['Settings', 'General', 'Personalization'];

  int _index = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: Row(children: [
          AnimatedSize(
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 150),
              child: _index != 0
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                          icon: const Icon(
                            fui.FluentIcons.arrow_left_24_regular,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _index = 0);
                          }),
                    )
                  : const SizedBox.shrink()),
          Text(routes[_index], style: appTheme.title)
        ]),
      ),
      children: [
        NavigationBody(
            index: _index,
            transitionBuilder: (child, animation) {
              return EntrancePageTransition(
                  vertical: false,
                  child: child,
                  animation: animation,
                  reverse: _index < 0);
            },
            children: [
              _options(appTheme),
              const General(),
              const Personalization(),
            ])
      ],
    );
  }

  Widget _options(AppTheme appTheme) {
    return Wrap(runSpacing: appTheme.itemSpacing, children: [
      // General
      navigationItemBuilder(
          title: 'General',
          subtitle: 'Max tab count & more',
          icon: const Icon(fui.FluentIcons.app_generic_24_regular, size: 21),
          cb: () {
            setState(() {
              _index = 1;
            });
          },
          appTheme: appTheme),
      // Personalization
      navigationItemBuilder(
          title: 'Personalization',
          subtitle: 'Dark mode & themes',
          icon: const Icon(fui.FluentIcons.paint_brush_24_regular, size: 21),
          cb: () {
            setState(() {
              _index = 2;
            });
          },
          appTheme: appTheme),
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
    final appTheme = context.read<AppTheme>();
    final tabs = context.read<TabsState>();

    return Wrap(runSpacing: 8.0, children: [
      Text('Tabs', style: appTheme.bodyStrongAccent),
      itemBuilder(
          title: 'Max tab count',
          icon: const Icon(fui.FluentIcons.tabs_24_regular, size: 21),
          footer: SizedBox(
            width: 55,
            child: Combobox<int>(
                comboboxColor: Colors.magenta,
                value: 8,
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
          ),
          appTheme: appTheme),
      itemBuilder(
          title: 'Clear tabs on exit',
          icon: const Icon(fui.FluentIcons.delete_24_regular, size: 21),
          footer: ToggleSwitch(checked: true, onChanged: (value) {}),
          appTheme: appTheme)
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
          title: 'Dark mode',
          icon: const Icon(fui.FluentIcons.weather_moon_24_regular, size: 21),
          appTheme: appTheme,
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
          title: 'Theme',
          icon: const Icon(fui.FluentIcons.color_24_regular, size: 21),
          appTheme: appTheme,
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
              SizedBox(
                height: 140,
                width: double.infinity,
                child: Mica(
                  borderRadius: appTheme.brInner,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Mica(
                              backgroundColor: accent[0],
                              borderRadius: appTheme.brInner,
                              child: const SizedBox(width: 50, height: 20)),
                          Text(
                              '________________\n________________\n________________\n________',
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                  height: 1,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: appTheme.fontFamily)),
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
