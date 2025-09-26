class AccountModel {
  final int id;
  final String accountName;
  final int accountType;
  final String accountNumber;
  final String inactive;

  AccountModel({
    required this.id,
    required this.accountName,
    required this.accountType,
    required this.accountNumber,
    required this.inactive,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] ?? 0,
      accountName: json['account_name'] ?? '',
      accountType: json['account_type'] ?? 0,
      accountNumber: json['account_number']?.toString() ?? '',
      inactive: json['inactive'] ?? 'FALSE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_name': accountName,
      'account_type': accountType,
      'account_number': accountNumber,
      'inactive': inactive,
    };
  }

  String get accountTypeString {
    return accountType == 0 ? 'Income' : 'Expenditure';
  }

  // Create a copy with updated fields
  AccountModel copyWith({
    int? id,
    String? accountName,
    int? accountType,
    String? accountNumber,
    String? inactive,
  }) {
    return AccountModel(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      accountType: accountType ?? this.accountType,
      accountNumber: accountNumber ?? this.accountNumber,
      inactive: inactive ?? this.inactive,
    );
  }
}

class AccountResponse {
  final List<AccountModel> data;
  final Map<String, dynamic> meta;

  AccountResponse({
    required this.data,
    required this.meta,
  });

  factory AccountResponse.fromJson(Map<String, dynamic> json) {
    final responseData = json['response'] ?? {};
    final dataList = responseData['data'] as List<dynamic>? ?? [];
    final meta = responseData['meta'] as Map<String, dynamic>? ?? {};

    return AccountResponse(
      data: dataList.map((item) => AccountModel.fromJson(item)).toList(),
      meta: meta,
    );
  }
}
