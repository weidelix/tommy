import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:xview/theme.dart';

Widget gapWidth([double size = 16]) {
  return SizedBox(width: size);
}

Widget gapHeight([double size = 16.0]) {
  return SizedBox(height: size);
}

Widget buttonItemBuilder(
    {required BuildContext context,
    required String title,
    bool navigationIndicator = true,
    String? subtitle,
    required IconData icon,
    required void Function() onPressed}) {
  final appTheme = context.read<AppTheme>();

  return Container(
    constraints: appTheme.itemConstraints,
    child: Button(
      style: ButtonStyle(
        border: ButtonState.all(BorderSide.none),
        padding: ButtonState.all(EdgeInsets.zero),
        backgroundColor: ButtonState.resolveWith((Set<ButtonStates> states) {
          final theme = FluentTheme.of(context);
          final color = theme.cardColor.toAccentColor();

          if (states.isDisabled) {
            if (theme.brightness.isDark) {
              return const Color(0xFF434343);
            } else {
              return const Color(0xFFBFBFBF);
            }
          } else if (states.isPressing) {
            if (theme.brightness.isDark) {
              return color.dark;
            } else {
              return color.light;
            }
          } else if (states.isHovering) {
            if (theme.brightness.isDark) {
              return color.light;
            } else {
              return color.dark;
            }
          }

          return color;
        }),
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 24),
                gapWidth(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: appTheme.body),
                    subtitle != null
                        ? Opacity(
                            opacity: 0.7,
                            child: Text(subtitle, style: appTheme.navSubtitle),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
            navigationIndicator
                ? const Icon(FluentIcons.chevron_right, size: 10)
                : const SizedBox.shrink()
          ],
        ),
      ),
    ),
  );
}

Widget itemBuilder(
    {required BuildContext context,
    required String title,
    String? subtitle,
    IconData? icon,
    Widget? footer,
    Widget? content}) {
  final appTheme = context.read<AppTheme>();
  final theme = FluentTheme.of(context);

  return Container(
    constraints: appTheme.itemConstraints,
    decoration: BoxDecoration(
      borderRadius: appTheme.brInner,
    ),
    clipBehavior: Clip.hardEdge,
    child: Card(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  icon != null ? Icon(icon, size: 24) : const SizedBox.shrink(),
                  gapWidth(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: appTheme.body),
                      subtitle != null
                          ? Opacity(
                              opacity: 0.7,
                              child:
                                  Text(subtitle, style: appTheme.navSubtitle),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
              footer ?? const SizedBox.shrink()
            ],
          ),
          content != null
              ? Column(
                  children: [gapHeight(), content],
                )
              : const SizedBox.shrink()
        ],
      ),
    ),
  );
}

void checkMemory() {
  var imageCache = PaintingBinding.instance.imageCache;
  if (imageCache.currentSizeBytes >= 55 << 20) {
    imageCache.clear();
    imageCache.clearLiveImages();
  }
}
