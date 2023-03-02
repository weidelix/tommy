import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:xview/theme.dart';
import 'package:xview/utils/utils.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('(┛◉Д◉)┛彡┻━┻', style: appTheme.titleLarge),
          gapHeight(),
          Text('No history.', style: appTheme.subtitle),
        ],
      ),
    );
  }
}
