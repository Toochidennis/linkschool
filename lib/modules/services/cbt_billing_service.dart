import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';


enum BillingVerifyStatus { success, notFoundYet, failed }

class BillingVerifyResult {
  final BillingVerifyStatus status;
  final String message;
  BillingVerifyResult({required this.status, required this.message});
}
class CbtBillingService {
  final  apiBaseUrl = EnvConfig.apiBaseUrl;
  String get baseUrl => '$apiBaseUrl/public/cbt/billing/verify';
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
  message: 'Server error: ${response.statusCode}',
);

    
    } catch (e) {
  return BillingVerifyResult(
    status: BillingVerifyStatus.failed,
    message: e.toString(),
  );
}
  }
}
