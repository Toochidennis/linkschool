import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/e-learning/single_content_model.dart';
import 'package:linkschool/modules/services/admin/e_learning/single-content_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class SingleContentProvider with ChangeNotifier {
  final SingleAssessmentService _assessmentService =
      locator<SingleAssessmentService>();

  AssessmentContentItem? _assessment;
  bool _isLoading = false;
  String? _errorMessage;

  AssessmentContentItem? get assessment => _assessment;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Fetch a single quiz
  Future<AssessmentContentItem?> fetchQuiz(int syllabusId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _assessmentService.fetchQuiz(syllabusId);
      _assessment = response;
      return response;
    } catch (e) {
      _setError('Unexpected error while fetching quiz: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch a single assignment
  Future<AssessmentContentItem?> fetchAssignment(int syllabusId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _assessmentService.fetchAssignment(syllabusId);
      _assessment = response;
      return response;
    } catch (e) {
      _setError('Unexpected error while fetching assignment: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch a single material
  Future<AssessmentContentItem?> fetchMaterial(int syllabusId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _assessmentService.fetchMaterial(syllabusId);
      _assessment = response;
      return response;
    } catch (e) {
      _setError('Unexpected error while fetching material: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
}
