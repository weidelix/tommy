import 'package:fluent_ui/fluent_ui.dart';

import 'package:xview/utils/utils.dart';

/// [_Reader] layouts
class VerticalReader extends StatelessWidget {
  const VerticalReader(
      {required this.images,
      required this.constraints,
      required this.controller,
      Key? key})
      : super(key: key);

  final List<Widget> images;
  final ScrollController controller;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    checkMemory();

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.builder(
          controller: controller,
          prototypeItem: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: const Center(child: ProgressRing())),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: images[index]);
          }),
    );
  }
}
