import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class StudentSettingDialog extends StatefulWidget {
  final VoidCallback logout;
  const StudentSettingDialog({super.key, required this.logout});

  @override
  State<StudentSettingDialog> createState() => _StudentSettingDialogState();
}

class _StudentSettingDialogState extends State<StudentSettingDialog> {
  late double opacity;


  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Setting',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.eLearningBtnColor1,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () {
                widget.logout();       // Perform logout action
                Navigator.pop(context); // Close the dialog after logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.eLearningBtnColor1,
                iconColor: Colors.white,
                elevation: 4,
              ),
              child: Text(
                'Logout',
                style:AppTextStyles.normal500(fontSize: 14, color: AppColors.backgroundLight),
              ),
            ),
          ),
        ],
        backgroundColor: AppColors.backgroundLight,
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
              )
            ],
          ),
        ),
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
      ),
    );
  }
}