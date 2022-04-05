import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:xview/theme.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();

    return ScaffoldPage.scrollable(
        header: PageHeader(title: Text('Library', style: appTheme.title)),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(
                width: 350,
              ),
            ],
          ),
        ]);
  }
}
