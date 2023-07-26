import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:xview/routes/navigation_manager.dart';
import 'package:xview/constants/route_names.dart';
import 'package:xview/theme.dart';
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
      buttonItemBuilder(
          context: context,
          title: 'Library',
          subtitle: 'Library updates & display',
          icon: fui.FluentIcons.library_24_regular,
          onPressed: () {
            NavigationManager().push(routeSettingsLibrary, context);
          }),
      buttonItemBuilder(
          context: context,
          title: 'Personalization',
          subtitle: 'Dark mode & themes',
          icon: fui.FluentIcons.paint_brush_24_regular,
          onPressed: () {
            NavigationManager().push(routeSettingsPersonalization, context);
          }),
      buttonItemBuilder(
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
