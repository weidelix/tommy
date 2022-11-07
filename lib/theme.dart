import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_theme/system_theme.dart';
import 'package:provider/provider.dart';

Widget gapWidth([double size = 16]) {
  return SizedBox(width: size);
}

Widget gapHeight([double size = 16.0]) {
  return SizedBox(height: size);
}

Widget navigationItemBuilder(
    {required BuildContext context,
    required String title,
    String? subtitle,
    required IconData icon,
    required void Function() onPressed}) {
  final appTheme = context.read<AppTheme>();

  return Container(
    constraints: appTheme.itemConstraints,
    child: Button(
      style: ButtonStyle(
        border: ButtonState.all(BorderSide.none),
        padding: ButtonState.all(EdgeInsets.zero),
        backgroundColor: ButtonState.resolveWith((Set<ButtonStates> states) {
          final theme = FluentTheme.of(context);
          final color = theme.cardColor.toAccentColor();

          if (states.isDisabled) {
            if (theme.brightness.isDark) {
              return const Color(0xFF434343);
            } else {
              return const Color(0xFFBFBFBF);
            }
          } else if (states.isPressing) {
            if (theme.brightness.isDark) {
              return color.dark;
            } else {
              return color.light;
            }
          } else if (states.isHovering) {
            if (theme.brightness.isDark) {
              return color.light;
            } else {
              return color.dark;
            }
          }

          return color;
        }),
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 24),
                gapWidth(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: appTheme.body),
                    subtitle != null
                        ? Opacity(
                            opacity: 0.7,
                            child: Text(subtitle, style: appTheme.navSubtitle),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
            const Icon(FluentIcons.chevron_right, size: 10)
          ],
        ),
      ),
    ),
  );
}

Widget itemBuilder(
    {required BuildContext context,
    required String title,
    String? subtitle,
    IconData? icon,
    Widget? footer,
    Widget? content}) {
  final appTheme = context.read<AppTheme>();
  final theme = FluentTheme.of(context);

  return Container(
    constraints: appTheme.itemConstraints,
    decoration: BoxDecoration(
      borderRadius: appTheme.brInner,
    ),
    clipBehavior: Clip.hardEdge,
    child: Card(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  icon != null ? Icon(icon, size: 24) : const SizedBox.shrink(),
                  gapWidth(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: appTheme.body),
                      subtitle != null
                          ? Opacity(
                              opacity: 0.7,
                              child:
                                  Text(subtitle, style: appTheme.navSubtitle),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
              footer ?? const SizedBox.shrink()
            ],
          ),
          content != null
              ? Column(
                  children: [gapHeight(), content],
                )
              : const SizedBox.shrink()
        ],
      ),
    ),
  );
}

class AppTheme extends ChangeNotifier {
  AppTheme() {
    // _accentColorPrimary = themes['Autumn']![0];
    // _accentColorSecondary = themes['Autumn']![1];
    _accentColorPrimary = themes['System']![0];
    _accentColorSecondary = themes['System']![1];
  }

  final double itemSpacing = 4.0;

  double scale = 1.0;
  final Typography _typography = const Typography.raw(
      caption: TextStyle(fontSize: 12, height: 1.33),
      body: TextStyle(fontSize: 14, height: 1.42),
      bodyLarge: TextStyle(fontSize: 18, height: 1.33),
      title: TextStyle(fontSize: 28, height: 1.28, fontWeight: FontWeight.w600),
      bodyStrong:
          TextStyle(fontSize: 14, height: 1.42, fontWeight: FontWeight.w600),
      subtitle:
          TextStyle(fontSize: 20, height: 1.4, fontWeight: FontWeight.w600),
      titleLarge:
          TextStyle(fontSize: 40, height: 1.3, fontWeight: FontWeight.w600),
      display:
          TextStyle(fontSize: 68, height: 1.35, fontWeight: FontWeight.w600));
  Typography get typography => _typography;

  final itemConstraints = const BoxConstraints(minHeight: 70);

  final String? _fontFamily = '';
  String? get fontFamily => _fontFamily;

  TextStyle get caption => _typography.caption!.apply(fontSizeFactor: scale);
  TextStyle get subtitle => _typography.subtitle!.apply(fontSizeFactor: scale);
  TextStyle get title => _typography.title!.apply(fontSizeFactor: scale);
  TextStyle get body => _typography.body!.apply(fontSizeFactor: scale);
  TextStyle get captionAccent => _typography.caption!
      .apply(color: _accentColorSecondary, fontSizeFactor: scale);
  TextStyle get titleLarge =>
      _typography.titleLarge!.apply(fontSizeFactor: scale);
  TextStyle get display => _typography.display!.apply(fontSizeFactor: scale);

  TextStyle get bodyStrong =>
      _typography.bodyStrong!.apply(fontSizeFactor: scale);
  TextStyle get bodyStrongAccent => _typography.bodyStrong!
      .apply(color: _accentColorSecondary, fontSizeFactor: scale);
  TextStyle get bodyLarge =>
      _typography.bodyLarge!.apply(fontSizeFactor: scale);

  TextStyle navSubtitle = const TextStyle(fontSize: 11);

  String? accentName = 'System default';

  late AccentColor _accentColorPrimary;
  AccentColor get accentColorPrimary => _accentColorPrimary;
  set accentColorPrimary(AccentColor accent) {
    _accentColorPrimary = accent;
    notifyListeners();
  }

  late AccentColor _accentColorSecondary;
  AccentColor get accentColorSecondary => _accentColorSecondary;
  set accentColorSecondary(AccentColor accent) {
    _accentColorSecondary = accent;
    notifyListeners();
  }

  BorderRadius brOuter = const BorderRadius.all(Radius.circular(8.0));
  BorderRadius brInner = const BorderRadius.all(Radius.circular(4.0));

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;
  set mode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  Map<String, List<AccentColor>> themes = {
    'System': [
      SystemTheme.accentColor.accent.toAccentColor().lighter.toAccentColor(),
      SystemTheme.accentColor.accent.toAccentColor().lighter.toAccentColor()
    ],
    'Fluent': [
      kDefaultSystemAccentColor.toAccentColor(),
      kDefaultSystemAccentColor.toAccentColor(),
    ],
    'Autumn': [Colors.accentColors[2], Colors.accentColors[1]],
    'Ocean': [Colors.accentColors[6], Colors.accentColors[5]],
  };
}
