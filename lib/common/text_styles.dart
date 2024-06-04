import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle titleLight = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
  );

  static const TextStyle title2Light = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
    color: AppColors.textLight,
  );

  static const TextStyle normalLight = TextStyle(
    fontSize: 16,
    color: AppColors.textLight,
  );

  static const TextStyle italicLight = TextStyle(
    fontSize: 16,
    fontStyle: FontStyle.italic,
    color: AppColors.textLight,
  );

  static const TextStyle titleDark = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle normalDark = TextStyle(
    fontSize: 16,
    color: AppColors.textDark,
  );

  static const TextStyle italicDark = TextStyle(
    fontSize: 16,
    fontStyle: FontStyle.italic,
    color: AppColors.textDark,
  );

  static TextStyle appBarTextStyle(Color color){
    return TextStyle(
      color: color,
      fontFamily: 'Urbanist',
      fontSize: 24.0,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w700,
    );
  }
}
