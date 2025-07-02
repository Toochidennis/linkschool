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
      print('Error adding assignment: $e');
      rethrow;
    }
    isLoading = false;
    notifyListeners();
  }
}
