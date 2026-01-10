// File: modules/model/admin/payment/expenditure_model.dart
class Expenditure {
  final int id;
  final int customerId;
  final String customerReference;
  final String customerName;
  final String description;
  final double amount;
  final String date;
  final String accountNumber;
  final String accountName;
  final int year;
  final int term;

  Expenditure({
    required this.id,
    required this.customerId,
    required this.customerReference,
    required this.customerName,
    required this.description,
    required this.amount,
    required this.date,
    required this.accountNumber,
    required this.accountName,
    required this.year,
    required this.term,
  });

  // Manual JSON deserialization
  factory Expenditure.fromJson(Map<String, dynamic> json) {
    return Expenditure(
      id: json['id'] as int,
      customerId: json['customer_id'] as int,
      customerReference: json['customer_reference'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] as String? ?? '',
      accountNumber: json['account_number'] as String? ?? '',
      accountName: json['account_name'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      term: json['term'] as int? ?? 0,
    );
  }

  // Manual JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_reference': customerReference,
      'customer_name': customerName,
      'description': description,
      'amount': amount,
      'date': date,
      'account_number': accountNumber,
      'account_name': accountName,
      'year': year,
      'term': term,
    };
  }
}
