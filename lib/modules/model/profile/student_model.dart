class StudentPayment {
  final String name;
  final String grade;
  final String amount;
  final String? phoneNumber;

  StudentPayment({
    required this.name,
    required this.grade,
    required this.amount,
    this.phoneNumber,
  });
}