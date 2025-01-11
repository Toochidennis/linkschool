import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:linkschool/modules/common/app_colors.dart';


class CustomFloatingSaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final String tooltip;

  const CustomFloatingSaveButton({
    Key? key,
    required this.onPressed,
    this.icon = Icons.save,
    this.backgroundColor = AppColors.primaryLight,
    this.iconColor = AppColors.backgroundLight,
    this.tooltip = 'Save',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      shape: const CircleBorder(),
      backgroundColor: backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 7,
              spreadRadius: 7,
              offset: const Offset(3, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
    );
  }
}