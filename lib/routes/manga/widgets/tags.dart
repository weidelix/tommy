import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:xview/theme.dart';

Widget buildTag(BuildContext context, String content) {
  final appTheme = context.read<AppTheme>();

  return IntrinsicWidth(
    child: Card(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: BorderRadius.circular(9999),
      child: Text(content, style: appTheme.caption),
    ),
  );
}
