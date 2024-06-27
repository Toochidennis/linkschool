import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../common/text_styles.dart';

class CustomIconButton extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final String iconPath;
  final String text;
  final double? height;
  final double? width;
  final Widget? destination;

  const CustomIconButton({
    super.key,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconPath,
    required this.text,
    this.height,
    this.width,
    this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return destination!;
            },
          ),
        );
      },
      child: Container(
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
                height: height,
                width: width,
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
      ),
    );
  }
}
