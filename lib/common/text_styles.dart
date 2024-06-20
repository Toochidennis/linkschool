import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle titleLight = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
  );

  static const TextStyle title2Light = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
    color: AppColors.textLight,
  );

  static const TextStyle title3Light = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.text2Light,
      fontFamily: 'Urbanist');

  static const TextStyle normalLight = TextStyle(
    fontSize: 16,
    color: AppColors.textLight,
  );

  static const TextStyle normal2Light = TextStyle(
      fontSize: 16,
      color: AppColors.text2Light,
      fontFamily: 'Urbanist',
      fontWeight: FontWeight.w500);

  static const TextStyle normal3Light = TextStyle(
    fontSize: 14,
    color: AppColors.text4Light,
    fontWeight: FontWeight.w500,
    fontFamily: 'Urbanist',
  );

  static const TextStyle normal4Light = TextStyle(
    fontSize: 10,
    color: AppColors.text4Light,
    fontWeight: FontWeight.w500,
    fontFamily: 'Urbanist',
  );

  static const TextStyle normal5Light = TextStyle(
    fontSize: 14,
    color: AppColors.backgroundLight,
    fontWeight: FontWeight.w500,
    fontFamily: 'Urbanist',
  );

  static TextStyle normal500({
    required double fontSize,
    required Color color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.w500,
      fontFamily: 'Urbanist',
    );
  }

  static const TextStyle italicLight = TextStyle(
    fontSize: 16,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w500,
    color: AppColors.text3Light,
  );

  static const TextStyle italic2Light = TextStyle(
      fontSize: 20,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w700,
      color: AppColors.backgroundLight,
      fontFamily: 'Urbanist');

  static const TextStyle italic3Light = TextStyle(
      fontSize: 20,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w700,
      color: AppColors.secondaryLight,
      fontFamily: 'Urbanist');

  static const TextStyle buttonsText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.backgroundLight,
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
  static const TextStyle normalDark2 = TextStyle(
    fontSize: 14,
    color: AppColors.backgroundDark,
    fontFamily: 'Urbanist',
    fontWeight: FontWeight.w500,
  );

  static const TextStyle italicDark = TextStyle(
    fontSize: 16,
    fontStyle: FontStyle.italic,
    color: AppColors.textDark,
  );

  static TextStyle appBarTextStyle(Color color) {
    return TextStyle(
      color: color,
      fontFamily: 'Urbanist',
      fontSize: 24.0,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w700,
    );
  }
}
