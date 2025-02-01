import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'app_colors.dart';

class Constants {
  static const double padding = 16.0;
  static const double gap = 10.0;
  static const double borderRadius = 8.0;

  static BoxDecoration customBoxDecoration(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    var opacity = brightness == Brightness.light ? 0.1 : 0.15;
    var backgroundColor = brightness == Brightness.light
        ? AppColors.backgroundLight
        : AppColors.backgroundDark;

    return BoxDecoration(
      color: backgroundColor,
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
  bool? centerTitle,
  String? title,
  bool showBackButton = true, 
}) {
  final Brightness brightness = Theme.of(context).brightness;
  var opacity = brightness == Brightness.light ? 0.1 : 0.15;

  return AppBar(
    backgroundColor: Colors.white,
    automaticallyImplyLeading: false,
    elevation: 0.0,
    title: Text(
      title ?? "",
      style: AppTextStyles.normal600(
        fontSize: 18.0,
        color: AppColors.primaryLight,
      ),
    ),
    centerTitle: centerTitle,
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
      ),
    ),
    leading: showBackButton 
        ? IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Image.asset(
              'assets/icons/arrow_back.png',
              color: AppColors.primaryLight,
              width: 34.0,
              height: 34.0,
            ),
          )
        : null, 
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


  
   static BoxDecoration customScreenDec0ration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomCenter,
        colors: [
         Color.fromRGBO(0, 114, 255, 1).withOpacity(0.3), 
                AppColors.attBgColor1,
        ],
        stops: [0.1, 0.3],
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
