import 'package:flutter/material.dart';

// Custom clipper for backward slash shape on the right side with curved top-left corner
class BackwardSlashClipper extends CustomClipper<Path> {
  final double borderRadius;

  BackwardSlashClipper({this.borderRadius = 8.0});

  @override
  Path getClip(Size size) {
    Path path = Path();
    
    // Start from the left side, below the curve
    path.moveTo(0, borderRadius);
    
    // Create curved top-left corner
    path.quadraticBezierTo(
      0, 0,  // Control point at corner
      borderRadius, 0,  // End point on top edge
    );
    
    // Draw along the top, but stop before the end
    path.lineTo(size.width - 30, 0);
    
    // Create the backward slash (\) on the right side
    // This line goes down and to the left
    path.lineTo(size.width, size.height);
    
    // Draw along the bottom
    path.lineTo(0, size.height);
    
    // Close the path back to starting point
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(covariant BackwardSlashClipper oldClipper) {
    return oldClipper.borderRadius != borderRadius;
  }
}
