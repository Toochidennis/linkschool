// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';

class CustomSaveElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const CustomSaveElevatedButton({required this.onPressed, super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.eLearningBtnColor1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0)
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.backgroundLight,
            fontSize: 16.0,
            fontWeight: FontWeight.w600, 
          ),
        ),
      ),
    );
  }
}
