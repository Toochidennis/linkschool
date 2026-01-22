import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/explore/courses/enrollment_service.dart';

class EnrollmentProvider  extends ChangeNotifier {
    // enrollment service
  final EnrollmentService _enrollmentService =
      EnrollmentService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // enroll user in cohort
  Future<void> enrollUser(Map<String, dynamic> enrollmentData, String cohortId) async {
    try {
      _isLoading = true;
      notifyListeners();

   
      await _enrollmentService.enrollmentService(enrollmentData, cohortId);

    } catch (e) {
      throw Exception("Error in provider while enrolling user: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
