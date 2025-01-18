import 'package:flutter/material.dart';

class CustomOutlineButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color borderColor; 
  final Color textColor;
  final double? height;
  final double? width;

  const CustomOutlineButton({
    required this.onPressed,
    required this.text,
    required this.borderColor,
    required this.textColor,
    this.height,
    this.width,
    super.key, 
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          // Only set minimumSize if both width and height are non-null
          minimumSize: (width != null || height != null)
              ? Size(width ?? 0, height ?? 0)
              : null,
          side: BorderSide(color: borderColor, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
