import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/model/cbt_license_activation_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CbtLicenseService {
  final String baseUrl =
      'https://linkskool.net/api/v3/public/cbt/license/activate/mobile';
  final String statusUrl =
      'https://linkskool.net/api/v3/public/cbt/license/status/mobile';
  final String trialUrl =
      'https://linkskool.net/api/v3/public/cbt/license/trial/start';
  final apiKey = EnvConfig.apiKey;

  static const String _licenseKey = 'cbt_license_activation';
  static const String _licenseStatusKey = 'cbt_license_status_active';
  static const String _licenseStatusTsKey = 'cbt_license_status_checked_at';
  static const String _licenseStatusUserKey = 'cbt_license_status_user_id';
  static const int _statusCacheMinutes = 0;

  Future<CbtLicenseActivationModel> activateLicense({
    required int userId,
  }) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: json.encode({'user_id': userId}),
      );

      print(
          'CBT License Activation Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final model = CbtLicenseActivationModel.fromJson(
            decoded['data'] as Map<String, dynamic>,
          );
          await _persistLicense(model);
          await _setCachedLicenseStatus(true, userId);
          return model;
        }
        throw Exception(decoded['message'] ?? 'Activation failed');
      }

      throw Exception('Activation failed: ${response.statusCode}');
    } catch (e) {
      throw Exception('Activation failed: $e');
    }
  }

  Future<void> _persistLicense(CbtLicenseActivationModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_licenseKey, json.encode(model.toJson()));
  }

  Future<CbtLicenseActivationModel?> getPersistedLicense() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_licenseKey);
    if (raw == null || raw.isEmpty) return null;
    final decoded = json.decode(raw) as Map<String, dynamic>;
    return CbtLicenseActivationModel.fromJson(decoded);
  }

  Future<bool> isLicenseActive({required int userId, bool forceRefresh = false}) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      if (!forceRefresh) {
        final cached = await _getCachedLicenseStatus(userId);
        if (cached != null) {
          return cached;
        }
      }

      final uri = Uri.parse(statusUrl).replace(
        queryParameters: {'user_id': userId.toString()},
      );
      print('Checking license status with URI: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );

      print(
          'CBT License Status Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final data = decoded['data'] as Map<String, dynamic>;
          var isActive = data['active'] == true;
          final expiresAtRaw = data['expires_at']?.toString();
          if (isActive && expiresAtRaw != null && expiresAtRaw.isNotEmpty) {
            final expiresAt = _parseDateTime(expiresAtRaw);
            if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
              isActive = false;
            }
          }
          await _setCachedLicenseStatus(isActive, userId);
          return isActive;
        }
        throw Exception(decoded['message'] ?? 'Failed to load license status');
      }

      throw Exception('Failed to load license status: ${response.statusCode}');
    } catch (e) {
      throw Exception('License status check failed: $e');
    }
  }

  Future<bool?> _getCachedLicenseStatus(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_licenseStatusTsKey);
    final cached = prefs.getBool(_licenseStatusKey);
    final cachedUserId = prefs.getInt(_licenseStatusUserKey);
    if (ts == null || cached == null) return null;
    if (cachedUserId == null || cachedUserId != userId) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final maxAgeMs = _statusCacheMinutes * 60 * 1000;
    if (now - ts > maxAgeMs) {
      return null;
    }
    return cached;
  }

  Future<void> _setCachedLicenseStatus(bool isActive, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_licenseStatusKey, isActive);
    await prefs.setInt(_licenseStatusUserKey, userId);
    await prefs.setInt(
      _licenseStatusTsKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  DateTime? _parseDateTime(String value) {
    final normalized = value.contains(' ')
        ? value.replaceFirst(' ', 'T')
        : value;
    return DateTime.tryParse(normalized);
  }

  Future<void> startFreeTrial({
    required int userId,
    String platform = 'mobile',
  }) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final response = await http.post(
        Uri.parse(trialUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: json.encode({
          'user_id': userId,
          'platform': platform,
        }),
      );

      print(
          'CBT Start Trial Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          return;
        }
        throw Exception(decoded['message'] ?? 'Failed to start trial');
      }

      throw Exception('Failed to start trial: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to start trial: $e');
    }
  }
}
