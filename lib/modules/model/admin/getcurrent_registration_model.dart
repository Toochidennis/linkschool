import 'dart:convert';

class CurrentCourseRegistrationModel {
  final String? classID;
  final String? year;
  final String? term;
  final String? student_Id;
  final int courseId;
  final String courseName;

  CurrentCourseRegistrationModel(
      {required this.student_Id,
      required this.classID,
      required this.year,
      required this.term,
      required this.courseId,
      required this.courseName});

  // Factory constructor for creating an instance from JSON
  factory CurrentCourseRegistrationModel.fromJson(
      Map<String, dynamic> json) {
    return CurrentCourseRegistrationModel(
      student_Id: json['student_id'],
      classID: json['class_Id'], // Ensure the correct JSON key
      year: json['year'],
      term: json['term'],
      courseId: json['id'],
      courseName: json['course_name'],
    );
  }

  // Convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'student_id': student_Id,
      'class_Id': classID,
      'year': year,
      'term': term,
      'id': courseId,
      'course_name': courseName
    };
  }

  // Convert JSON string to model instance
  static CurrentCourseRegistrationModel fromJsonString(String jsonString) {
    return CurrentCourseRegistrationModel.fromJson(json.decode(jsonString));
  }

  // Convert model instance to JSON string
  String toJsonString() {
    return json.encode(toJson());
  }
}
