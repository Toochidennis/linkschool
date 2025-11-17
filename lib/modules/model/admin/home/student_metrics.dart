class StudentStatsResponse {
  final int statusCode;
  final bool success;
  final StudentStats response;

  StudentStatsResponse({
    required this.statusCode,
    required this.success,
    required this.response,
  });

  factory StudentStatsResponse.fromJson(Map<String, dynamic> json) {
    return StudentStatsResponse(
      statusCode: json['statusCode'],
      success: json['success'],
      response: StudentStats.fromJson(json['response']),
    );
  }
}

class ChartData {
  final String x;
  final int y;

  ChartData({
    required this.x,
    required this.y,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      x: json['x'] as String,
      y: json['y'] as int,
    );
  }
}

class StudentStats {
  final int totalStudents;
  final int maleStudents;
  final int femaleStudents;
  final List<ChartData> charts;
  final List<LevelModel> levels;

  StudentStats({
    required this.totalStudents,
    required this.maleStudents,
    required this.femaleStudents,
    required this.charts,
    required this.levels,
  });

  factory StudentStats.fromJson(Map<String, dynamic> json) {
    return StudentStats(
      totalStudents: json['total_students'],
      maleStudents: json['male_students'],
      femaleStudents: json['female_students'],
      charts: (json['charts'] as List?)
          ?.map((e) => ChartData.fromJson(e))
          .toList() ?? [],
      levels: (json['levels'] as List)
          .map((e) => LevelModel.fromJson(e))
          .toList(),
    );
  }
}

class LevelModel {
  final int levelId;
  final String levelName;
  final int totalStudents;
  final List<ClassItem> classes;

  LevelModel({
    required this.levelId,
    required this.levelName,
    required this.totalStudents,
    required this.classes,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      levelId: json['level_id'],
      levelName: json['level_name'],
      totalStudents: json['total_students'],
      classes: (json['classes'] as List)
          .map((e) => ClassItem.fromJson(e))
          .toList(),
    );
  }
}

class ClassItem {
  final int classId;
  final String className;
  final int totalStudents;

  ClassItem({
    required this.classId,
    required this.className,
    required this.totalStudents,
  });

  factory ClassItem.fromJson(Map<String, dynamic> json) {
    return ClassItem(
      classId: json['class_id'],
      className: json['class_name'],
      totalStudents: json['total_students'],
    );
  }
}
