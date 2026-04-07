import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/model/cbt_license_activation_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CbtLicenseStatus {
  const CbtLicenseStatus({
    required this.active,
    this.source,
    this.reason,
    this.expiresAt,
    this.licenseId,
    this.deviceBound,
  });

  final bool active;
  final String? source;
  final String? reason;
  final String? expiresAt;
  final int? licenseId;
  final bool? deviceBound;

  bool get isTrial => active && source == 'trial';
  bool get isPaid => active && source == 'payment';
  bool get isExpired =>
      !active && (reason == 'expired' || reason == 'trial_expired');

  Map<String, dynamic> toCacheJson() {
    return {
      'active': active,
      'source': source,
      'reason': reason,
      'expires_at': expiresAt,
      'license_id': licenseId,
      'device_bound': deviceBound,
    };
  }
}

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
  static const String _licenseExpiresAtKey = 'cbt_license_expires_at';
  static const String _licenseSourceKey = 'cbt_license_source';
  static const String _licenseReasonKey = 'cbt_license_reason';
  static const int _statusCacheMinutes = 30;

  void _log(String message) {
    debugPrint('[CbtLicenseService] $message');
  }

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final model = CbtLicenseActivationModel.fromJson(
            decoded['data'] as Map<String, dynamic>,
          );
          await _persistLicense(model);
          await _setCachedLicenseStatus(
            const CbtLicenseStatus(active: true),
            userId,
            expiresAt: model.license.expiresAt,
            source: model.license.type,
          );
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

  Future<bool> isLicenseActive({
    required int userId,
    bool forceRefresh = false,
  }) async {
    final status = await getLicenseStatus(
      userId: userId,
      forceRefresh: forceRefresh,
    );
    return status.active;
  }

  Future<CbtLicenseStatus> getLicenseStatus({
    required int userId,
    bool forceRefresh = false,
  }) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      if (!forceRefresh) {
        final cached = await _getCachedLicenseStatusDetails(userId);
        if (cached != null) {
          _log(
            'Using cached license status for userId=$userId '
            'active=${cached.active}, source=${cached.source}, '
            'reason=${cached.reason}, expiresAt=${cached.expiresAt}',
          );
          return cached;
        }
      }

      final uri = Uri.parse(statusUrl).replace(
        queryParameters: {'user_id': userId.toString()},
      );
      _log(
        'Requesting license status from server: '
        'userId=$userId, forceRefresh=$forceRefresh, url=$uri',
      );
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );
      _log(
        'License status response: '
        'userId=$userId, statusCode=${response.statusCode}, body=${response.body}',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final data = decoded['data'] as Map<String, dynamic>;
          final status = _statusFromPayload(data);
          _log(
            'Parsed license status: '
            'userId=$userId, active=${status.active}, source=${status.source}, '
            'reason=${status.reason}, expiresAt=${status.expiresAt}',
          );
          await _setCachedLicenseStatus(
            status,
            userId,
            expiresAt: status.expiresAt,
            source: status.source,
            reason: status.reason,
          );
          return status;
        }
        throw Exception(decoded['message'] ?? 'Failed to load license status');
      }

      throw Exception('Failed to load license status: ${response.statusCode}');
    } catch (e) {
      throw Exception('License status check failed: $e');
    }
  }

  CbtLicenseStatus _statusFromPayload(Map<String, dynamic> data) {
    final active = data['active'] == true;
    final source = data['source']?.toString();
    final reason = data['reason']?.toString();
    final expiresAtRaw = data['expires_at']?.toString();
    final licenseId = data['license_id'] is num
        ? (data['license_id'] as num).toInt()
        : int.tryParse(data['license_id']?.toString() ?? '');
    final deviceBound =
        data['device_bound'] == null ? null : data['device_bound'] == true;

    if (active && expiresAtRaw != null && expiresAtRaw.isNotEmpty) {
      final expiresAt = _parseDateTime(expiresAtRaw);
      if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
        return CbtLicenseStatus(
          active: false,
          source: source,
          reason: source == 'trial' ? 'trial_expired' : 'expired',
          expiresAt: expiresAtRaw,
          licenseId: licenseId,
          deviceBound: deviceBound,
        );
      }
    }

    return CbtLicenseStatus(
      active: active,
      source: source,
      reason: reason,
      expiresAt: expiresAtRaw,
      licenseId: licenseId,
      deviceBound: deviceBound,
    );
  }

  Future<CbtLicenseStatus?> _getCachedLicenseStatusDetails(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_licenseStatusTsKey);
    final cached = prefs.getBool(_licenseStatusKey);
    final cachedUserId = prefs.getInt(_licenseStatusUserKey);
    final expiresAtRaw = prefs.getString(_licenseExpiresAtKey);
    final source = prefs.getString(_licenseSourceKey);
    final reason = prefs.getString(_licenseReasonKey);
    if (ts == null || cached == null) return null;
    if (cachedUserId == null || cachedUserId != userId) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final maxAgeMs = _statusCacheMinutes * 60 * 1000;
    if (now - ts > maxAgeMs) {
      return null;
    }

    if (cached == true && expiresAtRaw != null && expiresAtRaw.isNotEmpty) {
      final expiresAt = _parseDateTime(expiresAtRaw);
      if (expiresAt != null) {
        if (DateTime.now().isBefore(expiresAt)) {
          return CbtLicenseStatus(
            active: true,
            source: source,
            expiresAt: expiresAtRaw,
          );
        }
        return CbtLicenseStatus(
          active: false,
          source: source,
          reason: source == 'trial' ? 'trial_expired' : 'expired',
          expiresAt: expiresAtRaw,
        );
      }
    }

    if (cached == false) {
      return CbtLicenseStatus(
        active: false,
        source: source,
        reason: reason,
        expiresAt: expiresAtRaw,
      );
    }
    return CbtLicenseStatus(
      active: cached,
      source: source,
      reason: reason,
      expiresAt: expiresAtRaw,
    );
  }

  Future<bool?> _getCachedLicenseStatus(int userId) async {
    final cached = await _getCachedLicenseStatusDetails(userId);
    return cached?.active;
  }

  Future<bool?> getCachedLicenseStatus(int userId) async {
    return _getCachedLicenseStatus(userId);
  }

  Future<CbtLicenseStatus?> getCachedLicenseDetails(int userId) async {
    return _getCachedLicenseStatusDetails(userId);
  }

  Future<DateTime?> getCachedLicenseExpiresAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_licenseExpiresAtKey);
    if (raw == null || raw.isEmpty) return null;
    return _parseDateTime(raw);
  }

  Future<bool> isCachedLicenseInactiveOrExpired(int userId) async {
    final cached = await _getCachedLicenseStatus(userId);
    if (cached == false) return true;
    final expiresAt = await getCachedLicenseExpiresAt();
    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      return true;
    }
    return false;
  }

  Future<void> _setCachedLicenseStatus(
    CbtLicenseStatus status,
    int userId, {
    String? expiresAt,
    String? source,
    String? reason,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_licenseStatusKey, status.active);
    await prefs.setInt(_licenseStatusUserKey, userId);
    await prefs.setInt(
      _licenseStatusTsKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    final resolvedExpiresAt = expiresAt ?? status.expiresAt;
    final resolvedSource = source ?? status.source;
    final resolvedReason = reason ?? status.reason;
    if (resolvedExpiresAt != null && resolvedExpiresAt.isNotEmpty) {
      await prefs.setString(_licenseExpiresAtKey, resolvedExpiresAt);
    } else if (!status.active) {
      await prefs.remove(_licenseExpiresAtKey);
    }
    if (resolvedSource != null && resolvedSource.isNotEmpty) {
      await prefs.setString(_licenseSourceKey, resolvedSource);
    } else {
      await prefs.remove(_licenseSourceKey);
    }
    if (resolvedReason != null && resolvedReason.isNotEmpty) {
      await prefs.setString(_licenseReasonKey, resolvedReason);
    } else {
      await prefs.remove(_licenseReasonKey);
    }
  }

  Future<void> clearCachedLicenseStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_licenseKey);
    await prefs.remove(_licenseStatusKey);
    await prefs.remove(_licenseStatusTsKey);
    await prefs.remove(_licenseStatusUserKey);
    await prefs.remove(_licenseExpiresAtKey);
    await prefs.remove(_licenseSourceKey);
    await prefs.remove(_licenseReasonKey);
  }

  DateTime? _parseDateTime(String value) {
    final normalized =
        value.contains(' ') ? value.replaceFirst(' ', 'T') : value;
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
