import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/admin/view_course_result_service.dart';
// import 'package:linkschool/modules/services/course_result_service.dart';

class CourseResultData {
  final String studentName;
  final String regNo;
  final dynamic totalScore;
  final List<AssessmentData> assessments;
  final String grade;

  CourseResultData({
    required this.studentName,
    required this.regNo,
    required this.totalScore,
    required this.assessments,
    required this.grade,
  });

  factory CourseResultData.fromJson(
      Map<String, dynamic> json, List<GradeData> grades) {
    List<AssessmentData> assessments = [];
    if (json['assessments'] != null) {
      assessments = (json['assessments'] as List)
          .map((a) => AssessmentData.fromJson(a))
          .toList();
    }

    // Calculate grade based on total score and grades array
    String grade = _calculateGrade(json['total_score'], grades);

    return CourseResultData(
      studentName: json['student_name'] ?? '',
      regNo: json['reg_no'] ?? '',
      totalScore: json['total_score'] ?? 0,
      assessments: assessments,
      grade: grade,
    );
  }

  static String _calculateGrade(dynamic totalScore, List<GradeData> grades) {
    if (totalScore == null || totalScore == '' || totalScore == 0) {
      return '';
    }

    double score = totalScore is String
        ? (double.tryParse(totalScore) ?? 0.0)
        : (totalScore as num).toDouble();

    // Sort grades by start value in descending order
    List<GradeData> sortedGrades = List.from(grades);
    sortedGrades.sort((a, b) => b.start.compareTo(a.start));

    for (GradeData grade in sortedGrades) {
      if (score >= grade.start) {
        return grade.gradeSymbol;
      }
    }

    // If no grade matches, return the lowest grade or empty
    return sortedGrades.isNotEmpty ? sortedGrades.last.gradeSymbol : '';
  }
}

class AssessmentData {
  final String assessmentName;
  final dynamic score;
  final int maxScore;

  AssessmentData({
    required this.assessmentName,
    required this.score,
    required this.maxScore,
  });

  factory AssessmentData.fromJson(Map<String, dynamic> json) {
    return AssessmentData(
      assessmentName: json['assessment_name'] ?? '',
      score: json['score'] ?? 0,
      maxScore: json['max_score'] ?? 0,
    );
  }
}

class GradeData {
  final String gradeSymbol;
  final int start;

  GradeData({
    required this.gradeSymbol,
    required this.start,
  });

  factory GradeData.fromJson(Map<String, dynamic> json) {
    return GradeData(
      gradeSymbol: json['grade_symbol'] ?? '',
      start: json['start'] ?? 0,
    );
  }
}

class ViewCourseResultProvider with ChangeNotifier {
  final CourseResultService _courseResultService = CourseResultService();

  bool _isLoading = false;
  String? _error;
  List<CourseResultData> _courseResults = [];
  List<GradeData> _grades = [];
  List<String> _assessmentNames = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CourseResultData> get courseResults => _courseResults;
  List<GradeData> get grades => _grades;
  List<String> get assessmentNames => _assessmentNames;

  Future<void> fetchCourseResults({
    required String classId,
    required String courseId,
    required String term,
    required String year,
    required String levelId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _courseResultService.fetchCourseResults(
        classId: classId,
        courseId: courseId,
        term: term,
        year: year,
        levelId: levelId,
      );

      if (response.success && response.rawData != null) {
        final data = response.rawData!['response'];

        // Parse grades
        _grades = [];
        if (data['grades'] != null) {
          _grades = (data['grades'] as List)
              .map((g) => GradeData.fromJson(g))
              .toList();
        }

        // Parse course results
        _courseResults = [];
        if (data['course_results'] != null) {
          _courseResults = (data['course_results'] as List)
              .map((result) => CourseResultData.fromJson(result, _grades))
              .toList();
        }

        // Extract unique assessment names
        _extractAssessmentNames();

        _isLoading = false;
        _error = null;
      } else {
        _isLoading = false;
        _error = response.message;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to fetch course results: $e';
    }

    notifyListeners();
  }

  void _extractAssessmentNames() {
    Set<String> uniqueNames = {};

    for (CourseResultData result in _courseResults) {
      for (AssessmentData assessment in result.assessments) {
        uniqueNames.add(assessment.assessmentName);
      }
    }

    _assessmentNames = uniqueNames.toList();
  }

  // Helper method to get assessment score for a specific student and assessment
  dynamic getAssessmentScore(CourseResultData student, String assessmentName) {
    try {
      AssessmentData assessment = student.assessments.firstWhere(
        (a) => a.assessmentName == assessmentName,
      );
      return assessment.score;
    } catch (e) {
      return '';
    }
  }

  void clearData() {
    _courseResults = [];
    _grades = [];
    _assessmentNames = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
