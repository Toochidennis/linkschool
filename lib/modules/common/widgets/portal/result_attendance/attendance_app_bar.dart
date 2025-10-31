// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class AttendanceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSearchPressed;

  const AttendanceAppBar({super.key, this.onSearchPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryLight,
      elevation: 0,
      title: Text(
        'Attendance',
        style: AppTextStyles.normal600(fontSize: 20, color: AppColors.backgroundLight),
      ),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Image.asset('assets/icons/arrow_back.png',
            color: AppColors.backgroundLight, width: 34.0, height: 34.0),
      ),
      actions: [
        IconButton(
          onPressed: onSearchPressed,
          icon: SvgPicture.asset(
            'assets/icons/result/search.svg',
            color: AppColors.backgroundLight,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
