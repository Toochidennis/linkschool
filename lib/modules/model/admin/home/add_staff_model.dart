class Staff {
  final int id;
  final String? photo;
  final String? lastName;
  final String? firstName;
  final String? middleName;
  final String? gender;
  final String? birthDate;
  final String? address;
  final String? city;
  final dynamic state; // Can be int or String
  final String? country;
  final String? phoneNumber;
  final String? emailAddress;
  final String? religion;
  final String? maritalStatus;
  final String? lgaOrigin;
  final String? stateOrigin;
  final String? nationality;
  final String? homeTown;
  final String? healthStatus;
  final String? pastRecord;
  final String? pastRecordExtra;
  final String? personalRecord;
  final String? employmentHistory;
  final String? referees;
  final String? extraNote;
  final String? registrationTime;
  final String? nextOfKinName;
  final String? nextOfKinAddress;
  final String? nextOfKinEmail;
  final String? nextOfKinPhone;
  final String? employmentDate;
  final String? employmentStatus;
  final String? healthAppraisal;
  final String? generalAppraisal;
  final int? grade;
  final dynamic department; // Can be int or String
  final int? section;
  final int? designation;
  final String accessLevel;
  final String staffNo;

  Staff({
    required this.id,
    this.photo,
    this.lastName,
    this.firstName,
    this.middleName,
    this.gender,
    this.birthDate,
    this.address,
    this.city,
    this.state,
    this.country,
    this.phoneNumber,
    this.emailAddress,
    this.religion,
    this.maritalStatus,
    this.lgaOrigin,
    this.stateOrigin,
    this.nationality,
    this.homeTown,
    this.healthStatus,
    this.pastRecord,
    this.pastRecordExtra,
    this.personalRecord,
    this.employmentHistory,
    this.referees,
    this.extraNote,
    this.registrationTime,
    this.nextOfKinName,
    this.nextOfKinAddress,
    this.nextOfKinEmail,
    this.nextOfKinPhone,
    this.employmentDate,
    this.employmentStatus,
    this.healthAppraisal,
    this.generalAppraisal,
    this.grade,
    this.department,
    this.section,
    this.designation,
    required this.accessLevel,
    required this.staffNo,
  });

  // Get full name
  String get fullName {
    final parts = [lastName, firstName, middleName]
        .where((part) => part != null && part.isNotEmpty)
        .toList();
    return parts.isEmpty ? 'Unknown' : parts.join(' ');
  }

  // Check if staff is active
  bool get isActive {
    return employmentStatus == '1' || employmentStatus?.toLowerCase() == 'active';
  }

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'] as int,
      photo: json['photo'] as String?,
      lastName: json['last_name'] as String?,
      firstName: json['first_name'] as String?,
      middleName: json['middle_name'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birth_date'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'],
      country: json['country'] as String?,
      phoneNumber: json['phone_number'] as String?,
      emailAddress: json['email_address'] as String?,
      religion: json['religion'] as String?,
      maritalStatus: json['marital_status'] as String?,
      lgaOrigin: json['lga_origin'] as String?,
      stateOrigin: json['state_origin'] as String?,
      nationality: json['nationality'] as String?,
      homeTown: json['home_town'] as String?,
      healthStatus: json['health_status'] as String?,
      pastRecord: json['past_record'] as String?,
      pastRecordExtra: json['past_record_extra'] as String?,
      personalRecord: json['personal_record'] as String?,
      employmentHistory: json['employment_history'] as String?,
      referees: json['referees'] as String?,
      extraNote: json['extra_note'] as String?,
      registrationTime: json['registrationtime'] as String?,
      nextOfKinName: json['next_of_kin_name'] as String?,
      nextOfKinAddress: json['next_of_kin_address'] as String?,
      nextOfKinEmail: json['next_of_kin_email'] as String?,
      nextOfKinPhone: json['next_of_kin_phone'] as String?,
      employmentDate: json['employment_date'] as String?,
      employmentStatus: json['employment_status'] as String?,
      healthAppraisal: json['health_appraisal'] as String?,
      generalAppraisal: json['general_appraisal'] as String?,
      grade: json['grade'] as int?,
      department: json['department'],
      section: json['section'] as int?,
      designation: json['designation'] as int?,
      accessLevel: json['access_level'] as String? ?? 'staff',
      staffNo: json['staff_no'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photo': photo,
      'last_name': lastName,
      'first_name': firstName,
      'middle_name': middleName,
      'gender': gender,
      'birth_date': birthDate,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'phone_number': phoneNumber,
      'email_address': emailAddress,
      'religion': religion,
      'marital_status': maritalStatus,
      'lga_origin': lgaOrigin,
      'state_origin': stateOrigin,
      'nationality': nationality,
      'home_town': homeTown,
      'health_status': healthStatus,
      'past_record': pastRecord,
      'past_record_extra': pastRecordExtra,
      'personal_record': personalRecord,
      'employment_history': employmentHistory,
      'referees': referees,
      'extra_note': extraNote,
      'registrationtime': registrationTime,
      'next_of_kin_name': nextOfKinName,
      'next_of_kin_address': nextOfKinAddress,
      'next_of_kin_email': nextOfKinEmail,
      'next_of_kin_phone': nextOfKinPhone,
      'employment_date': employmentDate,
      'employment_status': employmentStatus,
      'health_appraisal': healthAppraisal,
      'general_appraisal': generalAppraisal,
      'grade': grade,
      'department': department,
      'section': section,
      'designation': designation,
      'access_level': accessLevel,
      'staff_no': staffNo,
    };
  }

  // Convert to display map for UI compatibility
 Map<String, dynamic> toDisplayMap() {
  // Map access level to role with a simpler approach
  String displayRole;
  if (accessLevel == 'admin') {
    displayRole = 'Admin';
  } else {
    displayRole = 'Staff';
  }
  
  return {
    'id': staffNo,
    'name': fullName,
    'email': emailAddress ?? 'No email',
    'phone': phoneNumber ?? 'No phone',
    'gender': gender ?? 'male',
    'role': displayRole,  // Now returns either 'Admin' or 'Staff'
    'courses': <String>[], 
    'level': '',
    'class': '',
    'status': isActive ? 'Active' : 'Inactive',
    'joinDate': employmentDate ?? '',
    'salary': '',
    'address': address ?? '',
  };
}
}