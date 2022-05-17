import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:xview/main.dart';
import 'package:xview/theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late List<Widget> itemsList;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    itemsList = [
      navigationItemBuilder(
          context: context,
          title: 'General',
          subtitle: 'Max tab count & more',
          icon: fui.FluentIcons.app_generic_24_regular,
          cb: () {
            // setState(() => settings.goTo(routeGeneral));
            RootNavigation().push(routeSettingsGeneral);
          }),
      // Personalization
      navigationItemBuilder(
          context: context,
          title: 'Personalization',
          subtitle: 'Dark mode & themes',
          icon: fui.FluentIcons.paint_brush_24_regular,
          cb: () {
            // setState(() => settings.goTo(routePersonalization));
            RootNavigation().push(routeSettingsPersonalization);
          }),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();

    return ListView.separated(
      separatorBuilder: ((context, index) =>
          SizedBox(height: appTheme.itemSpacing)),
      itemCount: itemsList.length,
      itemBuilder: (context, index) => itemsList[index],
    );
  }
}

class SettingsGeneral extends StatefulWidget {
  const SettingsGeneral({Key? key}) : super(key: key);

  @override
  _SettingsGeneralState createState() => _SettingsGeneralState();
}

class _SettingsGeneralState extends State<SettingsGeneral> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();

    return Wrap(runSpacing: 4.0, children: const [
      // Text('Tabs', style: appTheme.bodyStrongAccent),
    ]);
  }
}

class SettingsPersonalization extends StatefulWidget {
  const SettingsPersonalization({Key? key}) : super(key: key);

  @override
  _SettingsPersonalizationState createState() =>
      _SettingsPersonalizationState();
}

class _SettingsPersonalizationState extends State<SettingsPersonalization> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();

    return ListView(children: [
      Wrap(
        runSpacing: appTheme.itemSpacing,
        children: [
          itemBuilder(
            context: context,
            title: 'Dark mode',
            icon: fui.FluentIcons.dark_theme_24_regular,
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
            icon: fui.FluentIcons.color_24_regular,
            content: SizedBox(
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

                    if (appTheme.accentColorPrimary ==
                        appTheme.themes[key]![0]) {
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
      ),
    ]);
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
