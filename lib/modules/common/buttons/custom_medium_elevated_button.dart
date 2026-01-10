import 'package:flutter/material.dart';

class CustomMediumElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Made nullable
  final Color backgroundColor;
  final TextStyle textStyle;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const CustomMediumElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.textStyle,
    this.borderRadius = 4.0,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}

class CustomBlueElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Changed from VoidCallback to VoidCallback?
  final Color backgroundColor;
  final TextStyle textStyle;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const CustomBlueElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.textStyle,
    this.borderRadius = 16.0,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}
