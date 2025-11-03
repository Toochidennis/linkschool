class Vendor {
  final int id;
  final String vendorName;
  final String reference;
  final String phoneNumber;
  final String email;
  final String? address;

  Vendor({
    required this.id,
    required this.vendorName,
    required this.reference,
    required this.phoneNumber,
    required this.email,
    this.address,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as int,
      vendorName: json['vendor_name'] as String,
      reference: json['reference'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_name': vendorName,
      'reference': reference,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
    };
  }
}

