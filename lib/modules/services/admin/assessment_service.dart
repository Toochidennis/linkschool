import 'package:hive/hive.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class AssessmentService {
  final ApiService _apiService = locator<ApiService>();

  Future<ApiResponse<Map<String, dynamic>>> createAssessment(
      Map<String, dynamic> payload) async {
    try {
      // Get token from local storage
      final userBox = Hive.box('userData');
      final token = userBox.get('token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Set the auth token before making the request
      _apiService.setAuthToken(token);

      // Database parameter will be automatically added by ApiService
      return await _apiService.post(
        endpoint: 'portal/assessments',
        body: payload,
      );
    } catch (e) {
      rethrow;
    }
  }

  // method for editing assessment
  Future<ApiResponse<Map<String, dynamic>>> editAssessment(
      String assessmentId, Map<String, dynamic> payload) async {
    print("Payload in service: $payload");
    try {
      // Get token from local storage
      final userBox = Hive.box('userData');
      final token = userBox.get('token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Set the auth token before making the request
      _apiService.setAuthToken(token);

      // Database parameter will be automatically added by ApiService
      return await _apiService.put(
        endpoint: 'portal/assessments/$assessmentId',
        body: payload,
      );
    } catch (e) {
      rethrow;
    }
  }

  // method for deleting assessment
  Future<ApiResponse<Map<String, dynamic>>> deleteAssessment(
      String assessmentId) async {
    try {
      // Get token from local storage
      final userBox = Hive.box('userData');
      final token = userBox.get('token');

      final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Set the auth token before making the request
      _apiService.setAuthToken(token);

      // Database parameter will be automatically added by ApiService
      return await _apiService.delete(
        endpoint: 'portal/assessments/$assessmentId',
        body: {
          "_db": dbName
        }, // Empty body, database will be added automatically
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getAssessments() async {
    try {
      // Get token from local storage
      final userBox = Hive.box('userData');
      final token = userBox.get('token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Set the auth token before making the request
      _apiService.setAuthToken(token);

      // Database parameter will be automatically added by ApiService
      return await _apiService.get(
        endpoint: 'portal/assessments',
      );
    } catch (e) {
      rethrow;
    }
  }
}

// import 'package:hive/hive.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';
// import 'package:linkschool/modules/services/api/service_locator.dart';

// class AssessmentService {
//   final ApiService _apiService = locator<ApiService>();

//   Future<ApiResponse<Map<String, dynamic>>> createAssessment(Map<String, dynamic> payload) async {
//     try {
//       // Get token from local storage
//       final userBox = Hive.box('userData');
//       final token = userBox.get('token');

//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       // Set the auth token before making the request
//       _apiService.setAuthToken(token);

//       return await _apiService.post(
//         endpoint: 'portal/assessments',
//         body: payload,
//       );
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // method for editing assessment
//   Future<ApiResponse<Map<String, dynamic>>> editAssessment(String assessmentId, Map<String, dynamic> payload) async {
//     try {
//       // Get token from local storage
//       final userBox = Hive.box('userData');
//       final token = userBox.get('token');

//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       // Set the auth token before making the request
//       _apiService.setAuthToken(token);

//       // Get database name from payload or use default
//       final dbName = payload['_db'] ?? 'aalmgzmy_linkskoo_practice';

//       return await _apiService.put(
//         endpoint: 'portal/assessments/$assessmentId',
//         body: payload,
//         queryParams: {'_db': dbName},
//       );
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // method for deleting assessment
//   Future<ApiResponse<Map<String, dynamic>>> deleteAssessment(String assessmentId) async {
//     try {
//       // Get token from local storage
//       final userBox = Hive.box('userData');
//       final token = userBox.get('token');
//       final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       // Set the auth token before making the request
//       _apiService.setAuthToken(token);

//       final payload = {
//       '_db': dbName,
//     };

//       return await _apiService.request(
//         endpoint: 'portal/assessments/$assessmentId',
//         method: HttpMethod.DELETE,
//         queryParams: {'_db': dbName},
//         body: payload,
//       );
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<ApiResponse<Map<String, dynamic>>> getAssessments(String dbName) async {
//     try {
//       // Get token from local storage
//       final userBox = Hive.box('userData');
//       final token = userBox.get('token');

//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       // Set the auth token before making the request
//       _apiService.setAuthToken(token);

//       return await _apiService.get(
//         endpoint: 'portal/assessments',
//         queryParams: {'_db': dbName},
//       );
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
