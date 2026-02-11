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
  final LiveSessionInfo? liveSessionInfo;

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
    this.liveSessionInfo,
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
    assignmentUrl: json['assignment_url'],
    certificateUrl: json['certificate_url'],
    assignmentInstructions: json['assignment_instructions'] ?? '',
    isFinalLesson: json['is_final_lesson'] ?? false,
    displayOrder: json['display_order'] ?? 0,
    lessonDate: json['lesson_date'] ?? '',
    assignmentDueDate: json['assignment_due_date'],
    hasQuiz: json['has_quiz'] ?? false,
    liveSessionInfo: json['live_session_info'] != null && 
                     json['live_session_info'] is Map<String, dynamic>
        ? LiveSessionInfo.fromJson(json['live_session_info'])
        : null,
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
      'live_session_info': liveSessionInfo?.toJson(),
    };
  }
}

class LiveSessionInfo {
  final String? url;
  final String? meetingId;
  final String? passcode;
  final String? startTime;
  final String? endTime;

  LiveSessionInfo({
    this.url,
    this.meetingId,
    this.passcode,
    this.startTime,
    this.endTime,
  });

  factory LiveSessionInfo.fromJson(Map<String, dynamic> json) {
    return LiveSessionInfo(
      url: json['url'],
      meetingId: json['meeting_id'],
      passcode: json['passcode'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'meeting_id': meetingId,
      'passcode': passcode,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

class Submission {
  final String? assignment;
  final int? quizScore;
  final String? submittedAt;

  Submission({
    this.assignment,
    this.quizScore,
    this.submittedAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      assignment: json['assignment'],
      quizScore: json['quiz_score'],
      submittedAt: json['submitted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignment': assignment,
      'quiz_score': quizScore,
      'submitted_at': submittedAt,
    };
  }
}
