class VendorTransaction {
  final String period;
  final String dateTime;
  final double amount;
  final String description;
  final String name;
  final String phoneNumber;
  final String reference;
  final String session;

  VendorTransaction({
    required this.period,
    required this.dateTime,
    required this.amount,
    required this.description,
    required this.name,
    required this.phoneNumber,
    required this.reference,
    required this.session,
  });
}
