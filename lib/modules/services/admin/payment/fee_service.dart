import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/fee_name.dart';
// import 'package:linkschool/modules/admin/payment/models/fee_name.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class FeeService {
  final ApiService _apiService;

  FeeService(this._apiService);

  // Helper method to ensure token is set before making requests
  void _ensureTokenIsSet() {
    try {
      final userBox = Hive.box('userData');
      final token = userBox.get('token');
      if (token != null && token.toString().isNotEmpty) {
        _apiService.setAuthToken(token.toString());
      } else {
        throw Exception('No authentication token found. Please login again.');
      }
    } catch (e) {
      throw Exception('Failed to get authentication token: $e');
    }
  }

  Future<ApiResponse<List<FeeName>>> getFeeNames() async {
    try {
      // Ensure token is set before making the request
      _ensureTokenIsSet();
      
      final response = await _apiService.get<List<FeeName>>(
        endpoint: 'portal/payments/fee-names',
        fromJson: (json) {
          if (json['response'] != null && json['response'] is List) {
            return (json['response'] as List)
                .map((item) => FeeName.fromJson(item))
                .toList();
          }
          return <FeeName>[];
        },
      );
      return response;
    } catch (e) {
      return ApiResponse<List<FeeName>>.error(
        'Failed to fetch fee names: $e',
        500,
      );
    }
  }

  Future<ApiResponse<void>> addFeeName(AddFeeNameRequest request) async {
    try {
      // Ensure token is set before making the request
      _ensureTokenIsSet();
      
      final response = await _apiService.post<void>(
        endpoint: 'portal/payments/fee-names',
        body: request.toJson(),
      );
      return response;
    } catch (e) {
      return ApiResponse<void>.error(
        'Failed to add fee name: $e',
        500,
      );
    }
  }
}





// // import 'package:linkschool/modules/admin/payment/models/fee_name.dart';
// import 'package:linkschool/modules/model/admin/fee_name.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';

// class FeeService {
//   final ApiService _apiService;

//   FeeService(this._apiService);

//   Future<ApiResponse<List<FeeName>>> getFeeNames() async {
//     try {
//       final response = await _apiService.get<List<FeeName>>(
//         endpoint: 'portal/payments/fee-names',
//         fromJson: (json) {
//           if (json['response'] != null && json['response'] is List) {
//             return (json['response'] as List)
//                 .map((item) => FeeName.fromJson(item))
//                 .toList();
//           }
//           return <FeeName>[];
//         },
//       );
//       return response;
//     } catch (e) {
//       return ApiResponse<List<FeeName>>.error(
//         'Failed to fetch fee names: $e',
//         500,
//       );
//     }
//   }

//   Future<ApiResponse<void>> addFeeName(AddFeeNameRequest request) async {
//     try {
//       final response = await _apiService.post<void>(
//         endpoint: 'portal/payments/fee-names',
//         body: request.toJson(),
//       );
//       return response;
//     } catch (e) {
//       return ApiResponse<void>.error(
//         'Failed to add fee name: $e',
//         500,
//       );
//     }
//   }
// }
