import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class CustomDropdown extends StatelessWidget {
  final List<String> items;
  final String value;
  final Function(String?) onChanged;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.videoColor4,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 1),
              child: Container(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  item,
                  style: AppTextStyles.normal600(
                    fontSize: 12,
                    color: item == value
                        ? AppColors.backgroundLight
                        : AppColors.backgroundDark,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        style: AppTextStyles.normal600(
          fontSize: 12,
          color: AppColors.backgroundLight,
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        dropdownColor: Colors.white,
        menuMaxHeight: 200,
        itemHeight: 50,
        borderRadius: BorderRadius.circular(8),
        underline: Container(),
      ),
    );
  }
}
