import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/cohorts/upcoming_cohort_model.dart';
import 'package:linkschool/modules/services/explore/courses/upcoming_cohort_service.dart';

class UpcomingCohortProvider extends ChangeNotifier {
  final UpcomingCohortService _service;

  UpcomingCohortDataModel? _data;
  bool _isLoading = false;
  String? _error;

  UpcomingCohortProvider(this._service);

  UpcomingCohortDataModel? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUpcomingCohort({
    required int profileId,
    required String slug,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.fetchUpcomingCohort(
        profileId: profileId,
        slug: slug,
      );

      if (response.success && response.data != null) {
        _data = response.data;
      } else {
        _error = response.message.isNotEmpty
            ? response.message
            : 'Failed to load upcoming cohort';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _data = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
