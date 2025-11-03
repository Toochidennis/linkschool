import 'package:flutter/material.dart';
 import 'package:linkschool/modules/services/student/payment_submission_services.dart';



class PaymentProvider with ChangeNotifier {
 final PaymentSubmissionService _paymentService;
  PaymentProvider(this._paymentService);
 
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

 

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  Future<void> initializePayment({
    required String studentId,
    required String invoiceId,
    required String reference,
    required String regNo,
    required String name,
    required double amount,
    required List<Map<String, dynamic>> invoiceDetails,
    required int classId,
    required int levelId,
    required int year,
    required int term,
    required String email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      await _paymentService.submitPayment(
        studentId: studentId,
        invoiceId: invoiceId,
        reference: reference,
        regNo: regNo,
        name: name,
        amount: amount,
        invoiceDetails: invoiceDetails,
        classId: classId,
        levelId: levelId,
        year: year,
        term: term,
        email: email,
      );
      _isSuccess = true;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();
  }
}

