class Student {
  final int id;
  final String name;
  bool isSelected;

  Student({
    required this.id, 
    required this.name, 
    this.isSelected = false
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['student_name'],
    );
  }

  Student copyWith({
    int? id,
    String? name,
    bool? isSelected,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}