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

  // Update fee name method
  Future<ApiResponse<void>> updateFeeName(String feeNameId, UpdateFeeNameRequest request) async {
    try {
      // Ensure token is set before making the request
      _ensureTokenIsSet();
      
      final response = await _apiService.put<void>(
        endpoint: 'portal/payments/fee-names/$feeNameId',
        body: request.toJson(),
      );
      return response;
    } catch (e) {
      return ApiResponse<void>.error(
        'Failed to update fee name: $e',
        500,
      );
    }
  }

  // Delete fee name method
  Future<ApiResponse<void>> deleteFeeName(String feeNameId, {required String year, required String term}) async {
    try {
      // Ensure token is set before making the request
      _ensureTokenIsSet();

      final userBox = Hive.box('userData');
      final db = userBox.get('_db');
      
      final response = await _apiService.delete<void>(
        endpoint: 'portal/payments/fee-names/$feeNameId?year=$year&term=$term',
        body: {
          '_db': db ?? '',
        }, 
        fromJson: (json) => json,
        addDatabaseParam: false,
      );
      return response;
    } catch (e) {
      return ApiResponse<void>.error(
        'Failed to delete fee name: $e',
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
