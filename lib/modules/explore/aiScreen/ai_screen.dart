import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/aiScreen/aichatbot.dart';

class AiScreen extends StatefulWidget {
  @override
  _AiScreenState createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 200,
                child: Container(
                  width: 320,
                  height: 224,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.textFieldLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Hello, nice to see you here! By pressing the "Start chat" button, you agree to have your personal data processed as described in our Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.normal400(
                            fontSize: 18, color: AppColors.aitext),
                      ),
                      const SizedBox(height: 20),
                      CustomLongElevatedButton(
                        text: 'Start Chat',
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Aichatbot())),
                        backgroundColor: AppColors.eLearningBtnColor1,
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 150,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.aicircle,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/Ai-cion.svg',
                    color: Colors.white,
                    fit: BoxFit.contain,
                    height: 16,
                    width: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
