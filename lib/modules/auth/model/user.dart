class User {
  final String id;
  final String name;
  final String accessLevel;
  final String schoolName;
  final Map<String, dynamic> additionalData;

  User({
    required this.id,
    required this.name,
    required this.accessLevel,
    required this.schoolName,
    this.additionalData = const {},
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      accessLevel: json['access_level'] ?? '',
      schoolName: json['school_name'] ?? '',
      additionalData: json,
    );
  }
}