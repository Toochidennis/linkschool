class Levels {
  final int id;
  final String levelName;
  final String schoolType; // Changed to String
  final int rank;
  final String? resultTemplate;
  final int admit;

  Levels({
    required this.id,
    required this.levelName,
    required this.schoolType,
    required this.rank,
    this.resultTemplate,
    required this.admit,
  });

  factory Levels.fromJson(Map<String, dynamic> json) {
    final levelName = json['level_name'] as String;
    if (levelName.isEmpty) {
      throw FormatException('level_name cannot be empty');
    }
    return Levels(
      id: json['id'] as int,
      levelName: levelName,
      schoolType: json['school_type'] as String,
      rank: json['rank'] as int,
      resultTemplate: (json['result_template'] as String?)?.isEmpty ?? true ? null : json['result_template'] as String?,
      admit: json['admit'] as int,
    );
  }
}

class Class {
  final int id;
  final String className;
  final int levelId;
  final String? resultTemplate;
  final List<String> formTeacherIds;

  Class({
    required this.id,
    required this.className,
    required this.levelId,
    this.resultTemplate,
    required this.formTeacherIds,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    // final className = json['class_name'] as String;
    // if (className.isEmpty) {
    //   throw FormatException('class_name cannot be empty');
    // }
    return Class(
      id: json['id'] as int,
       className: json['class_name'] as String,
      levelId: json['level_id'] as int,
      resultTemplate: (json['result_template'] as String?)?.isEmpty ?? true ? null : json['result_template'] as String?,
      formTeacherIds: (json['form_teacher_ids'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}