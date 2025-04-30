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
  
  bool get isMarkedPresent => hasAttended || isSelected;
  
  Student copyWith({
    bool? isSelected, 
    bool? hasAttended,
    String? name,
    String? surname,
    String? firstName,
    String? middleName,
    String? registrationNo,
    String? pictureUrl,
  }) {
    return Student(
      id: id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      registrationNo: registrationNo ?? this.registrationNo,
      pictureUrl: pictureUrl ?? this.pictureUrl,
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
//   final String surname;
//   final String firstName;
//   final String middleName;
//   final String registrationNo;
//   final String? pictureUrl;
//   bool isSelected;
//   bool hasAttended;

//   Student({
//     required this.id,
//     required this.name,
//     required this.surname,
//     required this.firstName,
//     required this.middleName,
//     required this.registrationNo,
//     this.pictureUrl,
//     this.isSelected = false,
//     this.hasAttended = false,
//   });

//   String get fullName =>
//       '$surname $firstName ${middleName.isNotEmpty ? middleName : ''}'.trim();

//   // Getter to determine the visual state
//   bool get isMarkedPresent => hasAttended || isSelected;

//   Student copyWith({bool? isSelected, bool? hasAttended,}) {
//     return Student(
//       id: id,
//       name: name,
//       surname: surname,
//       firstName: firstName,
//       middleName: middleName,
//       registrationNo: registrationNo,
//       pictureUrl: pictureUrl,
//       isSelected: isSelected ?? this.isSelected,
//       hasAttended: hasAttended ?? this.hasAttended,
//     );
//   }

//   factory Student.fromJson(Map<String, dynamic> json) {
//     return Student(
//       id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
//       name: json['student_name'] ?? '',
//       surname: json['surname'] ?? '',
//       firstName: json['first_name'] ?? '',
//       middleName: json['middle'] ?? '',
//       registrationNo: json['registration_no'] ?? '',
//       pictureUrl: json['picture_url'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'student_name': name,
//       'surname': surname,
//       'first_name': firstName,
//       'middle': middleName,
//       'registration_no': registrationNo,
//       'picture_url': pictureUrl,
//     };
//   }
// }
