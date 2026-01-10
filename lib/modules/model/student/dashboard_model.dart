class DashboardData {
  final List<RecentQuiz> recentQuizzes;
  final List<RecentActivity> recentActivities;
  final List<AvailableCourse> availableCourses;

  DashboardData({
    required this.recentQuizzes,
    required this.recentActivities,
    required this.availableCourses,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    // Combine recent_quizzes with feeds (news and questions) as recent activities
    List<RecentActivity> activities = [];
    
    // Add recent_quizzes as activities
    if (json['recent_quizzes'] is List) {
      activities.addAll(
        (json['recent_quizzes'] as List)
            .map((e) => RecentActivity.fromJson(e))
            .toList(),
      );
    }
    
    // Add feeds.news as activities
    if (json['feeds'] is Map && json['feeds']['news'] is List) {
      activities.addAll(
        (json['feeds']['news'] as List)
            .map((e) => RecentActivity.fromFeedJson(e))
            .toList(),
      );
    }
    
    // Add feeds.questions as activities
    if (json['feeds'] is Map && json['feeds']['questions'] is List) {
      activities.addAll(
        (json['feeds']['questions'] as List)
            .map((e) => RecentActivity.fromFeedJson(e))
            .toList(),
      );
    }
    
    return DashboardData(
      recentQuizzes: (json['recent_quizzes'] as List<dynamic>?)
              ?.map((e) => RecentQuiz.fromJson(e))
              .toList() ??
          [],
      recentActivities: activities,
      availableCourses: (json['available_courses'] as List<dynamic>?)
              ?.map((e) => AvailableCourse.fromJson(e))
              .toList() ??
          [],
    );
  }
//Ho
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

  // Factory for parsing feed data (news and questions)
  factory RecentActivity.fromFeedJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'],
      syllabusId: null, // Feeds don't have syllabus_id
      courseId: 0, // Feeds don't have course_id
      levelId: '', // Feeds don't have level_id
      title: json['title'] ?? '',
      type: json['type'] ?? 'feed',
      courseName: '', // Feeds don't have course_name
      createdBy: json['author_name'] ?? '',
      datePosted: json['created_at'] ?? '',
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
