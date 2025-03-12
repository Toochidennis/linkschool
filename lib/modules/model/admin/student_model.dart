class Student {
  final int id;
  final String regId;
  final String name;
  final String className;
  final Map<String, Map<String, double>> terms;
  bool isSelected;

  Student( {required this.id,
   required this.name,
    required this.regId,
    required this.className,
       required this.terms,
    this.isSelected = false
    });

factory Student.fromJson(Map<String, dynamic> json) {
  return Student(
    id: json['id'] ?? 0, 
    name: json['student_name'] ?? "Unknown",
    regId: json['registration_no'] ?? "",
    className: json['class_name'] ?? "Unknown",
    terms: (json['terms'] != null)
        ? (json['terms'] as Map<String, dynamic>).map(
            (year, termData) => MapEntry(
              year,
              (termData as Map<String, dynamic>).map(
                (term, score) => MapEntry(term, double.tryParse(score.toString()) ?? 0.0),
              ),
            ),
          )
        : {}, // Default to an empty map if null
  );
}


  Student copyWith({
    int? id,
    String? name,
    String? regId,
    String? className,
    String? terms,
    bool? isSelected,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      regId: regId ?? this.regId,
      className: className ?? this.className,
      terms: terms as Map<String, Map<String, double>>? ?? this.terms,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
