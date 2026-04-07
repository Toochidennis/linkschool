// challenge_model.dart
import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/create_challenge.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';

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
    final groupedSubjects = <String, Map<String, dynamic>>{};

    void addGroupedSubject({
      required String subjectName,
      required String subjectId,
      required String yearValue,
      required String? examId,
      required int questionCount,
    }) {
      final key = '${subjectId}__${subjectName}';
      final group = groupedSubjects.putIfAbsent(
        key,
        () => <String, dynamic>{
          'subjectName': subjectName,
          'subjectId': subjectId,
          'firstExamId': examId,
          'questionCount': questionCount,
          'years': <YearModel>[],
        },
      );

      (group['years'] as List<YearModel>).add(
        YearModel(
          id: examId ?? yearValue,
          year: yearValue,
        ),
      );
      group['firstExamId'] ??= examId ?? yearValue;
      group['questionCount'] ??= questionCount;
    }

    // Preferred formats: subjects, then items
    final sourceSubjects = json['subjects'] is List
        ? json['subjects']
        : json['items'] is List
            ? json['items']
            : null;

    if (sourceSubjects is List) {
      for (var item in sourceSubjects) {
        if (item is Map<String, dynamic>) {
          final courseName =
              (item['course_name'] ?? item['subject_name'] ?? 'Unknown Subject')
                  .toString();
          final courseId =
              (item['course_id'] ?? item['subject_id'] ?? '').toString();
          final questionCount =
              item['question_count'] ?? item['question_limit'] ?? item['count_per_exam'] ?? json['count_per_exam'] ?? 40;
          final parsedQuestionCount = questionCount is int
              ? questionCount
              : int.tryParse(questionCount.toString()) ?? 40;
          final years = (item['years'] is List)
              ? (item['years'] as List).map((year) => year.toString()).toList()
              : <String>[];

          if (years.isNotEmpty) {
            for (final year in years) {
              final examId = year;
              examIds.add(examId);
              addGroupedSubject(
                subjectName: courseName,
                subjectId: courseId,
                yearValue: year,
                examId: examId,
                questionCount: parsedQuestionCount,
              );
            }
          } else {
            addGroupedSubject(
              subjectName: courseName,
              subjectId: courseId,
              yearValue: '2024',
              examId: null,
              questionCount: parsedQuestionCount,
            );
          }
        }
      }
    }

    // Legacy fallback: details
    if (groupedSubjects.isEmpty && json['details'] is List) {
      for (var item in json['details']) {
        if (item is Map<String, dynamic>) {
          final examId = (item['exam_id'] ?? item['id'])?.toString();
          final courseName = (item['course_name'] ?? item['subject_name'] ?? 'Unknown Subject').toString();
          final courseId = (item['course_id'] ?? item['subject_id'] ?? '').toString();
          final year = (item['year'] ?? '2024').toString();
          final questionCount = item['question_limit'] ?? item['count_per_exam'] ?? json['count_per_exam'] ?? 40;
          final parsedQuestionCount = questionCount is int
              ? questionCount
              : int.tryParse(questionCount.toString()) ?? 40;

          if (examId != null && examId.isNotEmpty) {
            examIds.add(examId);
            addGroupedSubject(
              subjectName: courseName,
              subjectId: courseId,
              yearValue: year,
              examId: examId,
              questionCount: parsedQuestionCount,
            );
          }
        } else if (item is String) {
          // Legacy: details: ["57", "105"]
          examIds.add(item);
          addGroupedSubject(
            subjectName: 'Subject ${subjects.length + 1}',
            subjectId: '',
            yearValue: item,
            examId: item,
            questionCount: json['count_per_exam'] is int
                ? json['count_per_exam']
                : int.tryParse(json['count_per_exam']?.toString() ?? '') ?? 40,
          );
        }
      }
    }

    if (groupedSubjects.isNotEmpty) {
      subjects = groupedSubjects.values.map((group) {
        final selectedYears = group['years'] as List<YearModel>;
        final firstYear = selectedYears.isNotEmpty ? selectedYears.first.year : '2024';
        final firstExamId = (group['firstExamId'] ?? '').toString();

        return SelectedSubject(
          subjectName: group['subjectName']?.toString() ?? 'Unknown Subject',
          subjectId: group['subjectId']?.toString() ?? '',
          year: firstYear,
          examId: firstExamId,
          icon: _mapSubjectToIcon(group['subjectName']?.toString() ?? 'Unknown Subject'),
          questionCount: (group['questionCount'] is int)
              ? group['questionCount'] as int
              : int.tryParse(group['questionCount']?.toString() ?? '') ?? 40,
          selectedYears: selectedYears,
        );
      }).toList();
    }

    // Fallback to exam_ids if details is missing
    if (examIds.isEmpty && json['exam_ids'] is List) {
      examIds = (json['exam_ids'] as List).map((e) => e.toString()).toList();
    }

    final timeLimit = json['time_limit'] is int
        ? json['time_limit']
        : json['duration'] is int
            ? json['duration']
            : int.tryParse(json['time_limit']?.toString() ?? '') ??
                int.tryParse(json['duration']?.toString() ?? '');
    final totalQuestionCount = subjects.fold<int>(
      0,
      (sum, subject) => sum + subject.questionCount,
    );

    final authorName = _extractAuthorName(json);

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
      questionLimit: json['count_per_exam'] is int
          ? json['count_per_exam']
          : totalQuestionCount > 0
              ? totalQuestionCount
              : null,
      examIds: examIds.isNotEmpty ? examIds : null,
      details: json['items'] ?? json['details'],
      status: json['status']?.toString(),
      authorId: json['author_id'] is int ? json['author_id'] : int.tryParse(json['author_id']?.toString() ?? ''),
      authorName: authorName,
      isActive: json['is_active']?.toString(),
      challengers: json['challengers'],
      isCustomChallenge: json['author_id'] != null, // All personal = custom
      subjects: subjects.isNotEmpty ? subjects : null,
    );
  }

  static String? _extractAuthorName(Map<String, dynamic> json) {
    final directKeys = [
      json['author_name'],
      json['authorName'],
      json['username'],
      json['created_by'],
    ];

    for (final value in directKeys) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }

    final author = json['author'];
    if (author is Map<String, dynamic>) {
      final nestedKeys = [
        author['name'],
        author['username'],
        author['full_name'],
        author['first_name'],
      ];
      for (final value in nestedKeys) {
        final text = value?.toString().trim();
        if (text != null && text.isNotEmpty) {
          return text;
        }
      }

      final first = author['first_name']?.toString().trim() ?? '';
      final last = author['last_name']?.toString().trim() ?? '';
      final combined = '$first $last'.trim();
      if (combined.isNotEmpty) return combined;
    }

    return null;
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
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'time_limit': timeInMinutes,
      'items': subjects?.map((s) {
        final years = s.selectedYears.isNotEmpty
            ? s.selectedYears
            : [
                YearModel(
                  id: s.examId,
                  year: s.year,
                ),
              ];

        return {
          'course_name': s.subjectName,
          'course_id': s.subjectId,
          'years': years.map((year) => int.tryParse(year.year) ?? year.year).toList(),
          'question_count': s.questionCount,
        };
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
