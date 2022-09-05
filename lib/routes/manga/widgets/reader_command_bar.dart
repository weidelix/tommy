import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fui;

import 'package:xview/routes/navigation_manager.dart';
import 'package:xview/theme.dart';

class ReaderCommandBar extends StatefulWidget {
  const ReaderCommandBar(
      {required this.onZoomIn, required this.onZoomOut, Key? key})
      : super(key: key);

  final void Function() onZoomIn;
  final void Function() onZoomOut;

  @override
  State<ReaderCommandBar> createState() => _ReaderCommandBarState();
}

class _ReaderCommandBarState extends State<ReaderCommandBar> {
  final _showCommandBar = ValueNotifier(true);

  @override
  void initState() {
    Timer(const Duration(milliseconds: 1500),
        () => _showCommandBar.value = false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.read<AppTheme>();

    const divider = Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.0),
        child: Divider(direction: Axis.vertical, size: 15));

    const iconSize = 20.0;

    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: MouseRegion(
          onEnter: (_) => _showCommandBar.value = true,
          onExit: (_) => _showCommandBar.value = false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0, top: 36.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ValueListenableBuilder(
                    valueListenable: _showCommandBar,
                    builder: (context, show, child) => AnimatedOpacity(
                          opacity: show as bool ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 100),
                          child: AnimatedSlide(
                            offset: show ? Offset.zero : const Offset(0, 10),
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOutCubic,
                            child: Card(
                              elevation: 10.0,
                              borderRadius: appTheme.brOuter,
                              padding: const EdgeInsets.all(4.0),
                              child:
                                  Flex(direction: Axis.horizontal, children: [
                                Tooltip(
                                  useMousePosition: false,
                                  message: 'Close reader',
                                  child: IconButton(
                                      icon: const Icon(
                                        fui.FluentIcons.arrow_left_24_regular,
                                        size: iconSize,
                                      ),
                                      onPressed: () {
                                        NavigationManager().back();
                                      }),
                                ),
                                divider,
                                Tooltip(
                                  useMousePosition: false,
                                  message: 'Next chapter',
                                  child: IconButton(
                                      icon: const Icon(
                                        fui.FluentIcons.previous_24_regular,
                                        size: iconSize,
                                      ),
                                      onPressed: () {}),
                                ),
                                Tooltip(
                                  useMousePosition: false,
                                  message: 'Previous chapter',
                                  child: IconButton(
                                      icon: const Icon(
                                        fui.FluentIcons.next_24_regular,
                                        size: iconSize,
                                      ),
                                      onPressed: () {}),
                                ),
                                divider,
                                Tooltip(
                                  useMousePosition: false,
                                  message: 'Zoom out',
                                  child: IconButton(
                                      icon: const Icon(
                                        fui.FluentIcons.zoom_out_24_regular,
                                        size: iconSize,
                                      ),
                                      onPressed: widget.onZoomOut),
                                ),
                                Tooltip(
                                  useMousePosition: false,
                                  message: 'Zoom in',
                                  child: IconButton(
                                      icon: const Icon(
                                        fui.FluentIcons.zoom_in_24_regular,
                                        size: iconSize,
                                      ),
                                      onPressed: widget.onZoomIn),
                                ),
                              ]),
                            ),
                          ),
                        ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
