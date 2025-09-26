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
    final registerData = json['students'] as List<dynamic>?; // Changed from 'register' to 'students'
    return AttendanceRecord(
      id: json['id'],
      count: json['attendance_count'],
      date: DateTime.parse(json['attendance_date']),
      course: json['course_id'] ?? 0,
      courseName: json['course_name'] ?? '',
      register: registerData?.map((item) => Register.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attendance_count': count,
      'attendance_date': date.toIso8601String(),
      'course_id': course,
      'course_name': courseName,
      'students': register?.map((item) => item.toJson()).toList(), // Changed to 'students' for consistency with API
    };
  }
}


class Register {
  final String id;
  final String name;

  Register({
    required this.id,
    required this.name,
  });

  factory Register.fromJson(Map<String, dynamic> json) {
    return Register(
      id: json['id'].toString(), // Ensure ID is treated as a string
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}



// import 'register_model.dart';

// class AttendanceRecord {
//   final int id;
//   final int count;
//   final DateTime date;
//   final int course;
//   final String courseName;
//   final List<Register>? register;

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
//       count: json['attendance_count'], // Changed from 'count' to 'attendance_count'
//       date: DateTime.parse(json['attendance_date']), // Changed from 'date' to 'attendance_date'
//       course: json['course_id'] ?? 0, // Changed from 'course' to 'course_id'
//       courseName: json['course_name'] ?? '',
//       register: registerData?.map((item) => Register.fromJson(item)).toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'attendance_count': count, // Updated to match API field
//       'attendance_date': date.toIso8601String(), // Updated to match API field
//       'course_id': course, // Updated to match API field
//       'course_name': courseName,
//       'register': register?.map((item) => item.toJson()).toList(),
//     };
//   }
// }