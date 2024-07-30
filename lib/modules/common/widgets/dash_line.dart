import 'package:flutter/material.dart';

class DashedLine extends StatelessWidget {
  final double height;
  final double width;
  final Color color;

  const DashedLine({
    this.height = 1,
    this.width = 5,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (2 * width)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: width,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}
