import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NairaSvgIcon extends StatelessWidget {
  final Color? color;   

  const NairaSvgIcon({super.key, this.color});
  
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/e_learning/naira_icon.svg',
      width: 16,
      height: 16, 
      color: color ?? Colors.black,
    );
  }
}
