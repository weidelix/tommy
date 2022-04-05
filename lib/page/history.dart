import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import 'package:xview/theme.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();

    return ScaffoldPage.scrollable(
        header: PageHeader(
          title: Text('History', style: appTheme.title),
        ),
        children: const []);
  }
}
