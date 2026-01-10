// lib/modules/services/student/payment_submission_service.dart

import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class PaymentSubmissionService {
  final ApiService _apiService;
  PaymentSubmissionService(this._apiService);
  getuserdata() {
    final userBox = Hive.box('userData');
    final storedUserData =
        userBox.get('userData') ?? userBox.get('loginResponse');
    final processedData =
        storedUserData is String ? json.decode(storedUserData) : storedUserData;
    final response = processedData['response'] ?? processedData;

    return response;
  }

  Future<void> submitPayment({
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
    final token = getuserdata()['token'] as String;
    final dbName = getuserdata()['_db'] ?? 'aalmgzmy_linkskoo_practice';
    print("Set token: $token");
    _apiService.setAuthToken(token);

    final paymentData = {
      'invoice_id': invoiceId,
      'reference': reference,
      'reg_no': regNo,
      'name': name,
      'amount': amount,
      'invoice_details': invoiceDetails,
      'class_id': classId,
      'level_id': levelId,
      'year': year,
      "type": "online",
      'term': term,
      '_db': dbName,
      'email': email,
      'student_id': studentId,
    };

    print("Request Payload: $paymentData");

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/students/277/make-payment',
        body: paymentData,
      );
      print("see me here oo $paymentData");
      print("Response Status Code: ${response.statusCode}");

      if (!response.success) {
        print("Failed to submit payment");
        print("Error: ${response.message ?? 'No error message provided'}");
        throw Exception("Failed to submit payment: ${response.message}");
      } else {
        print('Payment submitted successfully.');
        print('Status Code: ${response.statusCode}');
        print(' ${response.message}');
      }
    } catch (e) {
      print("Error submitting payment: $e");
      throw Exception("Failed to submit payment: $e");
    }
  }
}

// import 'dart:convert';

// import 'package:hive/hive.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';

// class PaymentSubmissionService {
//   final ApiService _apiService;

//   PaymentSubmissionService(this._apiService);

//       getuserdata(){
//     final userBox = Hive.box('userData');
//     final storedUserData =
//         userBox.get('userData') ?? userBox.get('loginResponse');
//     final processedData = storedUserData is String
//         ? json.decode(storedUserData)
//         : storedUserData;
//     final response = processedData['response'] ?? processedData;

//     return response;
//   }

//   Future<ApiResponse<dynamic>> submitPayment({
//     required String studentId,
//     required String invoiceId,
//     required String reference,
//     required String regNo,
//     required String name,
//     required double amount,
//     required List<Map<String, dynamic>> fees,
//     required int classId,
//     required int levelId,
//     required int year,
//     required String email,
//     required int term,
//   }) async {
//     try {
//       final response = await _apiService.post(
//         endpoint: 'https://linkskool.net/api/v3/portal/students/$studentId/make-payment',
//         body: {
//           "invoice_id": invoiceId,
//           "reference": reference,
//           "reg_no": regNo,
//           "name": name,
//           "amount": amount,
//           "fees": fees,
//           "class_id": classId,
//           "level_id": levelId,
//           "year": year,
//           "term": term,
//           "_db":  getuserdata()['_db'],
//         },
//       );

//       print("kkkkkkkkk response ${response.data} ");

//       if (response.success) {
//         return ApiResponse<dynamic>(
//           success: true,
//           message: 'Payment submitted successfully',
//           statusCode: response.statusCode,
//           data: response.rawData,
//           rawData: response.rawData,
//         );
//       } else {
//         return ApiResponse<dynamic>.error(
//           response.message,
//           response.statusCode,
//         );
//       }
//     } catch (e) {
//       return ApiResponse<dynamic>.error(
//         'Failed to submit payment: ${e.toString()}',
//         500,
//       );
//     }
//   }
// }
