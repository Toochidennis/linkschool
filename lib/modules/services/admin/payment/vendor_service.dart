// Updated vendor_service.dart
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/vendor/vendor_model.dart';
import 'package:linkschool/modules/model/admin/vendor/vendor_transaction_year.dart';
// import 'package:linkschool/modules/model/admin/vendor/vendor_transaction_model.dart'; // New import for transaction models
import 'package:linkschool/modules/services/api/api_service.dart';

class VendorService {
  final ApiService _apiService;

  VendorService(this._apiService);

  Future<ApiResponse<List<Vendor>>> fetchVendors() async {
    return await _apiService.get<List<Vendor>>(
      endpoint: 'portal/payments/vendors',
      fromJson: (json) {
        final List<dynamic> vendorList = json['response'] as List<dynamic>;
        return vendorList.map((vendor) => Vendor.fromJson(vendor)).toList();
      },
    );
  }

  Future<ApiResponse<void>> addVendor({
    required String vendorName,
    required String phoneNumber,
    String? email,
    String? address,
    required String reference,
  }) async {
    final payload = {
      'vendor_name': vendorName,
      'phone_number': phoneNumber,
      'email': email ?? '',
      'address': address ?? '',
      'reference': reference,
    };

    return await _apiService.post<void>(
      endpoint: 'portal/payments/vendors',
      body: payload,
    );
  }

  Future<ApiResponse<void>> updateVendor({
    required int vendorId,
    required String vendorName,
    required String phoneNumber,
    String? email,
    String? address,
    required String reference,
  }) async {
    final payload = {
      'vendor_name': vendorName,
      'phone_number': phoneNumber,
      'email': email ?? '',
      'address': address ?? '',
      'reference': reference,
    };

    return await _apiService.put<void>(
      endpoint: 'portal/payments/vendors/$vendorId',
      body: payload,
    );
  }

  Future<ApiResponse<void>> deleteVendor(int vendorId) async {
    try {
      final userBox = Hive.box('userData');
      final db = userBox.get('_db');

      final response = await _apiService.delete<Map<String, dynamic>>(
        endpoint: 'portal/payments/vendors/$vendorId',
        body: {
          '_db': db,
        },
        fromJson: (json) => json,
        addDatabaseParam: false,
      );

      return response;
    } catch (e) {
      print('Error deleting vendor: $e');
      return ApiResponse<Map<String, dynamic>>.error(
        'Failed to delete vendor: ${e.toString()}',
        500,
      );
    }
  }

  // return await _apiService.delete<void>(
  //   endpoint: 'portal/payments/vendors/$vendorId',
  //   body: {},
  // );
  Future<ApiResponse<List<VendorTransactionYear>>>
      fetchVendorTransactionHistory(int vendorId) async {
    return await _apiService.get<List<VendorTransactionYear>>(
      endpoint: 'portal/payments/vendors/$vendorId/transactions/annual',
      fromJson: (json) => (json['data'] as List)
          .map((e) => VendorTransactionYear.fromJson(e))
          .toList(),
    );
  }

  Future<ApiResponse<List<VendorTransactionDetail>>>
      fetchVendorTransactionDetails(int vendorId, int year) async {
    return await _apiService.get<List<VendorTransactionDetail>>(
      endpoint: 'portal/payments/vendors/$vendorId/transactions/$year',
      fromJson: (json) => (json['data'] as List)
          .map((e) => VendorTransactionDetail.fromJson(e))
          .toList(),
    );
  }
}

// import 'package:linkschool/modules/model/admin/vendor/vendor_model.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';
// // import 'package:linkschool/modules/model/vendor.dart';

// class VendorService {
//   final ApiService _apiService;

//   VendorService(this._apiService);

//   Future<ApiResponse<List<Vendor>>> fetchVendors() async {
//     return await _apiService.get<List<Vendor>>(
//       endpoint: 'portal/payments/vendors',
//       fromJson: (json) {
//         final List<dynamic> vendorList = json['response'] as List<dynamic>;
//         return vendorList.map((vendor) => Vendor.fromJson(vendor)).toList();
//       },
//     );
//   }

//   Future<ApiResponse<void>> addVendor({
//     required String vendorName,
//     required String phoneNumber,
//     String? email,
//     String? address,
//     required String reference,
//   }) async {
//     final payload = {
//       'vendor_name': vendorName,
//       'phone_number': phoneNumber,
//       'email': email ?? '',
//       'address': address ?? '',
//       'reference': reference,
//     };

//     return await _apiService.post<void>(
//       endpoint: 'portal/payments/vendors',
//       body: payload,
//     );
//   }

//   Future<ApiResponse<void>> updateVendor({
//     required int vendorId,
//     required String vendorName,
//     required String phoneNumber,
//     String? email,
//     String? address,
//     required String reference,
//   }) async {
//     final payload = {
//       'vendor_name': vendorName,
//       'phone_number': phoneNumber,
//       'email': email ?? '',
//       'address': address ?? '',
//       'reference': reference,
//     };

//     return await _apiService.put<void>(
//       endpoint: 'portal/payments/vendors/$vendorId',
//       body: payload,
//     );
//   }

//   Future<ApiResponse<void>> deleteVendor(int vendorId) async {
//     return await _apiService.delete<void>(
//       endpoint: 'portal/payments/vendors/$vendorId',
//       body: {},
//     );
//   }
// }
