import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';

class CourseCheckoutItem {
  final int courseId;
  final int cohortId;

  const CourseCheckoutItem({
    required this.courseId,
    required this.cohortId,
  });

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'cohort_id': cohortId,
    };
  }
}

class CourseCheckoutInitResult {
  final bool success;
  final String status;
  final String message;
  final String reference;
  final String paymentUrl;
  final String callbackUrl;

  const CourseCheckoutInitResult({
    required this.success,
    required this.status,
    required this.message,
    required this.reference,
    required this.paymentUrl,
    required this.callbackUrl,
  });
}

class CourseCheckoutReserveResult {
  final bool success;
  final String status;
  final String message;

  const CourseCheckoutReserveResult({
    required this.success,
    required this.status,
    required this.message,
  });
}

class CourseCheckoutService {
  final String apiBaseUrl = EnvConfig.apiBaseUrl;
  final String apiKey = EnvConfig.apiKey;

  String get checkoutUrl =>
      '$apiBaseUrl/public/learning/cohorts/enrollments/checkout';

  String get reserveUrl =>
      '$apiBaseUrl/public/learning/cohorts/enrollments/reserve';

  String checkoutStatusUrl(String reference) =>
      '$apiBaseUrl/public/learning/cohorts/enrollments/checkout/${Uri.encodeComponent(reference)}/status';

  Future<CourseCheckoutInitResult> initializeCheckout({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required int programId,
    required String callbackUrl,
    required List<CourseCheckoutItem> items,
  }) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception('API key not found in .env file');
      }

      final body = {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email,
        'program_id': programId,
        'callback_url': callbackUrl,
        'items': items.map((item) => item.toJson()).toList(),
      };
      
      final response = await http.post(
        Uri.parse(checkoutUrl),
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
          return CourseCheckoutInitResult(
            success: true,
            status: data['status']?.toString() ?? 'pending',
            message: data['message']?.toString() ??
                decoded['message']?.toString() ??
                'Payment initialized successfully',
            reference: data['reference']?.toString() ?? '',
            paymentUrl: data['payment_url']?.toString() ??
                data['paymentUrl']?.toString() ??
                '',
            callbackUrl: data['callback_url']?.toString() ??
                data['callbackUrl']?.toString() ??
                callbackUrl,
          );
        }
      }

      return CourseCheckoutInitResult(
        success: false,
        status: 'failed',
        message: _extractMessage(response.body) ??
            'Server error: ${response.statusCode}',
        reference: '',
        paymentUrl: '',
        callbackUrl: callbackUrl,
      );
    } catch (e) {
      return CourseCheckoutInitResult(
        success: false,
        status: 'failed',
        message: e.toString(),
        reference: '',
        paymentUrl: '',
        callbackUrl: callbackUrl,
      );
    }
  }

  Future<CourseCheckoutReserveResult> reserveSeat({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required int programId,
    required List<CourseCheckoutItem> items,
  }) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception('API key not found in .env file');
      }

      final body = {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email,
        'program_id': programId,
        'items': items.map((item) => item.toJson()).toList(),
      };

      final response = await http.post(
        Uri.parse(reserveUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: json.encode(body),
      );

      print('Course reserve response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          final data = decoded['data'];
          final isReserved =
              data is bool ? data : data?.toString().toLowerCase() == 'true';
          return CourseCheckoutReserveResult(
            success: isReserved == true,
            status: isReserved == true ? 'success' : 'failed',
            message: decoded['message']?.toString() ??
                (isReserved == true
                    ? 'Reservation completed successfully.'
                    : 'Reservation could not be confirmed.'),
          );
        }
      }

      return CourseCheckoutReserveResult(
        success: false,
        status: 'failed',
        message: _extractMessage(response.body) ??
            'Server error: ${response.statusCode}',
      );
    } catch (e) {
      print('Course reserve error: $e');
      return CourseCheckoutReserveResult(
        success: false,
        status: 'failed',
        message: e.toString(),
      );
    }
  }

  Future<CourseCheckoutVerifyResult> verifyCheckoutStatus({
    required String reference,
  }) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception('API key not found in .env file');
      }

      final response = await http.get(
        Uri.parse(checkoutStatusUrl(reference)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          final data = decoded['data'];
          final isPaid = data is bool ? data : data?.toString().toLowerCase() == 'true';
          return CourseCheckoutVerifyResult(
            success: isPaid == true,
            message: isPaid == true
                ? 'Payment successful'
                : 'Payment could not be confirmed. Please try again.',
          );
        }
      }

      return CourseCheckoutVerifyResult(
        success: false,
        message: _extractMessage(response.body) ??
            'Server error: ${response.statusCode}',
      );
    } catch (e) {
      return CourseCheckoutVerifyResult(
        success: false,
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

class CourseCheckoutVerifyResult {
  final bool success;
  final String message;

  const CourseCheckoutVerifyResult({
    required this.success,
    required this.message,
  });
}
