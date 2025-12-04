// Add to your ChallengeModel class
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/create_challenge.dart';

class ChallengeModel {
  final String? id;
  final String title;
  final String description;
  final IconData icon;
  final int xp;
  final List<Color> gradient;
  final int participants;
  final String difficulty;
  final DateTime startDate;
  final DateTime endDate;
  final double progress;
  final List<SelectedSubject>? subjects; // Add this
  final bool? isCustomChallenge; // Add this
  final int? timeInMinutes; // Add this
  final int? questionLimit; // Add this

  ChallengeModel({
    this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xp,
    required this.gradient,
    required this.participants,
    required this.difficulty,
    required this.startDate,
    required this.endDate,
    this.progress = 0.0,
    this.subjects,
    this.isCustomChallenge = false,
    this.timeInMinutes,
    this.questionLimit,
  });
}