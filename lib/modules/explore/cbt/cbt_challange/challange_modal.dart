// challenge_model.dart
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

  // Custom challenge fields
  final List<SelectedSubject>? subjects;
  final bool isCustomChallenge;
  final int? timeInMinutes;
  final int? questionLimit;

  // API / raw fields
  final List<String>? examIds;
  final dynamic details;
  final String? status;
  final int? authorId;
  final String? authorName;
  final String? isActive;
  final int? challengers;

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
    this.examIds,
    this.details,
    this.status,
    this.authorId,
    this.authorName,
    this.isActive,
    this.challengers,
  });

  /// Main factory — handles real API format
  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    List<String> examIds = [];
    List<SelectedSubject> subjects = [];

    // === Parse `details` field (most important!) ===
    if (json['details'] is List) {
      for (var item in json['details']) {
        if (item is Map<String, dynamic>) {
          final examId = (item['exam_id'] ?? item['id'])?.toString();
          final courseName = (item['course_name'] ?? item['subject_name'] ?? 'Unknown Subject').toString();
          final courseId = (item['course_id'] ?? item['subject_id'] ?? '').toString();
          final year = (item['year'] ?? '2024').toString();

          if (examId != null && examId.isNotEmpty) {
            examIds.add(examId);

            subjects.add(SelectedSubject(
              subjectName: courseName,
              subjectId: courseId,
              year: year,
              examId: examId,
              icon: _mapSubjectToIcon(courseName),
            ));
          }
        } else if (item is String) {
          // Legacy: details: ["57", "105"]
          examIds.add(item);
          // Optional: create placeholder subject
          subjects.add(SelectedSubject(
            subjectName: 'Subject ${subjects.length + 1}',
            subjectId: '',
            year: '2024',
            examId: item,
            icon: 'default',
          ));
        }
      }
    }

    // Fallback to exam_ids if details is missing
    if (examIds.isEmpty && json['exam_ids'] is List) {
      examIds = (json['exam_ids'] as List).map((e) => e.toString()).toList();
    }

    final timeLimit = json['time_limit'] is int ? json['time_limit'] : null;

    return ChallengeModel(
      id: json['id']?.toString(),
      title: json['title']?.toString() ?? 'Untitled Challenge',
      description: json['description']?.toString() ?? '',
      icon: Icons.emoji_events,
      xp: json['score'] ?? json['xp'] ?? 0,
      gradient: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      participants: json['challengers'] ?? 0,
      difficulty: _calculateDifficulty(timeLimit),
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 1)),
      progress: 0.0,
      timeInMinutes: timeLimit,
      questionLimit: json['count_per_exam'],
      examIds: examIds.isNotEmpty ? examIds : null,
      details: json['details'],
      status: json['status']?.toString(),
      authorId: json['author_id'] is int ? json['author_id'] : int.tryParse(json['author_id']?.toString() ?? ''),
      authorName: json['author_name']?.toString(),
      isActive: json['is_active']?.toString(),
      challengers: json['challengers'],
      isCustomChallenge: json['author_id'] != null, // All personal = custom
      subjects: subjects.isNotEmpty ? subjects : null,
    );
  }

  static String _calculateDifficulty(int? timeLimit) {
    if (timeLimit == null) return 'Medium';
    if (timeLimit <= 30) return 'Hard';
    if (timeLimit <= 60) return 'Medium';
    return 'Easy';
  }

  /// Optional: Map subject name to icon
  static String _mapSubjectToIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('math')) return 'calculate';
    if (lower.contains('english')) return 'menu_book';
    if (lower.contains('literature')) return 'auto_stories';
    if (lower.contains('science') || lower.contains('biology') || lower.contains('physics') || lower.contains('chemistry')) {
      return 'science';
    }
    if (lower.contains('history')) return 'history_edu';
    return 'book';
  }

  // Helper getters
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isActiveNow => DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'score': xp,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'time_limit': timeInMinutes,
      'count_per_exam': questionLimit,
      'exam_ids': examIds,
      'details': subjects?.map((s) => {
        'exam_id': s.examId,
        'course_name': s.subjectName,
        'course_id': s.subjectId,
        'year': s.year,
      }).toList(),
      'status': status,
      'author_id': authorId,
      'author_name': authorName,
    };
  }

  ChallengeModel copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    int? xp,
    List<Color>? gradient,
    int? participants,
    String? difficulty,
    DateTime? startDate,
    DateTime? endDate,
    double? progress,
    List<SelectedSubject>? subjects,
    bool? isCustomChallenge,
    int? timeInMinutes,
    int? questionLimit,
    List<String>? examIds,
    dynamic details,
    String? status,
    int? authorId,
    String? authorName,
    String? isActive,
    int? challengers,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      xp: xp ?? this.xp,
      gradient: gradient ?? this.gradient,
      participants: participants ?? this.participants,
      difficulty: difficulty ?? this.difficulty,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      progress: progress ?? this.progress,
      subjects: subjects ?? this.subjects,
      isCustomChallenge: isCustomChallenge ?? this.isCustomChallenge,
      timeInMinutes: timeInMinutes ?? this.timeInMinutes,
      questionLimit: questionLimit ?? this.questionLimit,
      examIds: examIds ?? this.examIds,
      details: details ?? this.details,
      status: status ?? this.status,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isActive: isActive ?? this.isActive,
      challengers: challengers ?? this.challengers,
    );
  }
}

// Keep your response classes unchanged
class ChallengeResponse {
  final int statusCode;
  final bool success;
  final String message;
  final ChallengeData data;

  ChallengeResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory ChallengeResponse.fromJson(Map<String, dynamic> json) {
    return ChallengeResponse(
      statusCode: json['statusCode'] ?? 200,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ChallengeData.fromJson(json['data'] ?? {}),
    );
  }
}

class ChallengeData {
  final List<ChallengeModel> recommended;
  final List<ChallengeModel> personal;
  final List<ChallengeModel> active;
  final List<ChallengeModel> upcoming;

  ChallengeData({
    required this.recommended,
    required this.personal,
    required this.active,
    required this.upcoming,
  });

  factory ChallengeData.fromJson(Map<String, dynamic> json) {
    return ChallengeData(
      recommended: _parseList(json['recommended']),
      personal: _parseList(json['personal']),
      active: _parseList(json['active']),
      upcoming: _parseList(json['upcoming']),
    );
  }

  static List<ChallengeModel> _parseList(dynamic items) {
    if (items is! List) return [];
    return items.map((e) => ChallengeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  List<ChallengeModel> get allChallenges {
    return [...recommended, ...personal, ...active, ...upcoming];
  }
}