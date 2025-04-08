// lib/models/course.dart
class Course {
  final String id;
  final String name;
  final String code;

  Course({required this.id, required this.name, required this.code});

  factory Course.fromList(List<dynamic> row) {
    return Course(
      id: row[0].toString(),
      name: row[1].toString(),
      code: row[2].toString(),
    );
  }
}