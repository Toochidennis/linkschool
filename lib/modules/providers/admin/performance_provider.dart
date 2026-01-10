// lib/modules/providers/admin/performance_provider.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/services/admin/performance_service.dart';

class PerformanceProvider with ChangeNotifier {
  final PerformanceService _performanceService;

  List<PerformanceData> _performanceData = [];
  bool _isLoading = false;
  String? _error;

  PerformanceProvider(this._performanceService);

  List<PerformanceData> get performanceData => _performanceData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPerformanceData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get year and term from Hive storage
      final userBox = Hive.box('userData');
      final settings = userBox.get('settings');

      if (settings == null) {
        throw Exception('No settings found. Please login again.');
      }

      final year = settings['year']?.toString();
      final term = settings['term']?.toString();

      if (year == null || term == null) {
        throw Exception('Year or term not found in settings');
      }

      final response = await _performanceService.getClassPerformance(
        year: year,
        term: term,
      );

      if (response.success && response.data != null) {
        _performanceData = response.data!;
        _error = null;
      } else {
        _error = response.message;
        _performanceData = [];
      }
    } catch (e) {
      _error = 'Failed to load performance data: $e';
      _performanceData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
