import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/admin/e_learning/assignment_service.dart';

class AssignmentProvider extends ChangeNotifier {
  final AssignmentService _assignmentService;
  bool isLoading = false;
  String? error;
  AssignmentProvider(this._assignmentService);

  Future<void> addAssignment(Map<String, dynamic> assignment) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _assignmentService.AddAssignment(assignment);
    } catch (e) {
      rethrow;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> UpDateAssignment(Map<String, dynamic> assignment, int id) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _assignmentService.UpDateAssignment(assignment, id);
    } catch (e) {
      rethrow;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> DeleteAssignment(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _assignmentService.DeleteAssignment(id);
    } catch (e) {
      rethrow;
    }
    isLoading = false;
    notifyListeners();
  }
}
