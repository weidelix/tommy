import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_theme/system_theme.dart';
import 'package:provider/provider.dart';
import 'package:xview/user_preference.dart';

class AppTheme extends ChangeNotifier {
  AppTheme() {
    // _accentColorPrimary = themes['Autumn']![0];
    // _accentColorSecondary = themes['Autumn']![1];
    _accentColorPrimary = themes[UserPreference().theme]![0];
    _accentColorSecondary = themes[UserPreference().theme]![1];

    if (UserPreference().darkMode == 'System Default') {
      _darkMode = ThemeMode.system;
    } else if (UserPreference().darkMode == 'Dark') {
      _darkMode = ThemeMode.dark;
    } else {
      _darkMode = ThemeMode.light;
    }
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

  ThemeMode _darkMode = ThemeMode.system;
  ThemeMode get darkMode => _darkMode;
  set darkMode(ThemeMode mode) {
    if (mode == ThemeMode.system) {
      UserPreference().darkMode = 'System Default';
    } else if (mode == ThemeMode.dark) {
      UserPreference().darkMode = 'Dark';
    } else if (mode == ThemeMode.light) {
      UserPreference().darkMode = 'Light';
    }

    _darkMode = mode;
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
