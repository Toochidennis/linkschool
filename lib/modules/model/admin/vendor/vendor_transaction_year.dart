// New file: lib/modules/model/admin/vendor/vendor_transaction_model.dart
class VendorTransactionYear {
  final int year;
  final double total;

  VendorTransactionYear({required this.year, required this.total});

  factory VendorTransactionYear.fromJson(Map<String, dynamic> json) =>
      VendorTransactionYear(
        year: json['year'] as int,
        total: (json['total'] as num).toDouble(),
      );
}

class VendorTransactionDetail {
  final int id;
  final String description;
  final String customerId;
  final String customerReference;
  final String customerName;
  final double amount;
  final String accountNumber;
  final String accountName;
  final int year;
  final int term;
  final String date;

  VendorTransactionDetail({
    required this.id,
    required this.description,
    required this.customerId,
    required this.customerReference,
    required this.customerName,
    required this.amount,
    required this.accountNumber,
    required this.accountName,
    required this.year,
    required this.term,
    required this.date,
  });

  factory VendorTransactionDetail.fromJson(Map<String, dynamic> json) =>
      VendorTransactionDetail(
        id: json['id'] as int,
        description: json['description'] as String,
        customerId: json['customer_id'] as String,
        customerReference: json['customer_reference'] as String,
        customerName: json['customer_name'] as String,
        amount: (json['amount'] as num).toDouble(),
        accountNumber: json['account_number'] as String,
        accountName: json['account_name'] as String,
        year: int.parse(json['year'] as String),
        term: json['term'] as int,
        date: json['date'] as String,
      );
}
