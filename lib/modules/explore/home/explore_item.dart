import 'package:flutter/material.dart';

class ExploreItem {
  final Color backgroundColor;
  final Color borderColor;
  final String label;
  final Color? textColor;
  final String iconPath;
  final Widget destination;
   final String subtitle;

  ExploreItem( {
    required this.backgroundColor,
    required this.borderColor,
    this.textColor,
    required this.label,
    required this.iconPath,
    required this.destination,
    required this.subtitle,
  });
}
