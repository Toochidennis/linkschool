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
  final String? assignmentUrl;
  final String? certificateUrl;
  final String assignmentInstructions;
  final String? assignmentSubmissionType;
  final bool isFinalLesson;
  final bool hasAttendance;
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
    this.assignmentUrl,
    this.certificateUrl,
    required this.assignmentInstructions,
    this.assignmentSubmissionType,
    required this.isFinalLesson,
    required this.hasAttendance,
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
    assignmentSubmissionType: json['assignment_submission_type'],
    isFinalLesson: json['is_final_lesson'] ?? false,
    hasAttendance: json['has_attendance'] ?? false,
    displayOrder: json['display_order'] ?? 0,
    lessonDate: json['lesson_date'] ?? '',
    assignmentDueDate: json['assignment_due_date'],
    hasQuiz: json['has_quiz'] ?? false,
    liveSessionInfo: _parseLiveSessionInfo(json['live_session_info']),
  );
}

  static LiveSessionInfo? _parseLiveSessionInfo(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map<String, dynamic>) {
      return LiveSessionInfo.fromJson(raw);
    }
    if (raw is List) {
      if (raw.isEmpty) return null;
      final first = raw.first;
      if (first is Map<String, dynamic>) {
        return LiveSessionInfo.fromJson(first);
      }
    }
    return null;
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
      'assignment_submission_type': assignmentSubmissionType,
      'is_final_lesson': isFinalLesson,
      'has_attendance': hasAttendance,
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
}class Submission {
  final String? submissionType;
  final dynamic assignment; // Changed from List to dynamic
  final String? textContent;
  final String? linkUrl;
  final int? quizScore;
  final int? assignedScore;
  final String? remark;
  final String? comment;
  final String? gradedAt;
  final String? notifiedAt;
  final String? submittedAt;

  Submission({
    this.submissionType,
    this.assignment,
    this.textContent,
    this.linkUrl,
    this.quizScore,
    this.assignedScore,
    this.remark,
    this.comment,
    this.gradedAt,
    this.notifiedAt,
    this.submittedAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      submissionType: json['submission_type'],
      assignment: json['assignment'], // Keep as-is, can be String or List
      textContent: json['text_content'],
      linkUrl: json['link_url'],
      quizScore: json['quiz_score'],
      assignedScore: json['assigned_score'],
      remark: json['remark'],
      comment: json['comment'],
      gradedAt: json['graded_at'],
      notifiedAt: json['notified_at'],
      submittedAt: json['submitted_at'],
    );
  }

  // Helper method to get assignment as a string
  String? get assignmentFile {
    if (assignment == null) return null;
    if (assignment is String) return assignment;
    if (assignment is List && (assignment as List).isNotEmpty) {
      final first = (assignment as List).first;
      if (first is Map) return first['file'];
      return first.toString();
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'submission_type': submissionType,
      'assignment': assignment,
      'text_content': textContent,
      'link_url': linkUrl,
      'quiz_score': quizScore,
      'assigned_score': assignedScore,
      'remark': remark,
      'comment': comment,
      'graded_at': gradedAt,
      'notified_at': notifiedAt,
      'submitted_at': submittedAt,
    };
  }
}

// Remove the SubmissionAttachment class if not needed elsewhere
