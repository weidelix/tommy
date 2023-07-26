import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:provider/provider.dart';

import 'package:xview/theme.dart';
import 'package:xview/user_preference.dart';
import 'package:xview/utils/utils.dart';

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
