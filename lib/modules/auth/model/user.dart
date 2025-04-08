class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<Class> classes;
  final List<Level> levels;
  final SchoolSettings settings;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.classes,
    required this.levels,
    required this.settings,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['profile']['form_teacher'] ?? '', 
      name: json['profile']['name'] ?? '', 
      email: json['profile']['email'] ?? '', 
      role: json['profile']['role'] ?? '', 
      classes: (json['classes'] as List?)
        ?.map((classData) => Class.fromJson(classData))
        .toList() ?? [],
      levels: (json['levels'] as List?)
        ?.map((levelData) => Level.fromJson(levelData))
        .toList() ?? [],
      settings: SchoolSettings.fromJson(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile': {
        'form_teacher': id,
        'name': name,
        'email': email,
        'role': role,
      },
      'classes': classes.map((c) => c.toJson()).toList(),
      'levels': levels.map((l) => l.toJson()).toList(),
      'settings': settings.toJson(),
    };
  }
}

class Class {
  final int id;
  final String className;
  final int levelId;
  final String? formTeacher;

  Class({
    required this.id,
    required this.className,
    required this.levelId,
    this.formTeacher,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['id'] ?? 0,
      className: json['class_name'] ?? '',
      levelId: json['level_id'] ?? 0,
      formTeacher: json['form_teacher'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_name': className,
      'level_id': levelId,
      'form_teacher': formTeacher,
    };
  }
}

class Level {
  final int id;
  final String levelName;

  Level({
    required this.id,
    required this.levelName,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] ?? 0,
      levelName: json['level_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level_name': levelName,
    };
  }
}

class SchoolSettings {
  final String schoolName;
  final String year;
  final int term;

  SchoolSettings({
    required this.schoolName,
    required this.year,
    required this.term,
  });

  factory SchoolSettings.fromJson(Map<String, dynamic> json) {
    return SchoolSettings(
      schoolName: json['school_name'] ?? '',
      year: json['year'] ?? '',
      term: json['term'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'school_name': schoolName,
      'year': year,
      'term': term,
    };
  }
}



// class User {
//   final String id;
//   final String name;
//   final String accessLevel;

//   User({
//     required this.id,
//     required this.name,
//     required this.accessLevel,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'] ?? '', 
//       name: json['name'] ?? '', 
//       accessLevel: json['access_level'] ?? '', 
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'access_level': accessLevel,
//     };
//   }
// }