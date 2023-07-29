import 'package:fluent_ui/fluent_ui.dart';

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
    return const Wrap(runSpacing: 4.0, children: [
      // Text('Tabs', style: appTheme.bodyStrongAccent),
    ]);
  }
}
