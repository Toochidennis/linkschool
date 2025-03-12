class Course {
  final String courseId;

  Course({required this.courseId});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(courseId: json['course_id']);
  }

  Map<String, dynamic> toJson() {
    return {"course_id": courseId};
  }
}

class StudentClassCourseRegistration {
  final String classId;
  final String term;
  final String year;
  final List<Course> course;
  final String studentId;

  StudentClassCourseRegistration({
    required this.classId,
    required this.term,
    required this.year,
    required this.course,
    required this.studentId,
  });

  factory StudentClassCourseRegistration.fromJson(Map<String, dynamic> json) {
    return StudentClassCourseRegistration(
      classId: json['class_id'],
      term: json['term'],
      year: json['year'],
      course: (json['course'] as List)
          .map((course) => Course.fromJson(course))
          .toList(),
      studentId: json['student_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "class_id": classId,
      "term": term,
      "year": year,
      "course": course.map((c) => c.toJson()).toList(),
      "student_id": studentId,
    };
  }
}
