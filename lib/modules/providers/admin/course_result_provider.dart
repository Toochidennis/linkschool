import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/admin/term_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class CourseResultProvider with ChangeNotifier {
  final TermService _termService = locator<TermService>();
  List<Map<String, dynamic>> _averageScores = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get averageScores => _averageScores;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAverageScores(String classId, String year, int term) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Fetching average scores for classId: $classId, year: $year, term: $term');
      final response = await _termService.fetchAverageScores(classId, year, term);
      print('Fetched Average Scores: $response');

      _averageScores = response;
      _error = null;
    } catch (e) {
      print('Error fetching average scores: $e');
      _error = 'Failed to load average scores. Please try again.';
      _averageScores = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}