class Grade {
  final String id;
  final String gradeSymbol;
  final String start;
  final String remark;

  Grade({
    required this.id,
    required this.gradeSymbol,
    required this.start,
    required this.remark,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'],
      gradeSymbol: json['grade_symbol'],
      start: json['start'],
      remark: json['remark'],
    );
  }
}