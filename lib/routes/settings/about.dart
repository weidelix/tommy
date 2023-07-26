import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:xview/theme.dart';

import 'package:xview/utils/utils.dart';

class SettingsAbout extends StatefulWidget {
  const SettingsAbout({Key? key}) : super(key: key);

  @override
  _SettingsAboutState createState() => _SettingsAboutState();
}

class _SettingsAboutState extends State<SettingsAbout> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

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
                    child: Text(
                      'Version: 0.2.4',
                      style: appTheme.body,
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
      buttonItemBuilder(
          context: context,
          icon: fui.FluentIcons.star_24_regular,
          title: 'What\'s new',
          onPressed: () {}),
      buttonItemBuilder(
          context: context,
          icon: fui.FluentIcons.branch_24_regular,
          title: 'Open source licenses',
          onPressed: () {}),
      buttonItemBuilder(
          context: context,
          icon: fui.FluentIcons.lock_closed_24_regular,
          title: 'Privacy policy',
          onPressed: () {}),
    ]);
  }
}
