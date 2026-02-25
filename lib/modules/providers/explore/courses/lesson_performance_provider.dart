import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/courses/lesson_performance_model.dart';
import 'package:linkschool/modules/services/explore/courses/lesson_performance_service.dart';

class LessonPerformanceProvider extends ChangeNotifier {
  final LessonPerformanceService _service;

  LessonPerformanceData? _performance;
  bool _isLoading = false;
  String? _error;
  String? _currentCohortId;
  int? _currentProfileId;

  LessonPerformanceProvider(this._service);

  LessonPerformanceData? get performance => _performance;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLessonPerformance({
    required String cohortId,
    required int profileId,
    bool silent = true,
  }) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    _currentCohortId = cohortId;
    _currentProfileId = profileId;

    try {
      final response = await _service.fetchLessonPerformance(
        cohortId: cohortId,
        profileId: profileId,
      );

      if (response.success) {
        _performance = response.data;
        _error = null;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_currentCohortId != null && _currentProfileId != null) {
      await loadLessonPerformance(
        cohortId: _currentCohortId!,
        profileId: _currentProfileId!,
        silent: false,
      );
    }
  }

  void clear() {
    _performance = null;
    _error = null;
    _currentCohortId = null;
    _currentProfileId = null;
    notifyListeners();
  }
}
