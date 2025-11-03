import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

// import 'package:linkschool/modules/services/api_service.dart';

class RegisteredTermsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Map<String, dynamic>>? _sessions;
  bool _isLoading = false;
  String _error = '';
  
  List<Map<String, dynamic>>? get sessions => _sessions;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Fetch terms for a specific class
  Future<void> fetchTerms(String classId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      final response = await _apiService.get(
        endpoint: 'portal/course-registrations/terms',
        queryParams: {
          'class_id': classId,
          '_db': 'aalmgzmy_linkskoo_practice',
          'year': '2025', // This can be dynamic if needed
        },
      );
      
      if (response.success && response.rawData != null && response.rawData!['success'] == true) {
        final List<dynamic> sessionsList = response.rawData!['sessions'] ?? [];
        _sessions = List<Map<String, dynamic>>.from(sessionsList);
        _isLoading = false;
        notifyListeners();
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to load terms: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Reset provider state
  void reset() {
    _sessions = null;
    _isLoading = false;
    _error = '';
    notifyListeners();
  }
}