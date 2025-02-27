
class Grading {
  final String status;
  final String message;
  final List<Grade> grades;

  Grading({
    required this.status,
    required this.message,
    required this.grades,
  });

  factory Grading.fromJson(Map<String, dynamic> json) => Grading(
        status: json["status"],
        message: json["message"],
        grades: List<Grade>.from(json["grades"].map((x) => Grade.fromJson(x))),
      );

  
  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "grades": grades.map((x) => x.toJson()).toList(),
      };
}

class Grade {
  final String id;
  final String gradeSymbol;
  final int start; 
  final String remark;

  Grade({
    required this.id,
    required this.gradeSymbol,
    required this.start,
    required this.remark,
  });

  
  factory Grade.fromJson(Map<String, dynamic> json) => Grade(
        id: json["id"],
        gradeSymbol: json["grade_symbol"],
        start: int.tryParse(json["start"]) ?? 0, 
        remark: json["remark"],
      );

  
  Map<String, dynamic> toJson() => {
        "id": id,
        "grade_symbol": gradeSymbol,
        "start": start.toString(), 
        "remark": remark,
      };
}
