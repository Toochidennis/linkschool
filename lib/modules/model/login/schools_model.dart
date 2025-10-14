class School {
  final int id;
  final String schoolName;
  final int schoolCode;
  final String? address;
  final String? email;
  final String? website;

  School({
    required this.id,
    required this.schoolName,
    required this.schoolCode,
    this.address,
    this.email,
    this.website,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'],
      schoolName: json['school_name'] ?? '',
      schoolCode: json['school_code'] ?? 0,
      address: json['address'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_name': schoolName,
      'school_code': schoolCode,
      'address': address,
      'email': email,
      'website': website,
    };
  }
}
