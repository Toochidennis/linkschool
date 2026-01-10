import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NairaSvgIcon extends StatelessWidget {
  final Color? color;
  final double width;
  final double height;
  final double? size;

  const NairaSvgIcon(
      {super.key,
      this.color,
      this.width = 16.0,
      this.height = 16.0,
      this.size});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/e_learning/naira_icon.svg',
      width: width,
      height: height,
      color: color ?? Colors.black,
    );
  }
}
