import 'package:flutter/material.dart';

class CbtDiscussionUpdateItem {
  final int id;
  final String title;
  final String body;
  final int commentsCount;
  final IconData icon;
  final Color accentColor;
  final String badge;
  final String timeLabel;

  const CbtDiscussionUpdateItem({
    required this.id,
    required this.title,
    required this.body,
    required this.commentsCount,
    required this.icon,
    required this.accentColor,
    required this.badge,
    required this.timeLabel,
  });

  String get previewText {
    final text = body
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return text;
  }

  String get plainTitle {
    return title
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
