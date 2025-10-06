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