import 'assessment_model.dart';

class Level {
  final String id;
  final String levelName;
  final List<Assessment>? assessments;

  Level({
    required this.id,
    required this.levelName,
    this.assessments,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['level_id']?.toString() ?? json['id']?.toString() ?? '',
      levelName: json['level_name']?.toString() ?? '',
      assessments: json['assessments'] != null
          ? (json['assessments'] as List)
              .map((assessment) => Assessment.fromJson(assessment))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level_id': id,
      'level_name': levelName,
      if (assessments != null)
        'assessments': assessments!.map((a) => a.toJson()).toList(),
    };
  }
}