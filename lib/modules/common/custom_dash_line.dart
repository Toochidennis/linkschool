import 'package:flutter/material.dart';

class CustomDashLine extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    var maxWidth = size.width;
    var dashWidth = 5.0;
    var dashSpace = 3.0;
    double startX = 0;

    while (startX < maxWidth) {
      canvas.drawLine(
        Offset(startX, 0), 
        Offset(startX + dashWidth, 0), 
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}