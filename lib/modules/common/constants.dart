import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/text_styles.dart';

import 'app_colors.dart';

class Constants {
  static BoxDecoration customBoxDecoration(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    var opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return BoxDecoration(
      image: DecorationImage(
        image: const AssetImage('assets/images/background.png'),
        fit: BoxFit.cover,
        opacity: opacity,
      ),
    );
  }

  static AppBar customAppBar({
    required BuildContext context,
    String? iconPath,
  }) {
    final Brightness brightness = Theme.of(context).brightness;
    var opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.0,
      flexibleSpace: FlexibleSpaceBar(
          background: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: opacity,
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      )),
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Image.asset(
          'assets/icons/arrow_back.png',
          color: AppColors.primaryLight,
          width: 34.0,
          height: 34.0,
        ),
      ),
      actions: [
        if (iconPath != null)
          IconButton(
            onPressed: () {},
            icon: Image.asset(
              iconPath,
              width: 24.0,
              height: 24.0,
            ),
          ),
      ],
    );
  }

  static Padding headingWithSeeAll600({
    required String title,
    double? titleSize,
    Color? titleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.normal600(
              fontSize: titleSize ?? 16.0,
              color: titleColor ?? AppColors.backgroundDark,
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(),
            child: const Text(
              'See all',
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Padding heading600({
    required String title,
    double? titleSize,
    Color? titleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: AppTextStyles.normal600(
          fontSize: titleSize ?? 16.0,
          color: titleColor ?? AppColors.backgroundDark,
        ),
      ),
    );
  }

}
