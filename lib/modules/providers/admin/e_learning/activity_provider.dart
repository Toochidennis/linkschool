

import 'package:flutter/cupertino.dart';
import 'package:linkschool/modules/model/e-learning/activity_model.dart';
import 'package:linkschool/modules/services/admin/e_learning/activity_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';



class RecentProvider with ChangeNotifier {
  final  _RecentService = locator<RecentService>();

RecentData? _recentData;
  bool _isLoading = false;
  String? _errorMessage;

  RecentData? get recentData => _recentData;
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

  Future<RecentData?> fetchDashboardData({
    required String class_id,
    required String level_id,
    required String term,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _RecentService.getDashboardData(class_id, level_id, term);
      _recentData = response;
      return response; // Return DashboardData directly
    } catch (e) {
      _setError('Unexpected error: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

}