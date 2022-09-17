import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:xview/theme.dart';

Widget buildTag(BuildContext context, String content) {
  final appTheme = context.read<AppTheme>();

  return IntrinsicWidth(
    child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
            color: FluentTheme.of(context).brightness == Brightness.light
                ? Colors.white
                : const Color(0xFF2b2b2b),
            borderRadius: BorderRadius.circular(9999)),
        child: Text(content, style: appTheme.caption)),
  );
}
