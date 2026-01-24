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


  // payment service
  Future<bool> checkPaymentStatus({
    required String cohortId,
    required int profileId,
  }) async {
    try {
      return await _enrollmentService.fetchPaymentStatus(
        cohortId: cohortId,
        profileId: profileId,
      );
    } catch (e) {
      throw Exception("Error in provider while checking payment status: $e");
    }
  }
  Future<void> processEnrollmentPayment(Map<String, dynamic> paymentData, String cohortId) async {
    try {
      _isLoading = true;
      notifyListeners();

   
      await _enrollmentService.enrollmentPayment(paymentData, cohortId);

    } catch (e) {
      throw Exception("Error in provider while processing enrollment payment: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
void updateTrialViewsSilently(Map<String, dynamic> trialData, int courseId) {
    _enrollmentService.updateTrialView(trialData, courseId).catchError((e) {
      debugPrint("Silent trial update failed: $e");
    });
  }
  //  update trial views
  Future<bool> updateTrialViews(Map<String, dynamic> trialData, int courseId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _enrollmentService.updateTrialView(trialData, courseId);
      // Optionally inspect `response` for success details
      return true;
    } catch (e) {
      // Don't throw to keep caller in control; log and return false
      print("Error in provider while updating trial views: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}




