import 'package:flutter/foundation.dart';

class Student {
  final int id;
  final String name;
  bool isSelected;

  Student({
    required this.id,
    required this.name,
    this.isSelected = false,
  });

  // Create a copy of student with updated isSelected value
  Student copyWith({bool? isSelected}) {
    return Student(
      id: this.id,
      name: this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  // Factory constructor to create a Student object from JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
    );
  }

  // Convert Student object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
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