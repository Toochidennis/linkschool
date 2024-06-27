import 'package:flutter/material.dart';

class ExploreItem{
  final Color backgroundColor;
  final Color borderColor;final String label;
  final String iconPath;
  final Widget destination;

  ExploreItem({
    required this.backgroundColor,
    required this.borderColor,
    required this.label,
    required this.iconPath,
    required this.destination,
  });
}