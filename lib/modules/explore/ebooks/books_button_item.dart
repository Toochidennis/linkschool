import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/text_styles.dart';

import '../../common/app_colors.dart';

class BooksButtonItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const BooksButtonItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: _bookButtonStyle(isSelected),
      child: Text(
        label,
        style: _bookTextStyle(isSelected),
      ),
    );
  }

  ButtonStyle _bookButtonStyle(bool isSelected) {
    return TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      backgroundColor:
          isSelected ? AppColors.primaryLight : AppColors.booksButtonColor,
      padding: const EdgeInsets.all(10.0),
    );
  }

  TextStyle _bookTextStyle(bool isSelected) {
    return AppTextStyles.normal600(
      fontSize: 16.0,
      color: isSelected
          ? AppColors.backgroundLight
          : AppColors.booksButtonTextColor,
    );
  }
}
