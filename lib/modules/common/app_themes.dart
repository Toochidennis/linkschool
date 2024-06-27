import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'text_styles.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    fontFamily: 'Urbanist',
    colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.backgroundLight, primary: AppColors.primaryLight),
    textTheme: const TextTheme(
      titleLarge: AppTextStyles.titleLight,
      titleMedium: AppTextStyles.normalLight,
      titleSmall: AppTextStyles.italicLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryLight,
      titleTextStyle: AppTextStyles.title2Light,
    ),

    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    fontFamily: 'Urbanist',
    colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryDark, primary: AppColors.primaryDark),
    textTheme: const TextTheme(
      titleLarge: AppTextStyles.titleDark,
      bodyMedium: AppTextStyles.normalDark,
      bodySmall: AppTextStyles.italicDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      titleTextStyle: AppTextStyles.title2Light,
    ),

    useMaterial3: true,
  );
}
