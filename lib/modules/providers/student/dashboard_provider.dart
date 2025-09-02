

import 'package:flutter/cupertino.dart';

import '../../model/student/dashboard_model.dart';
import '../../services/api/service_locator.dart';
import '../../services/student/student_dasboard_service.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService _dashboardService = locator<DashboardService>();

  DashboardData? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardData? get dashboardData => _dashboardData;
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

  Future<DashboardData?> fetchDashboardData({
    required String class_id,
    required String level_id,
    required String term,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _dashboardService.getDashboardData(class_id, level_id, term);
      _dashboardData = response;
      return response; // Return DashboardData directly
    } catch (e) {
      _setError('Unexpected error: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

}
