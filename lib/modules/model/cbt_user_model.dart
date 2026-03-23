/// Model class for CBT user data

class CbtUserProfile {
  final int? id;
  final int? userId;
  final String? firstName;
  final String? lastName;
  final String? birthDate;
  final String? gender;
  final String? avatar;
  final String? createdAt;
  final String? updatedAt;

  CbtUserProfile({
    this.id,
    this.userId,
    this.firstName,
    this.lastName,
    this.birthDate,
    this.gender,
    this.avatar,
    this.createdAt,
    this.updatedAt,
  });

  factory CbtUserProfile.fromJson(Map<String, dynamic> json) {
    return CbtUserProfile(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      birthDate: json['birth_date'] as String?,
      gender: json['gender'] as String?,
      avatar: json['avatar'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'birth_date': birthDate,
        'gender': gender,
        'avatar': avatar,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class CbtUserModel {
  final int? id;
  final String? username;
  final String? name;
  final String email;
  final String? phone;
  final String? profilePicture;
  final int attempt;
  final int subscribed;
  final String? reference;
  final String? createdAt;
  final List<CbtUserProfile> profiles;
  final String? first_name;
  final String? last_name;
  final String? fcmToken;

  CbtUserModel({
    this.id,
    this.username,
    this.name,
    required this.email,
    this.phone,
    this.profilePicture,
    this.attempt = 0,
    this.subscribed = 0,
    this.reference,
    this.createdAt,
    this.profiles = const [],
    this.first_name,
    this.last_name,
    this.fcmToken,
  });

  /// Create CbtUserModel from JSON
  factory CbtUserModel.fromJson(Map<String, dynamic> json) {
    // Accepts both {user: {...}, profiles: [...]} or just user fields
    if (json.containsKey('user')) {
      final user = json['user'] as Map<String, dynamic>;
      final profiles = (json['profiles'] as List?)?.map((e) => CbtUserProfile.fromJson(e as Map<String, dynamic>)).toList() ?? [];
      return CbtUserModel(
        id: user['id'] as int?,
        username: user['username'] as String?,
        name: user['name'] as String? ?? '',
        email: user['email'] as String? ?? '',
        phone: user['phone'] as String?,
        profilePicture: user['profile_picture'] as String?,
        attempt: user['attempt'] as int? ?? 0,
        subscribed: user['subscribed'] as int? ?? 0,
        reference: user['reference'] as String?,
        createdAt: user['created_at'] as String?,
        first_name: user['first_name'] as String?,
        last_name: user['last_name'] as String?,
        fcmToken: user['fcm_token'] as String? ,
        profiles: profiles,
      );
    } else {
      return CbtUserModel(
        id: json['id'] as int?,
        username: json['username'] as String?,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String?,
        profilePicture: json['profile_picture'] as String?,
        attempt: json['attempt'] as int? ?? 0,
        subscribed: json['subscribed'] as int? ?? 0,
        reference: json['reference'] as String?,
        createdAt: json['created_at'] as String?,
          first_name: json['first_name'] as String?,
        last_name: json['last_name'] as String?,
        fcmToken: json['fcm_token'] as String? ,
        profiles: [],
      );
    }
  }

  /// Convert CbtUserModel to JSON for POST request
 Map<String, dynamic> toJson() {
  return {
    'first_name': first_name, // ✅ add
    'last_name': last_name,   // ✅ add

    'name': name,             // optional; keep if backend accepts it
    'email': email,
    'phone': phone,
    'attempt': attempt,

    // keep these only if your create endpoint expects them
    'subscribed': subscribed,
    'profile_picture': profilePicture ?? '',
    'reference': reference ?? '',
    'fcm_token': fcmToken ?? '',
  };
}

  /// Convert CbtUserModel to JSON for local persistence
  Map<String, dynamic> toPrefsJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_picture': profilePicture ?? '',
      'attempt': attempt,
      'subscribed': subscribed,
      'reference': reference ?? '',
      'created_at': createdAt,
      'first_name': first_name,
      'last_name': last_name,
      'fcm_token': fcmToken ?? '',
    };
  }


  /// Create a copy of the model with updated fields
  CbtUserModel copyWith({
    int? id,
    String? username,
    String? name,
    String? email,
    String? phone,
    String? profilePicture,
    int? attempt,
    int? subscribed,
    String? reference,
    String? createdAt,
    List<CbtUserProfile>? profiles,
    String? first_name,
    String? last_name,
    String? fcmToken,
  }) {
    return CbtUserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      attempt: attempt ?? this.attempt,
      subscribed: subscribed ?? this.subscribed,
      reference: reference ?? this.reference,
      createdAt: createdAt ?? this.createdAt,
      profiles: profiles ?? this.profiles,
      first_name: first_name ?? this.first_name,
      last_name: last_name ?? this.last_name,
      fcmToken: fcmToken ?? this.fcmToken,
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
