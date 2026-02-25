class LessonPerformanceResponseModel {
  final int statusCode;
  final bool success;
  final String message;
  final LessonPerformanceData? data;

  LessonPerformanceResponseModel({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory LessonPerformanceResponseModel.fromJson(Map<String, dynamic> json) {
    return LessonPerformanceResponseModel(
      statusCode: json['statusCode'] is int ? json['statusCode'] as int : 0,
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? LessonPerformanceData.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class LessonPerformanceData {
  final int overallScorePercentage;
  final PerformanceCount attendance;
  final PerformanceCount assignments;
  final PerformanceCount quizzes;
  final List<LessonPerformanceItem> lessons;

  LessonPerformanceData({
    required this.overallScorePercentage,
    required this.attendance,
    required this.assignments,
    required this.quizzes,
    required this.lessons,
  });

  factory LessonPerformanceData.fromJson(Map<String, dynamic> json) {
    return LessonPerformanceData(
      overallScorePercentage: _parseInt(json['overall_score_percentage']),
      attendance: PerformanceCount.fromJson(
        json['attendance'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      ),
      assignments: PerformanceCount.fromJson(
        json['assignments'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      ),
      quizzes: PerformanceCount.fromJson(
        json['quizzes'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      ),
      lessons: (json['lessons'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(LessonPerformanceItem.fromJson)
          .toList(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class PerformanceCount {
  final int taken;
  final int supposed;

  const PerformanceCount({
    required this.taken,
    required this.supposed,
  });

  factory PerformanceCount.fromJson(Map<String, dynamic> json) {
    return PerformanceCount(
      taken: _parseInt(json['taken']),
      supposed: _parseInt(json['supposed']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class LessonPerformanceItem {
  final int lessonId;
  final String title;
  final int displayOrder;
  final bool attendanceTaken;
  final int? quizScore;
  final int? assignmentScore;

  LessonPerformanceItem({
    required this.lessonId,
    required this.title,
    required this.displayOrder,
    required this.attendanceTaken,
    required this.quizScore,
    required this.assignmentScore,
  });

  factory LessonPerformanceItem.fromJson(Map<String, dynamic> json) {
    return LessonPerformanceItem(
      lessonId: _parseInt(json['lesson_id']),
      title: json['title']?.toString() ?? '',
      displayOrder: _parseInt(json['display_order']),
      attendanceTaken: json['attendance_taken'] == true,
      quizScore: _parseNullableInt(json['quiz_score']),
      assignmentScore: _parseNullableInt(json['assignment_score']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
