import 'package:linkschool/modules/model/admin/vendor/vendor_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
// import 'package:linkschool/modules/model/vendor.dart';

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
    return await _apiService.delete<void>(
      endpoint: 'portal/payments/vendors/$vendorId',
      body: {},
    );
  }
}