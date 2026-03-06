import 'dart:ui';

class SubjectModel {
  final String id;
  final String name;
  String? subjectIcon;
  Color? cardColor;
  final List<YearModel>? years;

  SubjectModel({
    required this.id,
    required this.name,
    this.subjectIcon,
    this.cardColor,
    this.years,
  });

  // ✅ Used when parsing the STARTUP API response
  // courses from startup have: id, course_name (NO years)
  factory SubjectModel.fromStartupJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'].toString(),
      name: json['course_name'] ?? '',
      years: [], // years are empty until the exam is downloaded
    );
  }

  // ✅ Used when parsing DOWNLOADED exam data
  // courses from downloaded exam have: course_id, course_name, years[]
  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['course_id'].toString(),
      name: json['course_name'] ?? '',
      years: (json['years'] as List<dynamic>?)
              ?.map((year) => YearModel.fromJson(year))
              .toList() ??
          [],
    );
  }

  // ✅ Used when reading back from local SQLite
  factory SubjectModel.fromDb(
    Map<String, dynamic> row, {
    List<YearModel>? years,
  }) {
    return SubjectModel(
      id: row['id'].toString(),
      name: row['course_name'] ?? row['name'] ?? '',
      years: years ?? [],
    );
  }
}

class YearModel {
  final String id;
  final String year;

  YearModel({
    required this.id,
    required this.year,
  });

  // ✅ Used when parsing downloaded exam zip
  factory YearModel.fromJson(Map<String, dynamic> json) {
    return YearModel(
      id: json['exam_id'].toString(),
      year: json['year'] ?? '',
    );
  }

  // ✅ Used when reading back from local SQLite exams table
  factory YearModel.fromDb(Map<String, dynamic> row) {
    return YearModel(
      id: row['id'].toString(),
      year: row['year'].toString(),
    );
  }
}