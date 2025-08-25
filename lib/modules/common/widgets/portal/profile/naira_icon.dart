import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NairaSvgIcon extends StatelessWidget {
  final Color? color;
  final double width;
  final double height;

  const NairaSvgIcon({
    super.key,
    this.color,
    this.width = 16.0,
    this.height = 16.0,
  });

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





// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';

// class NairaSvgIcon extends StatelessWidget {
//   final Color? color;   

//   const NairaSvgIcon({super.key, this.color});
  
//   @override
//   Widget build(BuildContext context) {
//     return SvgPicture.asset(
//       'assets/icons/e_learning/naira_icon.svg',
//       width: 16,
//       height: 16, 
//       color: color ?? Colors.black,
//     );
//   }
// }
