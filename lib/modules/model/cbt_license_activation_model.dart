class CbtLicenseActivationModel {
  final String status;
  final CbtLicenseInfo license;
  final CbtLicensePolicy policy;
  final String message;

  const CbtLicenseActivationModel({
    required this.status,
    required this.license,
    required this.policy,
    required this.message,
  });

  factory CbtLicenseActivationModel.fromJson(Map<String, dynamic> json) {
    return CbtLicenseActivationModel(
      status: json['status']?.toString() ?? '',
      license: CbtLicenseInfo.fromJson(
        json['license'] as Map<String, dynamic>? ?? const {},
      ),
      policy: CbtLicensePolicy.fromJson(
        json['policy'] as Map<String, dynamic>? ?? const {},
      ),
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'license': license.toJson(),
      'policy': policy.toJson(),
      'message': message,
    };
  }
}

class CbtLicenseInfo {
  final String licenseId;
  final String platform;
  final String type;
  final String expiresAt;
  final String issuedAt;
  final String status;
  final bool deviceBound;

  const CbtLicenseInfo({
    required this.licenseId,
    required this.platform,
    required this.type,
    required this.expiresAt,
    required this.issuedAt,
    required this.status,
    required this.deviceBound,
  });

  factory CbtLicenseInfo.fromJson(Map<String, dynamic> json) {
    return CbtLicenseInfo(
      licenseId: json['license_id']?.toString() ?? '',
      platform: json['platform']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      expiresAt: json['expires_at']?.toString() ?? '',
      issuedAt: json['issued_at']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      deviceBound: json['device_bound'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'license_id': licenseId,
      'platform': platform,
      'type': type,
      'expires_at': expiresAt,
      'issued_at': issuedAt,
      'status': status,
      'device_bound': deviceBound,
    };
  }
}

class CbtLicensePolicy {
  final int revalidateAfterDays;
  final bool offlineAllowed;

  const CbtLicensePolicy({
    required this.revalidateAfterDays,
    required this.offlineAllowed,
  });

  factory CbtLicensePolicy.fromJson(Map<String, dynamic> json) {
    return CbtLicensePolicy(
      revalidateAfterDays: json['revalidate_after_days'] as int? ?? 0,
      offlineAllowed: json['offline_allowed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revalidate_after_days': revalidateAfterDays,
      'offline_allowed': offlineAllowed,
    };
  }
}
