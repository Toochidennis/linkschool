import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NairaSvgIcon extends StatelessWidget {
  final Color? color;  // Accept color as a parameter

  const NairaSvgIcon({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/e_learning/naira_icon.svg',
      width: 16,
      height: 16,
      color: color ?? Colors.black,  // Use the provided color or default to black
    );
  }
}
