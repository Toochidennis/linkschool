class StudentResultModel {
  final int position;
  final int average;
  final int totalStudents;
  final List<SubjectResult> subjects;

  StudentResultModel({
    required this.position,
    required this.average,
    required this.totalStudents,
    required this.subjects,
  });

  factory StudentResultModel.fromJson(Map<String, dynamic> json) {
    return StudentResultModel(
      position: json['position'],
      average: json['average'],
      totalStudents: json['total_students'],
      subjects: (json['subjects'] as List<dynamic>)
          .map((e) => SubjectResult.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'average': average,
      'total_students': totalStudents,
      'subjects': subjects.map((e) => e.toJson()).toList(),
    };
  }
}

class SubjectResult {
  final String courseName;
  final List<Assessment> assessments;
  final String total;
  final String grade;
  final String remark;

  SubjectResult({
    required this.courseName,
    required this.assessments,
    required this.total,
    required this.grade,
    required this.remark,
  });

  factory SubjectResult.fromJson(Map<String, dynamic> json) {
    return SubjectResult(
      courseName: json['course_name'],
      assessments: (json['assessments'] as List<dynamic>)
          .map((e) => Assessment.fromJson(e))
          .toList(),
      total: json['total'],
      grade: json['grade'],
      remark: json['remark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_name': courseName,
      'assessments': assessments.map((e) => e.toJson()).toList(),
      'total': total,
      'grade': grade,
      'remark': remark,
    };
  }
}

class Assessment {
  final String assessmentName;
  final int score;

  Assessment({
    required this.assessmentName,
    required this.score,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      assessmentName: json['assessment_name'],
      score: json['score'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assessment_name': assessmentName,
      'score': score,
    };
  }
}
