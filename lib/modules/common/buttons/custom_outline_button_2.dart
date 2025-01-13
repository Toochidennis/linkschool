import 'package:flutter/material.dart';

class CustomOutlineButton2 extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color borderColor;
  final Color textColor;
  final double fontSize;
  final double borderRadius;
  final double buttonHeight;

  const CustomOutlineButton2({
    super.key,
    required this.onPressed,
    required this.text,
    this.borderColor = Colors.blue, // Default border color
    this.textColor = Colors.blue, // Default text color
    this.fontSize = 18, // Default font size
    this.borderRadius = 10.0, // Default border radius
    this.buttonHeight = 48, // Default button height
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor),
        minimumSize: Size(double.infinity, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontWeight: FontWeight.w600, // Customize as needed
        ),
      ),
    );
  }
}