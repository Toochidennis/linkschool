class Student {
  final int id;
  final String name;
  final String registrationNo;
  bool isSelected;
  bool hasAttended; // Add this property
  
  Student({
    required this.id,
    required this.name,
    required this.registrationNo, 
    this.isSelected = false,
    this.hasAttended = false, // Initialize as false
  });
  
  // Update the copyWith method to include hasAttended
  Student copyWith({bool? isSelected, bool? hasAttended}) {
    return Student(
      id: id,
      name: name,
      registrationNo: registrationNo, 
      isSelected: isSelected ?? this.isSelected,
      hasAttended: hasAttended ?? this.hasAttended,
    );
  }
  
  // Keep the existing fromJson factory
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['student_name'] ?? '',  
      registrationNo: json['registration_no'] ?? '',  
    );
  }
  
  // Keep the existing toJson method
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