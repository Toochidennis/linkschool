class LessonDetailResponse {
  final int statusCode;
  final bool success;
  final LessonDetailData data;

  LessonDetailResponse({
    required this.statusCode,
    required this.success,
    required this.data,
  });

  factory LessonDetailResponse.fromJson(Map<String, dynamic> json) {
    return LessonDetailResponse(
      statusCode: json['statusCode'] ?? 0,
      success: json['success'] ?? false,
      data: LessonDetailData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'success': success,
      'data': data.toJson(),
    };
  }
}

class LessonDetailData {
  final Lesson lesson;
  final Submission? submission;

  LessonDetailData({
    required this.lesson,
    this.submission,
  });

  factory LessonDetailData.fromJson(Map<String, dynamic> json) {
    return LessonDetailData(
      lesson: Lesson.fromJson(json['lesson'] ?? {}),
      submission: json['submission'] != null
          ? Submission.fromJson(json['submission'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lesson': lesson.toJson(),
      'submission': submission?.toJson(),
    };
  }
}

class Lesson {
  final int id;
  final String title;
  final String? description;
  final String goals;
  final String objectives;
  final String videoUrl;
  final String recordedVideoUrl;
  final String materialUrl;
  final String assignmentUrl;
  final String? certificateUrl;
  final String assignmentInstructions;
  final bool isFinalLesson;
  final int displayOrder;
  final String lessonDate;
  final String? assignmentDueDate;
  final bool hasQuiz;

  Lesson({
    required this.id,
    required this.title,
    this.description,
    required this.goals,
    required this.objectives,
    required this.videoUrl,
    required this.recordedVideoUrl,
    required this.materialUrl,
    required this.assignmentUrl,
    this.certificateUrl,
    required this.assignmentInstructions,
    required this.isFinalLesson,
    required this.displayOrder,
    required this.lessonDate,
    this.assignmentDueDate,
    required this.hasQuiz,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      goals: json['goals'] ?? '',
      objectives: json['objectives'] ?? '',
      videoUrl: json['video_url'] ?? '',
      recordedVideoUrl: json['recorded_video_url'] ?? '',
      materialUrl: json['material_url'] ?? '',
      assignmentUrl: json['assignment_url'] ?? '',
      certificateUrl: json['certificate_url'],
      assignmentInstructions: json['assignment_instructions'] ?? '',
      isFinalLesson: json['is_final_lesson'] ?? false,
      displayOrder: json['display_order'] ?? 0,
      lessonDate: json['lesson_date'] ?? '',
      assignmentDueDate: json['assignment_due_date'],
      hasQuiz: json['has_quiz'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'goals': goals,
      'objectives': objectives,
      'video_url': videoUrl,
      'recorded_video_url': recordedVideoUrl,
      'material_url': materialUrl,
      'assignment_url': assignmentUrl,
      'certificate_url': certificateUrl,
      'assignment_instructions': assignmentInstructions,
      'is_final_lesson': isFinalLesson,
      'display_order': displayOrder,
      'lesson_date': lessonDate,
      'assignment_due_date': assignmentDueDate,
      'has_quiz': hasQuiz,
    };
  }
}

class Submission {
  // Since the structure is not provided, using a flexible approach
  final Map<String, dynamic>? data;

  Submission({this.data});

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(data: json);
  }

  Map<String, dynamic> toJson() {
    return data ?? {};
  }
}