import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/student/payment_model.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/services/api/api_service.dart';

class InvoiceService {
  final ApiService _apiService;
  
  InvoiceService(this._apiService);

  Future<InvoiceResponse> fetchInvoices(String studentId) async {
    try {
      final userBox = Hive.box('userData');
      final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
      final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

      if (loginData == null || loginData['token'] == null) {
        throw Exception("No valid login data or token found");
      }

      final token = loginData['token'] as String;
      _apiService.setAuthToken(token);

      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: 'portal/students/$studentId/financial-records',
        queryParams: {'_db': dbName},
      );

      if (response.statusCode != 200) {
        throw Exception('API request failed with status ${response.statusCode}');
      }

     final raw = response.rawData;

if (raw == null || raw['response'] == null) {
  throw Exception("Invalid response format: Missing 'response' key.");
}

final responseBody = raw['response'];

// ✅ Handle when the API returns an empty array instead of a map
Map<String, dynamic> transformedResponse;
if (responseBody is List && responseBody.isEmpty) {
  transformedResponse = {
    'invoices': [],
    'payments': [],
  };
} else if (responseBody is Map<String, dynamic>) {
  transformedResponse = Map<String, dynamic>.from(responseBody);
  if (transformedResponse.containsKey('invoice')) {
    transformedResponse['invoices'] = transformedResponse.remove('invoice');
  }
} else {
  throw Exception("Invalid response type for 'response': ${responseBody.runtimeType}");
}

return InvoiceResponse.fromJson({
  'success': raw['success'] ?? true,
  'statusCode': raw['statusCode'] ?? response.statusCode,
  'response': transformedResponse,
});


    } catch (e) {
      print("Error fetching invoices: $e");
      rethrow;
    }
  }
}

// class InvoiceService {
//   Future<InvoiceResponse> getInvoiceData() async {
//     final baseUrl = 'https://linkskool.net/api/v3/portal/students/277/financial-records?_db=aalmgzmy_linkskoo_practice'; // Replace with actual API endpoint
    
//     final mockJson = '''
//     {
//       "statusCode": 200,
//       "success": true,
//       "response": {
//         "invoice": [
//           {
//             "id": 20241277,
//             "invoice_details": [
//               {
//                 "fee_id": 26,
//                 "fee_name": "Bus Fee",
//                 "fee_amount": "1000"
//               },
//               {
//                 "fee_id": 17,
//                 "fee_name": "Ftee",
//                 "fee_amount": "5000"
//               },
//               {
//                 "fee_id": 14,
//                 "fee_name": "Hostel Fee",
//                 "fee_amount": "2500"
//               },
//               {
//                 "fee_id": 18,
//                 "fee_name": "Labour Fee",
//                 "fee_amount": "3200"
//               }
//             ],
//             "amount": 11700,
//             "year": "2024",
//             "term": 1
//           }
//         ],
//         "payments": [
//           {
//             "id": 20232287,
//             "reference": "hdkjj799",
//             "reg_no": "240277",
//             "description": "School Fees Receipt for 2023 2 term",
//             "name": "Toochi   Bill",
//             "amount": 23180,
//             "date": "2023-03-13",
//             "year": "2023",
//             "term": 2,
//             "level_id": 67,
//             "class_id": 71,
//             "level_name": "JSS2"
//           },
//           {
//             "id": 20232286,
//             "reference": "htvghg",
//             "reg_no": "240277",
//             "description": "School Fees Receipt for 2023 1 term",
//             "name": "Toochi   Bill",
//             "amount": 15680,
//             "date": "2023-03-13",
//             "year": "2023",
//             "term": 1,
//             "level_id": 67,
//             "class_id": 71,
//             "level_name": "JSS2"
//           }
//         ]
//       }
//     }
//     ''';

//     await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
//     final jsonMap = json.decode(mockJson);
//     return InvoiceResponse.fromJson(jsonMap);
//   }
// }