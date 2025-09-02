import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/staff/assignment_service.dart';

class StaffAssignmentProvider extends ChangeNotifier {
  final StaffAssignmentService _staffAssignmentService;
  bool isLoading = false;
  String? error;
  StaffAssignmentProvider(this._staffAssignmentService);

  Future<void> addAssignment(Map<String, dynamic> assignment) async {
    isLoading = true;
    error = null; 
    notifyListeners();
    try {
      await _staffAssignmentService.AddAssignment(assignment);
    } catch (e) {
      print('Error adding assignment: $e');
      rethrow;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> UpDateAssignment(Map<String, dynamic> assignment,int id) async {
    isLoading = true;
    error = null; 
    notifyListeners();
    try {
      await _staffAssignmentService.UpDateAssignment(assignment, id);
    } catch (e) {
      print('Error adding assignment: $e');
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
      await _staffAssignmentService.DeleteAssignment(id);
    } catch (e) {
      print('Error adding assignment: $e');
      rethrow;
    }
    isLoading = false;
    notifyListeners();
  }
}
