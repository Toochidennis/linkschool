import "package:flutter/material.dart";
import "package:linkschool/modules/common/app_colors.dart";
import "package:linkschool/modules/common/constants.dart";
import "package:linkschool/modules/common/text_styles.dart";

class LoginScreens extends StatefulWidget {
  const LoginScreens({super.key});

  @override
  State<LoginScreens> createState() => _LoginScreensState();
}

class _LoginScreensState extends State<LoginScreens> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Constants.customAppBar(context: context),
      body: Container(
        child: Column(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, 68, 24, 16),
            child: Wrap(
              children: [
                Image(
                  image: AssetImage(
                    'assets/images/explore-images/ls-logo.png',
                  ),
                  width: 19.23,
                  height: 20,
                ),
                Text("LinkSkool",
                    style: AppTextStyles.normal700(
                        fontSize: 16, color: AppColors.aboutTitle))

                    Text("LinkSkool",
                    style: AppTextStyles.normal700(
                        fontSize: 16, color: AppColors.aboutTitle))
              ],
            ),
          )
        ]),
      ),
    );
  }
}
