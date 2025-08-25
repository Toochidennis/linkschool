import 'package:linkschool/modules/services/admin/e_learning/marking_service.dart';
import 'package:flutter/material.dart';

class MarkAssignmentProvider extends ChangeNotifier {
  final MarkingService _markingService;

  MarkAssignmentProvider(this._markingService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _assignmentData;
  Map<String, dynamic>? get assignmentData => _assignmentData;

  String? _error;
  String? get error => _error;

  Future<void> fetchAssignment(String itemId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _markingService.getAssignment(itemId);
      _assignmentData = data;
    } catch (e) {
      _error = e.toString();
      _assignmentData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _assignmentData = null;
    _error = null;
    notifyListeners();
  }
}