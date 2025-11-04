class CourseRegistrationModel {
  final int studentId;
  final String studentName;
  final int courseCount;
  final String? classId;
  final String? term;
  final String? year;

  CourseRegistrationModel(
      {required this.studentId,
      required this.studentName,
      required this.courseCount,
      this.classId,
      this.term,
      this.year});

  factory CourseRegistrationModel.fromJson(Map<String, dynamic> json) {
    return CourseRegistrationModel(
      studentId: json['id'],
      studentName: json['student_name'],
      courseCount: json['course_count'],
      classId: json['class_id'],
      term: json['term'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': studentId,
      'student_name': studentName,
      'course_count': courseCount,
      'class_id': classId,
      'term': term,
      'year': year,
    };
  }
}
