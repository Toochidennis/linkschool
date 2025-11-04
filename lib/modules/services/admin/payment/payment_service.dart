import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/payment_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class PaymentService {
  final ApiService _apiService;

  PaymentService(this._apiService);

  Future<PaymentDashboardSummary?> getDashboardSummary() async {
    try {
      final userBox = Hive.box('userData');
      final settings = userBox.get('settings');

      if (settings == null) {
        throw Exception('No settings found. Please login again.');
      }

      final year = settings['year'];
      final term = settings['term'];

      final response = await _apiService.request<PaymentDashboardSummary>(
        endpoint: 'portal/payments/dashboard/summary',
        method: HttpMethod.GET,
        queryParams: {
          'year': year,
          'term': term,
        },
        fromJson: (json) => PaymentDashboardSummary.fromJson(json['data']),
      );

      return response.data;
    } catch (e) {
      print('Error fetching dashboard summary: $e');
      return null;
    }
  }

  Future<List<PaidInvoice>> getPaidInvoices({
    required int levelId,
    required int classId,
  }) async {
    try {
      final userBox = Hive.box('userData');
      final settings = userBox.get('settings');

      if (settings == null) {
        throw Exception('No settings found. Please login again.');
      }

      final year = settings['year'];
      final term = settings['term'];

      final response = await _apiService.request<List<PaidInvoice>>(
        endpoint: 'portal/payments/invoices/paid',
        method: HttpMethod.GET,
        queryParams: {
          'year': year,
          'term': term,
          'level_id': levelId,
          'class_id': classId,
        },
        fromJson: (json) => (json['data'] as List)
            .map((item) => PaidInvoice.fromJson(item))
            .toList(),
      );

      return response.data ?? [];
    } catch (e) {
      print('Error fetching paid invoices: $e');
      return [];
    }
  }

  Future<List<UnpaidStudent>> getUnpaidInvoices({
    required int levelId,
    required int classId,
  }) async {
    try {
      final userBox = Hive.box('userData');
      final settings = userBox.get('settings');

      if (settings == null) {
        throw Exception('No settings found. Please login again.');
      }

      final year = settings['year'];
      final term = settings['term'];

      final response = await _apiService.request<List<UnpaidStudent>>(
        endpoint: 'portal/payments/invoices/unpaid',
        method: HttpMethod.GET,
        queryParams: {
          'year': year,
          'term': term,
          'level_id': levelId,
          'class_id': classId,
        },
        fromJson: (json) => (json['data'] as List)
            .map((item) => UnpaidStudent.fromJson(item))
            .toList(),
      );

      return response.data ?? [];
    } catch (e) {
      print('Error fetching unpaid invoices: $e');
      return [];
    }
  }

  Future<bool> makePayment({
    required String invoiceId,
    required String reference,
    required String studentId,
    required String regNo,
    required String name,
    required List<InvoiceDetail> fees,
    required double amount,
    required int classId,
    required int levelId,
    required String year,
    required int term,
  }) async {
    try {
      final userBox = Hive.box('userData');

      // Try to get _db from multiple possible sources
      String? dbParam;

      // First try direct _db key
      dbParam = userBox.get('_db');

      // If not found, try from loginResponse
      if (dbParam == null) {
        final loginResponse = userBox.get('loginResponse');
        if (loginResponse != null) {
          dbParam = loginResponse['_db'] ?? loginResponse['db'];
        }
      }

      // If still not found, try from userData directly
      dbParam ??= userBox.get('db');

      if (dbParam == null || dbParam.isEmpty) {
        throw Exception('Database parameter not found. Please login again.');
      }

      print('Using database parameter: $dbParam');

      // Convert year to integer for the API
      int yearInt = int.tryParse(year) ?? DateTime.now().year;

      final payload = {
        'invoice_id': invoiceId,
        'reference': reference,
        'reg_no': regNo,
        'name': name,
        'type': 'offline', // Added missing type parameter with default value
        'invoice_details': fees
            .map((fee) => {
                  'fee_id':
                      int.tryParse(fee.feeId) ?? 0, // Ensure it's an integer
                  'fee_name': fee.feeName,
                  'amount': fee.amount,
                })
            .toList(),
        'amount': amount,
        'class_id': classId,
        'level_id': levelId,
        'year': yearInt, // Send as integer, not string
        'term': term,
        '_db': dbParam, // Use dynamic database parameter
      };

      print('Payment Payload: ${json.encode(payload)}');

      final response = await _apiService.request(
        endpoint: 'portal/students/$studentId/make-payment',
        method: HttpMethod.POST,
        body: payload,
        addDatabaseParam: false, // We're manually adding _db in the payload
      );

      print('Payment Response: ${response.rawData}');
      print('Payment Success: ${response.success}');
      print('Payment Message: ${response.message}');
      print('Payment Status Code: ${response.statusCode}');

      // Check for successful status codes (200, 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      if (!response.success) {
        throw Exception(
            'Payment failed: ${response.message ?? 'Unknown error'}');
      }

      return response.success;
    } catch (e) {
      print('Error making payment: $e');
      // Re-throw the exception so the UI can handle it properly
      throw Exception('Payment processing failed: $e');
    }
  }

  List<Level> getAvailableLevels() {
    try {
      final userBox = Hive.box('userData');
      final levels = userBox.get('levels') as List?;
      final classes = userBox.get('classes') as List?;

      if (levels == null || classes == null) return [];

      final levelsList = levels.map((l) => Level.fromJson(l)).toList();
      final classesList = classes.map((c) => ClassModel.fromJson(c)).toList();

      return levelsList.where((level) {
        return classesList
            .any((cls) => cls.levelId == level.id && cls.className.isNotEmpty);
      }).toList();
    } catch (e) {
      print('Error getting available levels: $e');
      return [];
    }
  }

  List<ClassModel> getClassesForLevel(int levelId) {
    try {
      final userBox = Hive.box('userData');
      final classes = userBox.get('classes') as List?;

      if (classes == null) return [];

      return classes
          .map((c) => ClassModel.fromJson(c))
          .where((cls) => cls.levelId == levelId && cls.className.isNotEmpty)
          .toList();
    } catch (e) {
      print('Error getting classes for level: $e');
      return [];
    }
  }

  String? getLevelName(int levelId) {
    try {
      final userBox = Hive.box('userData');
      final levels = userBox.get('levels') as List?;

      if (levels == null) return null;

      final level = levels.map((l) => Level.fromJson(l)).firstWhere(
          (l) => l.id == levelId,
          orElse: () => Level(id: 0, levelName: ''));

      return level.levelName.isNotEmpty ? level.levelName : null;
    } catch (e) {
      print('Error getting level name: $e');
      return null;
    }
  }

  String? getClassName(int classId) {
    try {
      final userBox = Hive.box('userData');
      final classes = userBox.get('classes') as List?;

      if (classes == null) return null;

      final classModel = classes.map((c) => ClassModel.fromJson(c)).firstWhere(
          (c) => c.id == classId,
          orElse: () => ClassModel(id: 0, className: '', levelId: 0));

      return classModel.className.isNotEmpty ? classModel.className : null;
    } catch (e) {
      print('Error getting class name: $e');
      return null;
    }
  }

  Future<IncomeReport> getIncomeReport(Map<String, dynamic> params) async {
    final response = await _apiService.post(
      endpoint: 'portal/payments/income/report/generate',
      body: params,
    );

    print("me and $params");

    if (response.success && response.rawData != null) {
      final data = response.rawData!['data'];
      return IncomeReport.fromJson(data);
    } else {
      throw Exception(response.message);
    }
  }
}
