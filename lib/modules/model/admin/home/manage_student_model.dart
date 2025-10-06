import 'dart:convert';

class StudentPhoto {
  final String? file;
  final String? fileName;
  final String? oldFileName;

  StudentPhoto({
    this.file,
    this.fileName,
    this.oldFileName,
  });

  factory StudentPhoto.fromJson(Map<String, dynamic> json) {
    return StudentPhoto(
      file: json['file'] as String?,
      fileName: json['file_name'] as String?,
      oldFileName: json['old_file_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'file_name': fileName,
      'old_file_name': oldFileName,
    };
  }
}

class Students {
  final int id;
  final StudentPhoto? photo;
  final String? photoPath; // Add this to store file paths from server
  final String surname;
  final String firstName;
  final String middle;
  final String gender;
  final String? birthDate;
  final String? address;
  final int? city;
  final int? state;
  final int? country;
  final String? email;
  final String? religion;
  final String? guardianName;        // Changed to nullable
  final String? guardianAddress;     // Changed to nullable
  final String? guardianEmail;
  final String? guardianPhoneNo;     // Changed to nullable
  final String? lgaOrigin;
  final String? stateOrigin;
  final String? nationality;
  final String? healthStatus;
  final String? dateAdmitted;
  final String? studentStatus;
  final String? pastRecord;
  final String? academicResult;
  final int classId;
  final int levelId;
  final String? registrationNo;

  Students({
    required this.id,
    this.photo,
    this.photoPath,
    required this.surname,
    required this.firstName,
    required this.middle,
    required this.gender,
    this.birthDate,
    this.address,
    this.city,
    this.state,
    this.country,
    this.email,
    this.religion,
    this.guardianName,
    this.guardianAddress,
    this.guardianEmail,
    this.guardianPhoneNo,
    this.lgaOrigin,
    this.stateOrigin,
    this.nationality,
    this.healthStatus,
    this.dateAdmitted,
    this.studentStatus,
    this.pastRecord,
    this.academicResult,
    required this.classId,
    required this.levelId,
    this.registrationNo,
  });

  factory Students.fromJson(Map<String, dynamic> json) {
    StudentPhoto? photoObj;
    String? photoPathStr;
    
    // Handle photo field - can be null, string path, or object
    if (json['photo'] != null) {
      if (json['photo'] is String) {
        final photoStr = json['photo'] as String;
        if (photoStr.isNotEmpty) {
          photoPathStr = photoStr; // Store the path
        }
      } else if (json['photo'] is Map<String, dynamic>) {
        photoObj = StudentPhoto.fromJson(json['photo'] as Map<String, dynamic>);
      }
    }

    return Students(
      id: json['id'] as int,
      photo: photoObj,
      photoPath: photoPathStr,
      surname: (json['surname'] as String?)?.trim() ?? '',
      firstName: (json['first_name'] as String?)?.trim() ?? '',
      middle: (json['middle'] as String?)?.trim() ?? '',
      gender: _normalizeGender(json['gender'] as String?),
      birthDate: json['birth_date'] as String?,
      address: json['address'] as String?,
      city: json['city'] as int?,
      state: json['state'] as int?,
      country: json['country'] as int?,
      email: json['email'] as String?,
      religion: json['religion'] as String?,
      guardianName: json['guardian_name'] as String?,
      guardianAddress: json['guardian_address'] as String?,
      guardianEmail: json['guardian_email'] as String?,
      guardianPhoneNo: json['guardian_phone_no'] as String?,
      lgaOrigin: json['lga_origin'] as String?,
      stateOrigin: json['state_origin'] as String?,
      nationality: json['nationality'] as String?,
      healthStatus: json['health_status'] as String?,
      dateAdmitted: json['date_admitted'] as String?,
      studentStatus: json['student_status'] as String?,
      pastRecord: json['past_record'] as String?,
      academicResult: json['academic_result'] as String?,
      classId: json['class_id'] as int,
      levelId: json['level_id'] as int,
      registrationNo: json['registration_no'] as String?,
    );
  }

  // Helper method to normalize gender values
  static String _normalizeGender(String? gender) {
    if (gender == null || gender.isEmpty) return '';
    final lowercase = gender.toLowerCase();
    if (lowercase == 'm') return 'male';
    if (lowercase == 'f') return 'female';
    return lowercase; // Return as-is if already 'male' or 'female'
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photo': photo?.toJson(),
      'surname': surname,
      'first_name': firstName,
      'middle': middle,
      'gender': gender,
      'birth_date': birthDate,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'email': email,
      'religion': religion,
      'guardian_name': guardianName,
      'guardian_address': guardianAddress,
      'guardian_email': guardianEmail,
      'guardian_phone_no': guardianPhoneNo,
      'lga_origin': lgaOrigin,
      'state_origin': stateOrigin,
      'nationality': nationality,
      'health_status': healthStatus,
      'date_admitted': dateAdmitted,
      'student_status': studentStatus,
      'past_record': pastRecord,
      'academic_result': academicResult,
      'class_id': classId,
      'level_id': levelId,
      'registration_no': registrationNo,
    };
  }

  String getInitials() {
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final surnameInitial = surname.isNotEmpty ? surname[0].toUpperCase() : '';
    return '$firstInitial$surnameInitial';
  }
}