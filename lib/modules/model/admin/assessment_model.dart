class Assessment {
  final String? id;
  final String assessmentName;
  final int assessmentScore;  // This will map to max_score in API
  final int assessmentType;   // This will map to assessment_type in API
  final int levelId;
  final String levelName; // Added to store level name

  Assessment({
    this.id,
    required this.assessmentName,
    required this.assessmentType,
    required this.levelId,
    required this.levelName, 
    required this.assessmentScore,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id']?.toString(),
      assessmentName: json['assessment_name'] ?? '',
      assessmentScore: json['max_score'] ?? json['assessment_score'] ?? 0,
      assessmentType: json['assessment_type'] ?? json['type'] ?? 0,
      levelId: json['level_id'] ?? 0, levelName: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'assessment_name': assessmentName,
      'max_score': assessmentScore,  // Changed to match API
      'assessment_type': assessmentType,  // Changed to match API
      'level_id': levelId,
    };
  }
}


// class Assessment {
//   final String? id;
//   final String assessmentName;
//   final int assessmentScore;
//   final int assessmentType;
//   final int levelId;

//   Assessment({
//     this.id,
//     required this.assessmentName,
//     required this.assessmentScore,
//     required this.assessmentType,
//     required this.levelId,
//   });

//   factory Assessment.fromJson(Map<String, dynamic> json) {
//     return Assessment(
//       id: json['id']?.toString(),
//       assessmentName: json['assessment_name'] ?? json['name'],
//       assessmentScore: json['assessment_score'] ?? json['max_score'] ?? 0,
//       assessmentType: json['assessment_type'] ?? json['type'] ?? 0,
//       levelId: json['level_id'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       if (id != null) 'id': id,
//       'assessment_name': assessmentName,
//       'max_score': assessmentScore,
//       'assessment_type': assessmentType,
//       'level_id': levelId,
//     };
//   }
// }