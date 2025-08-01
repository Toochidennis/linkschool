class FeeName {
  final int id;
  final String feeName;
  final bool isMandatory;

  FeeName({
    required this.id,
    required this.feeName,
    required this.isMandatory,
  });

  factory FeeName.fromJson(Map<String, dynamic> json) {
    return FeeName(
      id: json['id'] ?? 0,
      feeName: json['fee_name'] ?? '',
      isMandatory: (json['is_mandatory'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fee_name': feeName,
      'is_mandatory': isMandatory ? 1 : 0,
    };
  }
}

class AddFeeNameRequest {
  final String feeName;
  final bool isMandatory;

  AddFeeNameRequest({
    required this.feeName,
    required this.isMandatory,
  });

  Map<String, dynamic> toJson() {
    return {
      'fee_name': feeName,
      'is_mandatory': isMandatory ? 1 : 0,
    };
  }
}
