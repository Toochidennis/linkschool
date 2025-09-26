// models/invoice_model.dart
class InvoiceResponse {
  final bool success;
  final int? statusCode;
  final InvoiceData response;

  InvoiceResponse({
    required this.success,
    required this.statusCode,
    required this.response,
  });

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceResponse(
      success: json['success'] ?? false,
      statusCode: json['statusCode'],
      response: InvoiceData.fromJson(json['response'] ?? {}),
    );
  }
}

class InvoiceData {
  final List<Invoice> invoices;
  final List<Payment> payments;

  InvoiceData({
    required this.invoices,
    required this.payments,
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      invoices: (json['invoices'] as List?)
              ?.where((item) => item != null)
              .map((item) => Invoice.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      payments: (json['payments'] as List?)
              ?.where((item) => item != null)
              .map((item) => Payment.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Invoice {
  final int? id;
  final List<InvoiceDetail> details;
  final double amount;
  final String year; // Already stored as session format
  final int? term;

  Invoice({
    required this.id,
    required this.details,
    required this.amount,
    required this.year,
    required this.term,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      details: (json['invoice_details'] as List?)
              ?.where((item) => item != null)
              .map((d) => InvoiceDetail.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      year: _formatSchoolSession(json['year']?.toString()),
      term: json['term']
    );
  }

  String get termName {
    switch (term) {
      case 1:
        return "First Term";
      case 2:
        return "Second Term";
      case 3:
        return "Third Term";
      default:
        return "";
    }
  }

  get invoiceId => null;

  get reference => null;

  get regNo => null;

  get studentName => null;

  get fees => null;

  get schoolId => null;
}

class InvoiceDetail {
  final String feeId;
  final String feeName;
  final double feeAmount;

  InvoiceDetail({
    required this.feeId,
    required this.feeName,
    required this.feeAmount,
  });

factory InvoiceDetail.fromJson(Map<String, dynamic> json) {
  return InvoiceDetail(
    feeId: json['fee_id'],
    feeName: json['fee_name']?.toString() ?? '',
    feeAmount: double.tryParse(json['amount']?.toString() ?? '') ?? 0.0, 
  );
}
}

class Payment {
  final int? id;
  final String reference;
  final String regNo;
  final String description;
  final String name;
  final double amount;
  final DateTime date;
  final String year; // Already stored as session format
  final int? term;
  final int? levelId;
  final int? classId;
  final String levelName;

  Payment({
    required this.id,
    required this.reference,
    required this.regNo,
    required this.description,
    required this.name,
    required this.amount,
    required this.date,
    required this.year,
    required this.term,
    required this.levelId,
    required this.classId,
    required this.levelName,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      reference: json['reference']?.toString() ?? '',
      regNo: json['reg_no']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      year: _formatSchoolSession(json['year']?.toString()),
      term: json['term'],
      levelId: json['level_id'],
      classId: json['class_id'],
      levelName: json['level_name']?.toString() ?? '',
    );
  }

  String get termName {
    switch (term) {
      case 1:
        return "First Term";
      case 2:
        return "Second Term";
      case 3:
        return "Third Term";
      default:
        return "";
    }
  }
}

/// Shared private helper
String _formatSchoolSession(String? yearString) {
  final parsedYear = int.tryParse(yearString ?? '');
  if (parsedYear == null) return yearString ?? '';
  return "${parsedYear - 1} / $parsedYear";
}