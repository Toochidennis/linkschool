class Assessment {
  final String? id;
  final String assessmentName;
  final int assessmentScore;
  final int assessmentType;
  final int levelId;

  Assessment({
    this.id,
    required this.assessmentName,
    required this.assessmentScore,
    required this.assessmentType,
    required this.levelId,
  });

  // Convert a JSON object to an Assessment instance
  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id']?.toString(),
      assessmentName: json['assessment_name'],
      assessmentScore: json['assessment_score'],
      assessmentType: json['assessment_type'],
      levelId: json['level_id'],
    );
  }

  // Convert an Assessment instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'assessment_name': assessmentName,
      'assessment_score': assessmentScore,
      'assessment_type': assessmentType,
      'level_id': levelId,
    };
  }
}