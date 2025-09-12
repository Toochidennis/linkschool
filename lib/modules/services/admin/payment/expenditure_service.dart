// New file: modules/services/admin/payment/expenditure_service.dart
// import 'package:linkschool/modules/model/admin/payment/expenditure_model.dart';
import 'package:linkschool/modules/model/admin/expenditure_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class ExpenditureService {
  final ApiService _apiService;

  ExpenditureService(this._apiService);

  Future<ApiResponse<void>> addExpenditure(Map<String, dynamic> payload) async {
    return await _apiService.post<void>(
      endpoint: 'portal/payments/expenditure',
      body: payload,
    );
  }

  Future<ApiResponse<void>> updateExpenditure(int id, Map<String, dynamic> payload) async {
    return await _apiService.put<void>(
      endpoint: 'portal/payments/expenditure/$id',
      body: payload,
    );
  }

  Future<ApiResponse<List<Expenditure>>> fetchExpenditures(int vendorId) async {
    return await _apiService.get<List<Expenditure>>(
      endpoint: 'portal/payments/expenditure',
      queryParams: {'customer_id': vendorId},
      fromJson: (json) {
        final List<dynamic> list = json['response'] as List<dynamic>;
        return list.map((e) => Expenditure.fromJson(e)).toList();
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> generateReport(Map<String, dynamic> payload) async {
    return await _apiService.post<Map<String, dynamic>>(
      endpoint: 'portal/payments/expenditure/report/generate',
      body: payload,
      fromJson: (json) => Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}