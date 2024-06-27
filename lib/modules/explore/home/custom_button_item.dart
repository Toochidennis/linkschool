import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../common/text_styles.dart';

class CustomButtonItem extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final String iconPath;
  final String label;
  final double? iconHeight;
  final double? iconWidth;
  final Widget? destination;

  const CustomButtonItem({
    super.key,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconPath,
    required this.label,
    this.iconHeight,
    this.iconWidth,
    this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => destination!,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: borderColor,
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
                height: iconHeight,
                width: iconWidth,
              ),
              const SizedBox(
                width: 10.0,
              ),
              Text(
                label,
                style: AppTextStyles.normal500(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
