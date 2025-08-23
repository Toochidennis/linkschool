import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NairaSvgIcon extends StatelessWidget {
  final Color color;
  final double size; // new parameter

  const NairaSvgIcon({
    super.key,
    required this.color,
    this.size = 24, // default size
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
     'assets/icons/e_learning/naira_icon.svg',
      color: color,
      width: size,
      height: size,
    );
  }
}

