import 'package:curved_nav_bar/fab_bar/fab_bottom_app_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


import 'app_colors.dart';

FABBottomAppBarItem createBottomNavIcon({
  required String imagePath,
  required String text,
  double? height,
  double? width,
}) {
  return FABBottomAppBarItem(
    activeIcon: SvgPicture.asset(
      imagePath,
      colorFilter: const ColorFilter.mode(
        AppColors.secondaryLight,
        BlendMode.srcIn,
      ),
      height: height ?? 24.0,
      width: width ?? 24.0,
    ),
    inActiveIcon: SvgPicture.asset(
      imagePath,
      colorFilter: const ColorFilter.mode(
        AppColors.paymentTxtColor1,
        BlendMode.srcIn,
      ),
      height: height ?? 24.0,
      width: width ?? 24.0,
    ),
    text: text,
  );
}
