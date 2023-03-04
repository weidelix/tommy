import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:system_theme/system_theme.dart';
import 'package:xview/layout.dart';
import 'package:xview/manga_manager.dart';
import 'package:xview/theme.dart';
import 'package:xview/user_preference.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemTheme.accentColor.load();

  runApp(const Tommy());
  doWhenWindowReady(() async {
    const initialSize = Size(1280, 720);
    appWindow.title = 'Tommy';
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class Tommy extends StatelessWidget {
  const Tommy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MangaManager();
    UserPreference();

    return ChangeNotifierProvider(
        create: (context) => AppTheme(),
        builder: (context, _) {
          final appTheme = context.watch<AppTheme>();

          return FluentApp(
            title: 'Tommy',
            themeMode: appTheme.darkMode,
            darkTheme: FluentThemeData(
                typography:
                    appTheme.typography.apply(displayColor: Colors.white),
                visualDensity: VisualDensity.standard,
                fontFamily: appTheme.fontFamily,
                accentColor: appTheme.accentColorPrimary,
                brightness: Brightness.dark),
            theme: FluentThemeData(
                typography:
                    appTheme.typography.apply(displayColor: Colors.black),
                visualDensity: VisualDensity.standard,
                fontFamily: appTheme.fontFamily,
                accentColor: appTheme.accentColorPrimary,
                brightness: Brightness.light),
            home: const Layout(),
            debugShowCheckedModeBanner: false,
          );
        });
  }
}
