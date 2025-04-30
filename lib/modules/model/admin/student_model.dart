class Student {
  final int id;
  final String name;
  final String surname;
  final String firstName;
  final String middleName;
  final String registrationNo;
  final String? pictureUrl;
  bool isSelected;
  bool hasAttended;
  
  Student({
    required this.id,
     required this.name,
    required this.surname,
    required this.firstName,
    required this.middleName,
    required this.registrationNo,
    this.pictureUrl,
    this.isSelected = false,
    this.hasAttended = false,
  });

  String get fullName => '$surname $firstName ${middleName.isNotEmpty ? middleName : ''}'.trim();
  
  Student copyWith({bool? isSelected, bool? hasAttended}) {
    return Student(
      id: id,
      name: name,
      surname: surname,
      firstName: firstName,
      middleName: middleName,
      registrationNo: registrationNo,
      pictureUrl: pictureUrl,
      isSelected: isSelected ?? this.isSelected,
      hasAttended: hasAttended ?? this.hasAttended,
    );
  }
  
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
       name: json['student_name'] ?? '', 
      surname: json['surname'] ?? '',
      firstName: json['first_name'] ?? '',
      middleName: json['middle'] ?? '',
      registrationNo: json['registration_no'] ?? '',
      pictureUrl: json['picture_url'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': name,  
      'surname': surname,
      'first_name': firstName,
      'middle': middleName,
      'registration_no': registrationNo,
      'picture_url': pictureUrl,
    };
  }
}


// class Student {
//   final int id;
//   final String name;
//   final String registrationNo;
//   bool isSelected;
//   bool hasAttended; // Add this property
  
//   Student({
//     required this.id,
//     required this.name,
//     required this.registrationNo, 
//     this.isSelected = false,
//     this.hasAttended = false, // Initialize as false
//   });
  
//   // Update the copyWith method to include hasAttended
//   Student copyWith({bool? isSelected, bool? hasAttended}) {
//     return Student(
//       id: id,
//       name: name,
//       registrationNo: registrationNo, 
//       isSelected: isSelected ?? this.isSelected,
//       hasAttended: hasAttended ?? this.hasAttended,
//     );
//   }
  
//   // Keep the existing fromJson factory
//   factory Student.fromJson(Map<String, dynamic> json) {
//     return Student(
//       id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
//       name: json['student_name'] ?? '',  
//       registrationNo: json['registration_no'] ?? '',  
//     );
//   }
  
//   // Keep the existing toJson method
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'student_name': name,  
//       'registration_no': registrationNo,  
//     };
//   }
// }
