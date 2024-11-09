// lib/widgets/settings_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/admin_portal/result/assessment_settings.dart';
import 'package:linkschool/modules/admin_portal/result/behaviour_settings_screen.dart';
import 'package:linkschool/modules/admin_portal/result/grading_settings.dart';



class SettingsSection extends StatelessWidget {
  const SettingsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: _buildSettingsBox(
              'assets/icons/result/assessment.svg',
              'Assessment',
              AppColors.boxColor1,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AssessmentSettingScreen())),
            ),
          ),
          Expanded(
            child: _buildSettingsBox(
              'assets/icons/result/grading.svg',
              'Grading',
              AppColors.boxColor2,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GradingSettingsScreen())),
            ),
          ),
          Expanded(
            child: _buildSettingsBox(
              'assets/icons/result/behaviour.svg',
              'Behaviour',
              AppColors.boxColor3,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BehaviourSettingScreen())),
            ),
          ),
          Expanded(
            child: _buildSettingsBox(
              'assets/icons/result/tool.svg',
              'Tools',
              AppColors.boxColor4,
              () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsBox(String iconPath, String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        height: 90,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2.0)),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.avatarbgColor,
                child: SvgPicture.asset(iconPath, width: 24, height: 24),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              text,
              style: AppTextStyles.normal600(fontSize: 12, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}