import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';


enum BillingVerifyStatus { success, notFoundYet, failed }

class BillingVerifyResult {
  final BillingVerifyStatus status;
  final String message;
  BillingVerifyResult({required this.status, required this.message});
}

class BillingInitResult {
  final bool success;
  final String status;
  final String message;
  final String reference;
  final String paymentUrl;
  final String callbackUrl;

  BillingInitResult({
    required this.success,
    required this.status,
    required this.message,
    required this.reference,
    required this.paymentUrl,
    required this.callbackUrl,
  });
}

class CbtBillingService {
  final  apiBaseUrl = EnvConfig.apiBaseUrl;
  String get baseUrl => '$apiBaseUrl/public/cbt/billing/verify';
  String get initializeUrl => '$apiBaseUrl/public/cbt/billing/initiate';
  String statusUrl(String reference) =>
      '$apiBaseUrl/public/cbt/billing/$reference/status';

  final apiKey = EnvConfig.apiKey;

  Future<BillingVerifyResult>  verifyPayment({
    required int userId,
    required int planId,
    required String method,
    required String platform,
    required String firstName,
    required String lastName,
    required String voucherCode,
    required String reference,
  }) async {
    try {
      if (apiKey.isEmpty) {
        throw ("❌ API key not found in .env file");
      }

      final body = {
        'user_id': userId,
        'plan_id': planId,
        'method': method,
        'platform': platform,
        'first_name': firstName,
        'last_name': lastName,
        'voucher_code': voucherCode,
        'reference': reference,
      };
      print('Request2 body: $body');
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: json.encode(body),
      );

      print('CBT Billing Verification Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
  final decoded = json.decode(response.body);
  if (decoded['success'] == true) {
    final data = decoded['data'] as Map<String, dynamic>?;
    final status = data?['status']?.toString().toLowerCase();
    final message = data?['message']?.toString() ?? '';

    if (status == 'failed') {
      final isNotFoundYet = message.toLowerCase().contains('not found');
      return BillingVerifyResult(
        status: isNotFoundYet
            ? BillingVerifyStatus.notFoundYet
            : BillingVerifyStatus.failed,
        message: message,
      );
    }

    return BillingVerifyResult(
      status: BillingVerifyStatus.success,
      message: decoded['message'] ?? 'Success',
    );
  }
}

    return BillingVerifyResult(
      status: BillingVerifyStatus.failed,
      message: _extractMessage(response.body) ??
          'Server error: ${response.statusCode}',
    );

    
    } catch (e) {
  return BillingVerifyResult(
    status: BillingVerifyStatus.failed,
    message: e.toString(),
  );
}
  }


  
  Future<BillingInitResult> initializePayment({
  required int userId,
  required int planId,
  required String method,
  required String platform,
  required String email,
  required String firstName,
  required String lastName,
  required String voucherCode,
}) async {
  try {
    if (apiKey.isEmpty) throw ("❌ API key not found in .env file");

    final body = {
      'user_id': userId,
      'plan_id': planId,
      'method': method,
      'platform': platform,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'voucher_code': voucherCode,
    
    };

    print('Initialize Payment body: $body');

    final response = await http.post(
      Uri.parse(initializeUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: json.encode(body),
    );

  

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      if (decoded['success'] == true) {
        final data = (decoded['data'] as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return BillingInitResult(
          success: true,
          status: data['status']?.toString() ?? 'success',
          message: data['message']?.toString() ??
              decoded['message']?.toString() ??
              'Initialized',
          reference: data['reference']?.toString() ?? '',
          paymentUrl: data['payment_url']?.toString() ??
              data['paymentUrl']?.toString() ??
              '',
          callbackUrl: data['callback_url']?.toString() ??
              data['callbackUrl']?.toString() ??
              '',
        );
      }
    }

    return BillingInitResult(
      success: false,
      status: 'failed',
      message: _extractMessage(response.body) ??
          'Server error: ${response.statusCode}',
      reference: '',
      paymentUrl: '',
      callbackUrl: '',
    );
  } catch (e) {
    return BillingInitResult(
      success: false,
      status: 'failed',
      message: e.toString(),
      reference: '',
      paymentUrl: '',
      callbackUrl: '',
    );
  }
}

Future<BillingVerifyResult> checkPaymentStatus({
  required String reference,
}) async {
  try {
    if (apiKey.isEmpty) {
      throw ("❌ API key not found in .env file");
    }

    final response = await http.get(
      Uri.parse(statusUrl(reference)),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-KEY': apiKey,
      },
    );

    print('CBT Payment Status Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      if (decoded['success'] == true) {
        final data = decoded['data'] as Map<String, dynamic>?;
        final status = data?['status']?.toString().toLowerCase();
        final message = data?['message']?.toString() ??
            decoded['message']?.toString() ??
            'Success';

        if (status == 'success' || status == 'paid' || status == 'completed') {
          return BillingVerifyResult(
            status: BillingVerifyStatus.success,
            message: message,
          );
        }

        if (status == 'pending') {
          return BillingVerifyResult(
            status: BillingVerifyStatus.notFoundYet,
            message: message,
          );
        }

        return BillingVerifyResult(
          status: BillingVerifyStatus.failed,
          message: message,
        );
      }
    }

    return BillingVerifyResult(
      status: BillingVerifyStatus.failed,
      message: _extractMessage(response.body) ??
          'Server error: ${response.statusCode}',
    );
  } catch (e) {
    return BillingVerifyResult(
      status: BillingVerifyStatus.failed,
      message: e.toString(),
    );
  }
}

String? _extractMessage(String body) {
  try {
    final decoded = json.decode(body);
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message']?.toString().trim();
      if (message != null && message.isNotEmpty) return message;

      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        final nestedMessage = data['message']?.toString().trim();
        if (nestedMessage != null && nestedMessage.isNotEmpty) {
          return nestedMessage;
        }
      }
    }
  } catch (_) {
    // Fall through to raw body handling below.
  }

  final trimmed = body.trim();
  return trimmed.isNotEmpty ? trimmed : null;
}
}
