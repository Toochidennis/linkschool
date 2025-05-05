import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/assessment_model.dart';
import 'package:linkschool/modules/services/admin/assessment_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class AssessmentProvider with ChangeNotifier {
  final AssessmentService _assessmentService = locator<AssessmentService>();
  final List<Assessment> _assessments = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters for state variables
  List<Assessment> get assessments => _assessments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Add an assessment to the local collection
  void addAssessment(Assessment assessment) {
    _assessments.add(assessment);
    notifyListeners();
  }

  // Update an existing assessment
  void updateAssessment(int index, Assessment updatedAssessment) {
    if (index >= 0 && index < _assessments.length) {
      _assessments[index] = updatedAssessment;
      notifyListeners();
    }
  }

  // Remove an assessment from the local collection
  void removeAssessment(Assessment assessment) {
    _assessments.remove(assessment);
    notifyListeners();
  }

  // Save assessments to the API - implemented the previously commented method
  Future<bool> saveAssessments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> payload = _assessments.map((assessment) {
        return assessment.toJson();
      }).toList();

      await _assessmentService.addAssessments(payload);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save assessments: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch assessments from the API with improved error handling
  Future<void> fetchAssessments() async {
  _isLoading = true;
  notifyListeners();

  try {
    final response = await _assessmentService.getAssessments();

    if (response.success && response.rawData != null) {
      _assessments.clear();

      final raw = response.rawData!;

      raw.forEach((classKey, classData) {
        if (classData is Map &&
            classData['assessments'] is List &&
            classData['level_id'] != null) {

          int levelId = classData['level_id'];
          String levelName = classData['level_name'] ?? classKey;

          for (var json in classData['assessments']) {
            _assessments.add(
              Assessment.fromJson(
                json, 
                levelId: levelId,
                levelName: levelName,
              ),
            );
          }
        }}
      );
    } else {
      throw Exception(response.message);
    }
  } catch (e) {
    print('Failed to fetch assessments: ${e.toString()}');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
  
  // Get assessments for a specific level
  List<Assessment> getAssessmentsByLevel(String levelId) {
    return _assessments.where((assessment) => 
      assessment.levelId.toString() == levelId).toList();
  }
}