import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/explore/courses/cohort_service.dart';
import 'package:linkschool/modules/model/explore/cohorts/cohort_model.dart';

class CohortProvider extends ChangeNotifier {
  final CohortService _cohortService;

  CohortModel? _cohort;
  bool _isLoading = false;
  String? _error;

  CohortProvider(this._cohortService);

  CohortModel? get cohort => _cohort;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCohort(String cohortId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _cohortService.fetchCohort(cohortId);
      if (response.success && response.data != null) {
        _cohort = response.data;
      } else {
        _error = response.message.isNotEmpty ? response.message : 'Failed to load cohort';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _cohort = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
