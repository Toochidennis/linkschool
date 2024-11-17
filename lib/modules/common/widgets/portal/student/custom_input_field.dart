// custom_comment_input.dart
import 'package:flutter/material.dart';

// TopBorder class remains the same
class TopBorder extends InputBorder {
  const TopBorder({
    required this.borderSide,
  }) : super(borderSide: borderSide);

  @override
  final BorderSide borderSide;

  @override
  bool get isOutline => false;

  @override
  InputBorder copyWith({BorderSide? borderSide}) {
    return TopBorder(borderSide: borderSide ?? this.borderSide);
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(top: borderSide.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {double? gapStart, double? gapExtent = 0.0, double? gapPercentage = 0.0, TextDirection? textDirection}) {
    canvas.drawLine(
      rect.topLeft,
      rect.topRight,
      borderSide.toPaint(),
    );
  }

  @override
  ShapeBorder scale(double t) {
    return TopBorder(
      borderSide: borderSide.scale(t),
    );
  }

  @override
  TopBorder lerpFrom(ShapeBorder? a, double t) {
    if (a is TopBorder) {
      return TopBorder(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
      );
    }
    return this;
  }

  @override
  TopBorder lerpTo(ShapeBorder? b, double t) {
    if (b is TopBorder) {
      return TopBorder(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
      );
    }
    return this;
  }
}

class CustomCommentInput extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final VoidCallback? onSendPressed;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? hintTextColor;
  final Color? sendIconColor;
  final double? iconSize;
  final double? fontSize;
  final double topPadding;
  final double bottomPadding;

  const CustomCommentInput({
    Key? key,
    this.controller,
    this.hintText = 'Add a comment...',
    this.onSendPressed,
    this.onChanged,
    this.focusNode,
    this.textInputAction = TextInputAction.send,
    this.autofocus = false,
    this.borderColor,
    this.focusedBorderColor,
    this.hintTextColor,
    this.sendIconColor,
    this.iconSize = 20,
    this.fontSize = 14,
    this.topPadding = 22.0, // Default top padding
    this.bottomPadding = 8.0, // Default bottom padding
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultBorderColor = Colors.grey[300]!;
    final defaultFocusedBorderColor = Colors.grey[400]!;
    final defaultHintTextColor = Colors.grey[400]!;
    final defaultSendIconColor = Colors.grey[400]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          textInputAction: textInputAction,
          autofocus: autofocus,
          style: TextStyle(
            fontSize: fontSize,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: hintTextColor ?? defaultHintTextColor,
              fontSize: fontSize,
            ),
            border: TopBorder(
              borderSide: BorderSide(
                color: borderColor ?? defaultBorderColor,
                width: 1,
              ),
            ),
            focusedBorder: TopBorder(
              borderSide: BorderSide(
                color: focusedBorderColor ?? defaultFocusedBorderColor,
                width: 1,
              ),
            ),
            enabledBorder: TopBorder(
              borderSide: BorderSide(
                color: borderColor ?? defaultBorderColor,
                width: 1,
              ),
            ),
            // Add padding to top and bottom
            contentPadding: EdgeInsets.only(
              top: topPadding, 
              bottom: bottomPadding,
            ),
            // Adjust the send icon alignment
            suffixIcon: Padding(
              padding: EdgeInsets.only(top: topPadding / 2), // Adjust icon vertical alignment
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: sendIconColor ?? defaultSendIconColor,
                  size: iconSize,
                ),
                onPressed: onSendPressed,
              ),
            ),
          ),
        ),
      ],
    );
  }
}