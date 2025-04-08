// import 'package:flutter/foundation.dart';

class Student {
  final int id;
  final String name;
  final String registrationNo;
  bool isSelected;

  Student({
    required this.id,
    required this.name,
    required this.registrationNo, 
    this.isSelected = false,
  });

  // Create a copy of student with updated isSelected value
  Student copyWith({bool? isSelected}) {
    return Student(
      id: id,
      name: name,
      registrationNo: registrationNo, 
      isSelected: isSelected ?? this.isSelected,
    );
  }

  // Updated to match API response fields
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['student_name'] ?? '',  
      registrationNo: json['registration_no'] ?? '',  
    );
  }

  // Convert Student object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': name,  
      'registration_no': registrationNo,  
    };
  }
}


// class Student {
//   final int id;
//   final String name;
//   bool isSelected;

//   Student({
//     required this.id, 
//     required this.name, 
//     this.isSelected = false
//   });

//   factory Student.fromJson(Map<String, dynamic> json) {
//     return Student(
//       id: json['id'],
//       name: json['student_name'],
//     );
//   }

//   Student copyWith({
//     int? id,
//     String? name,
//     bool? isSelected,
//   }) {
//     return Student(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       isSelected: isSelected ?? this.isSelected,
//     );
//   }
// }