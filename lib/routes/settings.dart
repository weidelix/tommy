import 'package:fluent_ui/fluent_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:xview/routes/navigation_manager.dart';
import 'package:xview/constants/route_names.dart';
import 'package:xview/theme.dart';
import 'package:xview/user_preference.dart';
import 'package:xview/utils/utils.dart';

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
    super.initState();
    itemsList = [
      navigationItemBuilder(
          context: context,
          title: 'Personalization',
          subtitle: 'Dark mode & themes',
          icon: fui.FluentIcons.paint_brush_24_regular,
          onPressed: () {
            NavigationManager().push(routeSettingsPersonalization, context);
          }),
      navigationItemBuilder(
          context: context,
          title: 'About',
          subtitle: 'Updates, what\'s new & privacy policy',
          icon: fui.FluentIcons.info_24_regular,
          onPressed: () {
            NavigationManager().push(routeSettingsAbout, context);
          }),
    ];
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
              child: ComboBox<ThemeMode>(
                value: appTheme.darkMode,
                items: const [
                  ComboBoxItem<ThemeMode>(
                      value: ThemeMode.system, child: Text('System default')),
                  ComboBoxItem<ThemeMode>(
                      value: ThemeMode.light, child: Text('Light')),
                  ComboBoxItem<ThemeMode>(
                      value: ThemeMode.dark, child: Text('Dark')),
                ],
                onChanged: (value) {
                  setState(() {
                    appTheme.darkMode = value!;
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
                            key),
                        gapWidth()
                      ]);
                    }

                    return Row(children: [
                      _themeCard(
                          Text(key, style: appTheme.caption), appTheme, key),
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

  Widget _themeCard(Widget title, AppTheme appTheme, String key) {
    return SizedBox(
      width: 210,
      child: Button(
        onPressed: () {
          setState(() {
            UserPreference().theme = key;
            appTheme.accentColorPrimary = appTheme.themes[key]![0];
            appTheme.accentColorSecondary = appTheme.themes[key]![0];
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
                              backgroundColor: appTheme.themes[key]![0],
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
                                backgroundColor: appTheme.themes[key]![1],
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

class SettingsAbout extends StatefulWidget {
  const SettingsAbout({Key? key}) : super(key: key);

  @override
  _SettingsAboutState createState() => _SettingsAboutState();
}

class _SettingsAboutState extends State<SettingsAbout> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();

    return Wrap(runSpacing: 4.0, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              Image.asset(
                'assets/app_icon/xview_logo.png',
                height: 100,
                fit: BoxFit.fitHeight,
              ),
              gapWidth(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tommy',
                    style: appTheme.subtitle,
                  ),
                  Opacity(
                    opacity: 0.7,
                    child: FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) => Text(
                        'Version: ${snapshot.data?.version}',
                        style: appTheme.body,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
          Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: appTheme.brInner),
            child: OutlinedButton(
              onPressed: () {},
              style: ButtonStyle(
                  border: ButtonState.all(BorderSide.none),
                  padding: ButtonState.all(const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 10.0)),
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
              child: Row(children: [
                Icon(fui.FluentIcons.arrow_sync_24_filled,
                    size: 24, color: appTheme.accentColorSecondary),
                gapWidth(),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Check for updates'),
                  Opacity(
                    opacity: 0.7,
                    child: Text(
                      'Last checked: 0 hours ago',
                      style: appTheme.caption,
                    ),
                  )
                ])
              ]),
            ),
          )
        ]),
      ),
      navigationItemBuilder(
          context: context,
          icon: fui.FluentIcons.star_24_regular,
          title: 'What\'s new',
          onPressed: () {}),
      navigationItemBuilder(
          context: context,
          icon: fui.FluentIcons.branch_24_regular,
          title: 'Open source licenses',
          onPressed: () {}),
      navigationItemBuilder(
          context: context,
          icon: fui.FluentIcons.lock_closed_24_regular,
          title: 'Privacy policy',
          onPressed: () {}),
    ]);
  }
}
