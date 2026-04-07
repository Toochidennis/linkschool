
import 'package:flutter/material.dart';

class ChallengeCourseYearModel {
  final int examId;
  final String year;

  ChallengeCourseYearModel({
    required this.examId,
    required this.year,
  });

  factory ChallengeCourseYearModel.fromJson(Map<String, dynamic> json) {
    return ChallengeCourseYearModel(
      examId: json['exam_id'] is int
          ? json['exam_id'] as int
          : int.tryParse(json['exam_id']?.toString() ?? '') ?? 0,
      year: json['year']?.toString() ?? '',
    );
  }
}

class ChallengeCourseModel {
  final int courseId;
  final String courseName;
  final List<ChallengeCourseYearModel> years;
  final String iconName;
  final Color cardColor;

  ChallengeCourseModel({
    required this.courseId,
    required this.courseName,
    required this.years,
    required this.iconName,
    required this.cardColor,
  });

  factory ChallengeCourseModel.fromJson(Map<String, dynamic> json) {
    final yearsJson = json['years'];
    final courseId = json['course_id'] is int
        ? json['course_id'] as int
        : int.tryParse(json['course_id']?.toString() ?? '') ?? 0;
    final courseName = json['course_name']?.toString() ?? '';
    return ChallengeCourseModel(
      courseId: courseId,
      courseName: courseName,
      years: yearsJson is List
          ? yearsJson
              .whereType<Map<String, dynamic>>()
              .map(ChallengeCourseYearModel.fromJson)
              .toList()
          : [],
      iconName: _pickRandomIcon(courseId, courseName),
      cardColor: _pickRandomColor(courseId, courseName),
    );
  }

  static String _pickRandomIcon(int courseId, String courseName) {
    const icons = [
      'maths',
      'english',
      'physics',
      'biology',
      'chemistry',
      'geography',
      'agric',
      'further_maths',
      'assessment',
      'tools',
    ];

    final seed = courseId != 0 ? courseId : courseName.hashCode;
    return icons[seed.abs() % icons.length];
  }

  static Color _pickRandomColor(int courseId, String courseName) {
    const colors = [
      Color(0xFF6366F1),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
      Color(0xFF8B5CF6),
      Color(0xFF14B8A6),
      Color(0xFFEF4444),
      Color(0xFF0EA5E9),
      Color(0xFFF97316),
    ];

    final seed = courseId != 0 ? courseId : courseName.hashCode;
    return colors[seed.abs() % colors.length];
  }
}
