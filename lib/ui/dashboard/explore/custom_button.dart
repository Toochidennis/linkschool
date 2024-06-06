import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/common/text_styles.dart';

class CustomButton extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final String iconPath;
  final String text;

  const CustomButton(
      {super.key,
      required this.backgroundColor,
      required this.borderColor,
      required this.iconPath,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Text(
              text,
              style: AppTextStyles.buttonsText,
            ),
          ],
        ),
      ),
    );
  }
}
