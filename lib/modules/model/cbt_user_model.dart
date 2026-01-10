/// Model class for CBT user data
class CbtUserModel {
  final int? id;
  final String? username;
  final String name;
  final String email;
  final String? profilePicture;
  final int attempt;
  final int subscribed;
  final String? reference;
  final String? createdAt;

  CbtUserModel({
    this.id,
    this.username,
    required this.name,
    required this.email,
    this.profilePicture,
    this.attempt = 0,
    this.subscribed = 0,
    this.reference,
    this.createdAt,
  });

  /// Create CbtUserModel from JSON
  factory CbtUserModel.fromJson(Map<String, dynamic> json) {
    return CbtUserModel(
      id: json['id'] as int?,
      username: json['username'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profilePicture: json['profile_picture'] as String?,
      attempt: json['attempt'] as int? ?? 0,
      subscribed: json['subscribed'] as int? ?? 0,
      reference: json['reference'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  /// Convert CbtUserModel to JSON for POST request
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'subscribed': subscribed,
      'profile_picture': profilePicture ?? '',
      'attempt': attempt,
      'reference': reference ?? '',
    };
  }

  /// Create a copy of the model with updated fields
  CbtUserModel copyWith({
    int? id,
    String? username,
    String? name,
    String? email,
    String? profilePicture,
    int? attempt,
    int? subscribed,
    String? reference,
    String? createdAt,
  }) {
    return CbtUserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      attempt: attempt ?? this.attempt,
      subscribed: subscribed ?? this.subscribed,
      reference: reference ?? this.reference,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'CbtUserModel(id: $id, name: $name, email: $email, attempt: $attempt, subscribed: $subscribed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CbtUserModel &&
        other.id == id &&
        other.username == username &&
        other.name == name &&
        other.email == email &&
        other.profilePicture == profilePicture &&
        other.attempt == attempt &&
        other.subscribed == subscribed &&
        other.reference == reference &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        name.hashCode ^
        email.hashCode ^
        profilePicture.hashCode ^
        attempt.hashCode ^
        subscribed.hashCode ^
        reference.hashCode ^
        createdAt.hashCode;
  }
}
