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
  final dynamic mandatoryValue = json['is_mandatory'];
  final bool isMandatory = mandatoryValue == 1 ||
      mandatoryValue == true ||
      mandatoryValue == '1' ||
      mandatoryValue == 'true';

  return FeeName(
    id: json['id'] ?? 0,
    feeName: json['fee_name'] ?? '',
    isMandatory: isMandatory,
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


class UpdateFeeNameRequest {
  final String feeName;
  final bool isMandatory;

  UpdateFeeNameRequest({
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
