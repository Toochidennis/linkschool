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
    required List<Map<String, dynamic>> fees,
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
        fees: fees,
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


// import 'package:flutter/foundation.dart';
// import 'package:linkschool/modules/services/student/payment_submission_services.dart';



// class PaymentProvider with ChangeNotifier {
//   final PaymentSubmissionService _paymentService;

//   PaymentProvider(this._paymentService);

//   Map<String, dynamic>? _paymentData;
//   String? _errorMessage;


//   // Getters
//   Map<String, dynamic>? get paymentData => _paymentData;
//   String? get errorMessage => _errorMessage;



//   // Derived loading state
//   bool get isLoading => _paymentData == null && _errorMessage == null;

//   // Initialize payment
//   Future<void> initializePayment({
//     required String invoiceId,
//     required String reference,
//     required String regNo,
//     required String name,
//     required double amount,
//     required List<Map<String, dynamic>> fees,
//     required int classId,
//     required int levelId,
//     required int year,
//     required int term,

//     required String email,
   
//     required String studentId,
//   }) async {
//     _errorMessage = null;
//     notifyListeners();

//     final response = await _paymentService.submitPayment(
//       invoiceId: invoiceId,
//       reference: reference,
//       regNo: regNo,
//       name: name,
//       amount: amount,
//       fees: fees,
//       classId: classId,
//       levelId: levelId,
//       year: year,
//       term: term,
//       email: email,
     
//       studentId: studentId,
//     );

//     if (response.success) {
//       _paymentData = response.data;
//     } else {
//       _paymentData = null;
//       _errorMessage = response.message;
//     }

//     notifyListeners();
//   }
// }