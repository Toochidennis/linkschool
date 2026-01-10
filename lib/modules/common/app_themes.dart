import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'text_styles.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    fontFamily: 'Urbanist',
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.backgroundLight, 
        primary: AppColors.primaryLight,
        brightness: Brightness.light),
    textTheme: const TextTheme(
      titleLarge: AppTextStyles.titleLight,
      titleMedium: AppTextStyles.normalLight,
      titleSmall: AppTextStyles.italicLight,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryLight,
      titleTextStyle: AppTextStyles.normal600(
          fontSize: 18.0, color: AppColors.primaryLight),
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    fontFamily: 'Urbanist',
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryDark, 
        primary: AppColors.primaryDark,
        brightness: Brightness.dark),
    textTheme: const TextTheme(
      titleLarge: AppTextStyles.titleDark,
      bodyMedium: AppTextStyles.normalDark,
      bodySmall: AppTextStyles.italicDark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      titleTextStyle: AppTextStyles.normal600(
        fontSize: 18.0,
        color: AppColors.secondaryLight,
      ),
    ),
    useMaterial3: true,
  );
}
