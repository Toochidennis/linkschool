class Grade {
  final String id;
  final String? grade_Symbol;
  final String? start;
  final String? remark;

  Grade({
    required this.id,
    required this.grade_Symbol,
    required this.start,
    required this.remark,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'].toString(),
      grade_Symbol: json['grade_symbol'] ?? "",
      start: json['start']?.toString() ?? "",
      remark: json['remark'] ?? "",
    );
  }
}
