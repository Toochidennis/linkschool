class Register {
  final String id;
  final String name;

  Register({
    required this.id,
    required this.name,
  });

  factory Register.fromJson(Map<String, dynamic> json) {
    return Register(
      id: json['id'].toString(),
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
