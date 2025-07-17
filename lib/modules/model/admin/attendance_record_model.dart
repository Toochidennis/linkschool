import 'register_model.dart';

class AttendanceRecord {
  final int id;
  final int count;
  final DateTime date;
  final int course;
  final String courseName;
  final List<Register>? register;

  AttendanceRecord({
    required this.id,
    required this.count,
    required this.date,
    this.course = 0,
    this.courseName = '',
    this.register,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    final registerData = json['register'] as List<dynamic>?;
    return AttendanceRecord(
      id: json['id'],
      count: json['attendance_count'], // Changed from 'count' to 'attendance_count'
      date: DateTime.parse(json['attendance_date']), // Changed from 'date' to 'attendance_date'
      course: json['course_id'] ?? 0, // Changed from 'course' to 'course_id'
      courseName: json['course_name'] ?? '',
      register: registerData?.map((item) => Register.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attendance_count': count, // Updated to match API field
      'attendance_date': date.toIso8601String(), // Updated to match API field
      'course_id': course, // Updated to match API field
      'course_name': courseName,
      'register': register?.map((item) => item.toJson()).toList(),
    };
  }
}




// import 'package:linkschool/modules/model/admin/register_model.dart';

// class AttendanceRecord {
//   final int id;
//   final int count;
//   final DateTime date;
//   final int course;
//   final String courseName;
//   final List<Register>? register; // Optional, used in attendance details

//   AttendanceRecord({
//     required this.id,
//     required this.count,
//     required this.date,
//     this.course = 0,
//     this.courseName = '',
//     this.register,
//   });

//   factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
//     final registerData = json['register'] as List<dynamic>?;
//     return AttendanceRecord(
//       id: json['id'],
//       count: json['count'],
//       date: DateTime.parse(json['date']),
//       course: json['course'] ?? 0,
//       courseName: json['course_name'] ?? '',
//       register: registerData?.map((item) => Register.fromJson(item)).toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'count': count,
//       'date': date.toIso8601String(),
//       'course': course,
//       'course_name': courseName,
//       'register': register?.map((item) => item.toJson()).toList(),
//     };
//   }
// }