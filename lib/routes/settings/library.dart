import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;
import 'package:provider/provider.dart';
import 'package:xview/cache_managers/global_image_cache_manager.dart';

import 'package:xview/theme.dart';
import 'package:xview/user_preference.dart';
import 'package:xview/utils/utils.dart';

class SettingsLibrary extends StatefulWidget {
  const SettingsLibrary({Key? key}) : super(key: key);

  @override
  State<SettingsLibrary> createState() => _SettingsLibraryState();
}

class _SettingsLibraryState extends State<SettingsLibrary> {
  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();

    return Wrap(runSpacing: appTheme.itemSpacing, children: [
      itemBuilder(
          context: context,
          title: 'Update library on start',
          footer: ToggleSwitch(
              checked: UserPreference().updateLibraryOnStart,
              onChanged: (value) {
                setState(() {
                  UserPreference().updateLibraryOnStart = value;
                });
              }),
          icon: fui.FluentIcons.arrow_sync_24_regular),
      buttonItemBuilder(
          context: context,
          title: 'Clear cache',
          subtitle: 'Clears all cached images',
          icon: fui.FluentIcons.delete_24_regular,
          navigationIndicator: false,
          onPressed: () {
            GlobalImageCacheManager().emptyCache();
          })
    ]);
  }
}
