import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/cohorts/program_cohort_model.dart';
import 'package:linkschool/modules/services/explore/courses/program_cohort_service.dart';

class ProgramCohortProvider extends ChangeNotifier {
  final ProgramCohortService _service;

  ProgramCohortDataModel? _data;
  bool _isLoading = false;
  String? _error;

  ProgramCohortProvider(this._service);

  ProgramCohortDataModel? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadByRef(String ref) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.fetchProgramCohortByRef(ref);
      if (response.success && response.data != null) {
        _data = response.data;
      } else {
        _error = response.message.isNotEmpty
            ? response.message
            : 'Failed to load program cohort';
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
