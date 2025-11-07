import 'dart:convert';

class Courses {
  final int id;
  final String courseName;
  final String courseCode;
  final int? levelId; // Add
  final int? classId; // Add

  Courses({
    required this.id,
    required this.courseName,
    required this.courseCode,
    this.levelId,
    this.classId,
  });

  factory Courses.fromJson(Map<String, dynamic> json) {
    return Courses(
      id: json['id'] as int,
      courseName: json['course_name'] as String,
      courseCode: json['course_code'] as String,
      levelId: json['level_id'] as int?,
      classId: json['class_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_name': courseName,
      'course_code': courseCode,
      'level_id': levelId,
      'class_id': classId,
      '_db': '',
    };
  }
}



CourseAssignmentResponse courseAssignmentResponseFromJson(String str) =>
    CourseAssignmentResponse.fromJson(json.decode(str));

class CourseAssignmentResponse {
  final int statusCode;
  final bool success;
  final List<CourseAssignment> response;

  CourseAssignmentResponse({
    required this.statusCode,
    required this.success,
    required this.response,
  });

  factory CourseAssignmentResponse.fromJson(Map<String, dynamic> json) =>
      CourseAssignmentResponse(
        statusCode: json["statusCode"] ?? 0,
        success: json["success"] ?? false,
        response: json["response"] == null
            ? []
            : List<CourseAssignment>.from(
                json["response"].map((x) => CourseAssignment.fromJson(x))),
      );
}

class CourseAssignment {
  final int courseId;
  final String courseName;
  final String courseCode;
  final int classId;
  final String className;
  final int levelId;
  final String levelName;

  CourseAssignment({
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.classId,
    required this.className,
    required this.levelId,
    required this.levelName,
  });

  factory CourseAssignment.fromJson(Map<String, dynamic> json) =>
      CourseAssignment(
        courseId: json["course_id"],
        courseName: json["course_name"],
        courseCode: json["course_code"],
        classId: json["class_id"],
        className: json["class_name"],
        levelId: json["level_id"],
        levelName: json["level_name"],
      );
}