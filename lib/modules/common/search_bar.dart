import 'package:flutter/material.dart';
import 'text_styles.dart';

import 'app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 50,
        child: TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            labelText: 'Search',
            labelStyle: AppTextStyles.normal500(
              fontSize: 14.0,
              color: AppColors.text10Light,
            ),
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(24.0),
              ),
              gapPadding: 4.0,
            ),
          ),
        ),
      ),
    );
  }
}
