class Assessment {
  final String? id;
  final String assessmentName;
  final int assessmentType;
  final int levelId;
  final String levelName; // Added to store level name

  Assessment({
    this.id,
    required this.assessmentName,
    required this.assessmentType,
    required this.levelId,
    required this.levelName,
  });

  factory Assessment.fromJson(Map<String, dynamic> json, {required int levelId, required String levelName}) {
    return Assessment(
      id: json['id']?.toString(),
      assessmentName: json['assessment_name'] ?? '',
      assessmentType: json['type'] ?? 0,
      levelId: levelId,
      levelName: levelName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assessment_name': assessmentName,
      'type': assessmentType, // Changed to match API key
      'level_id': levelId,
    };
  }
}