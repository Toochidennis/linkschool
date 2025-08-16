class RecentData {
  final List<RecentQuiz> recentQuizzes;
  final List<RecentActivity> recentActivities;
  final List<AvailableCourse> availableCourses;

  RecentData({
    required this.recentQuizzes,
    required this.recentActivities,
    required this.availableCourses,
  });

  factory RecentData.fromJson(Map<String, dynamic> json) {
    return RecentData(
      recentQuizzes: (json['recent_quizzes'] as List<dynamic>?)
          ?.map((e) => RecentQuiz.fromJson(e))
          .toList() ??
          [],
      recentActivities: (json['recent_activities'] as List<dynamic>?)
          ?.map((e) => RecentActivity.fromJson(e))
          .toList() ??
          [],
      availableCourses: (json['available_courses'] as List<dynamic>?)
          ?.map((e) => AvailableCourse.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recent_quizzes': recentQuizzes.map((e) => e.toJson()).toList(),
      'recent_activities': recentActivities.map((e) => e.toJson()).toList(),
      'available_courses': availableCourses.map((e) => e.toJson()).toList(),
    };
  }
}

class RecentQuiz {
  final int id;
  final int? syllabusId;
  final int courseId;
  final String levelId;
  final String title;
  final String type;
  final String courseName;
  final String createdBy;
  final String datePosted;

  RecentQuiz({
    required this.id,
    this.syllabusId,
    required this.courseId,
    required this.levelId,
    required this.title,
    required this.type,
    required this.courseName,
    required this.createdBy,
    required this.datePosted,
  });

  factory RecentQuiz.fromJson(Map<String, dynamic> json) {
    return RecentQuiz(
      id: json['id'],
      syllabusId: json['syllabus_id'],
      courseId: json['course_id'],
      levelId: json['level_id'],
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      courseName: json['course_name'] ?? '',
      createdBy: json['created_by'] ?? '',
      datePosted: json['date_posted'] ?? '',
    );
  }


  Map<String, dynamic> toJson() {
    return {};
  }
}

class RecentActivity {
  final int id;
  final int? syllabusId;
  final int courseId;
  final String levelId;
  final String title;
  final String type;
  final String courseName;
  final String createdBy;
  final String datePosted;

  RecentActivity({
    required this.id,
    this.syllabusId,
    required this.courseId,
    required this.levelId,
    required this.title,
    required this.type,
    required this.courseName,
    required this.createdBy,
    required this.datePosted,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'],
      syllabusId: json['syllabus_id'],
      courseId: json['course_id'],
      levelId: json['level_id'],
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      courseName: json['course_name'] ?? '',
      createdBy: json['created_by'] ?? '',
      datePosted: json['date_posted'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'syllabus_id': syllabusId,
      'course_id': courseId,
      'level_id': levelId,
      'title': title,
      'type': type,
      'course_name': courseName,
      'created_by': createdBy,
      'date_posted': datePosted,
    };
  }
}

class AvailableCourse {
  final int syllabusId;
  final int courseId;
  final String levelId;
  final String courseName;

  AvailableCourse({
    required this.syllabusId,
    required this.courseId,
    required this.levelId,
    required this.courseName,
  });

  factory AvailableCourse.fromJson(Map<String, dynamic> json) {
    return AvailableCourse(
      syllabusId: json['syllabus_id'],
      courseId: json['course_id'],
      levelId: json['level_id'],
      courseName: json['course_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'syllabus_id': syllabusId,
      'course_id': courseId,
      'level_id': levelId,
      'course_name': courseName,
    };
  }
}