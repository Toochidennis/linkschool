// import 'package:linkschool/modules/models/account_model.dart';
import 'package:linkschool/modules/model/admin/account_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:hive/hive.dart';

class AccountService {
  final ApiService _apiService;

  AccountService(this._apiService) {
    _setAuthToken();
  }

  // Set authentication token from Hive storage using existing auth system
  void _setAuthToken() {
    try {
      final userBox = Hive.box('userData');
      final token = userBox.get('token');
      
      if (token != null && token.isNotEmpty) {
        _apiService.setAuthToken(token);
        print('Auth token set for AccountService');
      } else {
        print('Warning: No auth token found in userData box');
      }
    } catch (e) {
      print('Error setting auth token: $e');
    }
  }

  // Add a method to refresh auth token
  void refreshAuthToken() {
    _setAuthToken();
  }

  // Fetch all accounts
  Future<ApiResponse<AccountResponse>> fetchAccounts({
    int page = 1,
    int limit = 140,
  }) async {
    try {
      final response = await _apiService.get<AccountResponse>(
        endpoint: 'portal/payments/accounts',
        queryParams: {
          'page': page,
          'limit': limit,
        },
        fromJson: (json) => AccountResponse.fromJson(json),
      );

      return response;
    } catch (e) {
      print('Error fetching accounts: $e');
      return ApiResponse<AccountResponse>.error(
        'Failed to fetch accounts: ${e.toString()}',
        500,
      );
    }
  }

  // Add new account
  Future<ApiResponse<Map<String, dynamic>>> addAccount({
    required String accountName,
    required String accountNumber,
    required int accountType,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/payments/accounts',
        body: {
          'account_name': accountName,
          'account_number': int.parse(accountNumber),
          'account_type': accountType,
        },
        fromJson: (json) => json,
      );

      return response;
    } catch (e) {
      print('Error adding account: $e');
      return ApiResponse<Map<String, dynamic>>.error(
        'Failed to add account: ${e.toString()}',
        500,
      );
    }
  }

  // Update existing account
  Future<ApiResponse<Map<String, dynamic>>> updateAccount({
    required int accountId,
    required String accountName,
    required String accountNumber,
    required int accountType,
  }) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        endpoint: 'portal/payments/accounts/$accountId',
        body: {
          'account_name': accountName,
          'account_number': int.parse(accountNumber),
          'account_type': accountType,
        },
        fromJson: (json) => json,
      );

      return response;
    } catch (e) {
      print('Error updating account: $e');
      return ApiResponse<Map<String, dynamic>>.error(
        'Failed to update account: ${e.toString()}',
        500,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteAccount({
    required int accountId,
  }) async {
    try {
      final userBox = Hive.box('userData');
      final db = userBox.get('_db');
      
      final response = await _apiService.delete<Map<String, dynamic>>(
        endpoint: 'portal/payments/accounts/$accountId',
        body: {
          '_db': db,
        },
        fromJson: (json) => json,
        addDatabaseParam: false,
      );

      return response;
    } catch (e) {
      print('Error deleting account: $e');
      return ApiResponse<Map<String, dynamic>>.error(
        'Failed to delete account: ${e.toString()}',
        500,
      );
    }
  }
}





// // import 'package:linkschool/modules/models/account_model.dart';
// import 'package:linkschool/modules/model/admin/account_model.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';
// import 'package:hive/hive.dart';

// class AccountService {
//   final ApiService _apiService;

//   AccountService(this._apiService) {
//     _setAuthToken();
//   }

//   // Set authentication token from Hive storage using existing auth system
//   void _setAuthToken() {
//     try {
//       final userBox = Hive.box('userData');
//       final token = userBox.get('token');
      
//       if (token != null && token.isNotEmpty) {
//         _apiService.setAuthToken(token);
//         print('Auth token set for AccountService');
//       } else {
//         print('Warning: No auth token found in userData box');
//       }
//     } catch (e) {
//       print('Error setting auth token: $e');
//     }
//   }

//   // Add a method to refresh auth token
//   void refreshAuthToken() {
//     _setAuthToken();
//   }

//   // Fetch all accounts
//   Future<ApiResponse<AccountResponse>> fetchAccounts({
//     int page = 1,
//     int limit = 140,
//   }) async {
//     try {
//       final response = await _apiService.get<AccountResponse>(
//         endpoint: 'portal/payments/accounts',
//         queryParams: {
//           'page': page,
//           'limit': limit,
//         },
//         fromJson: (json) => AccountResponse.fromJson(json),
//       );

//       return response;
//     } catch (e) {
//       print('Error fetching accounts: $e');
//       return ApiResponse<AccountResponse>.error(
//         'Failed to fetch accounts: ${e.toString()}',
//         500,
//       );
//     }
//   }

//   // Add new account
//   Future<ApiResponse<Map<String, dynamic>>> addAccount({
//     required String accountName,
//     required String accountNumber,
//     required int accountType,
//   }) async {
//     try {
//       final response = await _apiService.post<Map<String, dynamic>>(
//         endpoint: 'portal/payments/accounts',
//         body: {
//           'account_name': accountName,
//           'account_number': int.parse(accountNumber),
//           'account_type': accountType,
//         },
//         fromJson: (json) => json,
//       );

//       return response;
//     } catch (e) {
//       print('Error adding account: $e');
//       return ApiResponse<Map<String, dynamic>>.error(
//         'Failed to add account: ${e.toString()}',
//         500,
//       );
//     }
//   }

//   // Update existing account
//   Future<ApiResponse<Map<String, dynamic>>> updateAccount({
//     required int accountId,
//     required String accountName,
//     required String accountNumber,
//     required int accountType,
//   }) async {
//     try {
//       final response = await _apiService.put<Map<String, dynamic>>(
//         endpoint: 'portal/payments/accounts/$accountId',
//         body: {
//           'account_name': accountName,
//           'account_number': int.parse(accountNumber),
//           'account_type': accountType,
//         },
//         fromJson: (json) => json,
//       );

//       return response;
//     } catch (e) {
//       print('Error updating account: $e');
//       return ApiResponse<Map<String, dynamic>>.error(
//         'Failed to update account: ${e.toString()}',
//         500,
//       );
//     }
//   }
// }