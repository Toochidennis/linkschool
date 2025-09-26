class DashboardResponse {
  final int statusCode;
  final bool success;
  final DashboardData data;

  DashboardResponse({
    required this.statusCode,
    required this.success,
    required this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      statusCode: json['statusCode'],
      success: json['success'],
      data: DashboardData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "success": success,
        "data": data.toJson(),
      };
}

class DashboardData {
  final List<ActivityItem> recentQuizzes;
  final List<ActivityItem> recentActivities;
  final List<CourseGroup> courses;

  DashboardData({
    required this.recentQuizzes,
    required this.recentActivities,
    required this.courses,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      recentQuizzes: (json['recent_quizzes'] as List<dynamic>)
          .map((e) => ActivityItem.fromJson(e))
          .toList(),
      recentActivities: (json['recent_activities'] as List<dynamic>)
          .map((e) => ActivityItem.fromJson(e))
          .toList(),
      courses: (json['courses'] as List<dynamic>)
          .map((e) => CourseGroup.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        "recent_quizzes": recentQuizzes.map((e) => e.toJson()).toList(),
        "recent_activities": recentActivities.map((e) => e.toJson()).toList(),
        "courses": courses.map((e) => e.toJson()).toList(),
      };
}

class ActivityItem {
  final int id;
  final int? syllabusId;
  final int courseId;
  final String levelId;
  final String title;
  final String courseName;
  final List<ClassItem> classes;
  final String createdBy;
  final String datePosted;
  final String type;
  final String comment;

  ActivityItem({
    required this.id,
    this.syllabusId,
    required this.courseId,
    required this.levelId,
    required this.title,
    required this.courseName,
    required this.classes,
    required this.createdBy,
    required this.datePosted,
    required this.type,
    required this.comment,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'],
      syllabusId: json['syllabus_id'],
      courseId: json['course_id'],
      levelId: json['level_id'],
      title: json['title'],
      courseName: json['course_name'],
      classes: (json['classes'] as List<dynamic>)
          .map((e) => ClassItem.fromJson(e))
          .toList(),
      createdBy: json['created_by'],
      datePosted: json['date_posted'],
      type: json['type'],
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "syllabus_id": syllabusId,
        "course_id": courseId,
        "level_id": levelId,
        "title": title,
        "course_name": courseName,
        "classes": classes.map((e) => e.toJson()).toList(),
        "created_by": createdBy,
        "date_posted": datePosted,
        "type": type,
        "comment": comment,
      };
}

class ClassItem {
  final String id;
  final String name;

  ClassItem({
    required this.id,
    required this.name,
  });

  factory ClassItem.fromJson(Map<String, dynamic> json) {
    return ClassItem(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class CourseGroup {
  final int classId;
  final String className;
  final int levelId;
  final List<CourseItem> courses;

  CourseGroup({
    required this.classId,
    required this.className,
    required this.levelId,
    required this.courses,
  });

  factory CourseGroup.fromJson(Map<String, dynamic> json) {
    return CourseGroup(
      classId: json['class_id'],
      className: json['class_name'],
      levelId: json['level_id'],
      courses: (json['courses'] as List<dynamic>)
          .map((e) => CourseItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        "class_id": classId,
        "class_name": className,
        "level_id": levelId,
        "courses": courses.map((e) => e.toJson()).toList(),
      };
}

class CourseItem {
  final int courseId;
  final String courseName;

  CourseItem({
    required this.courseId,
    required this.courseName,
  });

  factory CourseItem.fromJson(Map<String, dynamic> json) {
    return CourseItem(
      courseId: json['course_id'],
      courseName: json['course_name'],
    );
  }

  Map<String, dynamic> toJson() => {
        "course_id": courseId,
        "course_name": courseName,
      };
}
