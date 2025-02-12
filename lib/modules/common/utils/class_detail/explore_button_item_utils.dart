// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';

class ExploreButtonItem extends StatelessWidget {
  final Color backgroundColor;
  final String label;
  final String iconPath;
  final VoidCallback onTap;

  const ExploreButtonItem({
    super.key,
    required this.backgroundColor,
    required this.label,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(
            top: 30.0, bottom: 15.0, left: 6, right: 8),
        child: Container(
          width: 110,
          height: 80,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(0, -1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconPath,
                width: 25,
                height: 25,
                color: AppColors.backgroundLight,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.backgroundLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
