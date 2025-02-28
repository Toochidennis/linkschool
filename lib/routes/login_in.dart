import "package:flutter/material.dart";
import "package:linkschool/modules/common/app_colors.dart";
import "package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart";
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
      // appBar:
      body: Container(
        width: double.infinity,
        decoration: Constants.customScreenDec0ration(),
        child: Stack(
          children: [
            Positioned(
              top: 120,
              right: 300,
              left: 0,
              child: Container(
                  child: InkWell(
                onTap: () => (Navigator.pop(context)),
                child: Icon(
                  Icons.arrow_back,
                  size: 16,
                  color: AppColors.attCheckColor1,
                ),
              )
                  // Constants.customAppBar(
                  //   context: context
                  // ),
                  ),
            ),
            Positioned(
              top: 100,
              right: 0,
              left: 0,
              child: Container(
                child: loginpage(),
              ),
            ),
            Positioned(
                top: 700,
                bottom: 30,
                left: 60,
                child: Wrap(
                  children: [
                    SizedBox(height: 150),
                    Text("Don't have an account?",
                        style: AppTextStyles.normal500(
                            fontSize: 12, color: AppColors.assessmentColor2)),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        " Sign Up",
                        style: AppTextStyles.normal500(
                            fontSize: 14, color: AppColors.aicircle),
                      ),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

class loginpage extends StatelessWidget {
  const loginpage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            SizedBox(
              width: 10,
            ),
            Text("Link",
                style: AppTextStyles.normal700(
                  fontSize: 16,
                  color: AppColors.aboutTitle,
                )),
            Text("Skool",
                style: AppTextStyles.normal700(
                    fontSize: 16, color: AppColors.bgXplore1))
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 24, left: 10, right: 10),
        child: Wrap(
          children: [
            Text("Get Started now",
                style: AppTextStyles.normal700(
                    fontSize: 32, color: AppColors.bookText)),
            Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  child: Text(
                    "Log in and simplify your school processes",
                    style: AppTextStyles.normal400(
                        fontSize: 14, color: AppColors.assessmentColor2),
                  ),
                )
              ],
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter Username',
                      filled: true,
                      fillColor: AppColors.assessmentColor1,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Enter Password',
                      filled: true,
                      fillColor: AppColors.assessmentColor1,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: Icon(Icons.visibility_off),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Enter School Code',
                      filled: true,
                      fillColor: AppColors.assessmentColor1,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: Icon(Icons.visibility_off_rounded),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CustomBlueElevatedButton(
                    text: 'Login',
                    onPressed: () {},
                    backgroundColor: AppColors.aicircle,
                    textStyle: AppTextStyles.italicTitle700(
                        fontSize: 14, color: AppColors.assessmentColor1),
                    padding:
                        EdgeInsets.symmetric(vertical: 14, horizontal: 140),
                  )
                ],
              ),
            ))
          ],
        ),
      )
    ]);
  }
}
