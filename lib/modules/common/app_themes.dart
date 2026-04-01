import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: AppTextStyles.normal600(
          fontSize: 18.0, color: Colors.white),
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
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: AppTextStyles.normal600(
        fontSize: 18.0,
        color: Colors.white,
      ),
    ),
    useMaterial3: true,
  );
}
