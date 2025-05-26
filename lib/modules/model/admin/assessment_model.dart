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

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id']?.toString(),
      assessmentName: json['assessment_name'] ?? '',
      assessmentScore: json['max_score'] ?? json['assessment_score'] ?? 0,
      assessmentType: json['assessment_type'] ?? json['type'] ?? 0,
      levelId: json['level_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'assessment_name': assessmentName,
      'max_score': assessmentScore,  
      'type': assessmentType,  
      'level_id': levelId,
    };
  }
}