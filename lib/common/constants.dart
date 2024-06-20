import 'package:flutter/material.dart';

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

  static AppBar customAppBar(BuildContext context) {
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
    );
  }
}
