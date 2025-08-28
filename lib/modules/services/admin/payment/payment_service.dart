import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/payment_models.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
// import '../models/payment_models.dart';
// import 'api_service.dart';

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
      final payload = {
        'invoice_id': invoiceId,
        'reference': reference,
        'reg_no': regNo,
        'name': name,
        'fees': fees.map((fee) => {
          'fee_id': int.tryParse(fee.feeId) ?? 0,
          'fee_name': fee.feeName,
          'amount': fee.amount,
        }).toList(),
        'amount': amount,
        'class_id': classId,
        'level_id': levelId,
        'year': int.tryParse(year) ?? 0,
        'term': term,
      };

      final response = await _apiService.request(
        endpoint: 'portal/students/${regNo}/make-payment',
        method: HttpMethod.POST,
        body: payload,
      );

      return response.success;
    } catch (e) {
      print('Error making payment: $e');
      return false;
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

      // Only return levels that have corresponding classes
      return levelsList.where((level) {
        return classesList.any((cls) => cls.levelId == level.id && cls.className.isNotEmpty);
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

      final level = levels
          .map((l) => Level.fromJson(l))
          .firstWhere((l) => l.id == levelId, orElse: () => Level(id: 0, levelName: ''));
      
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

      final classModel = classes
          .map((c) => ClassModel.fromJson(c))
          .firstWhere((c) => c.id == classId, orElse: () => ClassModel(id: 0, className: '', levelId: 0));
      
      return classModel.className.isNotEmpty ? classModel.className : null;
    } catch (e) {
      print('Error getting class name: $e');
      return null;
    }
  }
}
