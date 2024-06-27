import 'package:flutter/material.dart';

import '../../common/app_colors.dart';

class BooksButtonItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const BooksButtonItem(
      {super.key,
      required this.text,
      required this.isSelected,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          backgroundColor:
              isSelected ? AppColors.primaryLight : AppColors.booksButtonColor,
          padding: const EdgeInsets.all(10.0)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          fontFamily: 'Urbanist',
          color: isSelected
              ? AppColors.backgroundLight
              : AppColors.booksButtonTextColor,
        ),
      ),
    );
  }
}
