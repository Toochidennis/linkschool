import 'dart:ui';

// import 'video_model.dart';

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

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['course_id'].toString() ?? '',
      name: json['course_name'] ?? '',
      years: (json['years'] as List<dynamic>?)
              ?.map((year) => YearModel.fromJson(year))
              .toList() ??
          [],
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

  factory YearModel.fromJson(Map<String, dynamic> json) {
    return YearModel(
      id: json['exam_id'].toString() ?? '',
      year: json['year'] ?? '',
    );
  }
}
// class Category {
//   final String id;
//   final String level;
//   final String levelName;
//   final String name;
//   final List<Video> videos;

//   Category({
//     required this.id,
//     required this.level,
//     required this.levelName,
//     required this.name,
//     required this.videos,
//   });

//   factory Category.fromJson(Map<String, dynamic> json) {
//     return Category(
//       id: json['id'] ?? '',
//       level: json['level'] ?? '',
//       levelName: json['level_name'] ?? '',
//       name: json['name'] ?? '',
//       videos: (json['videos'] as List)
//           .map((video) => Video.fromJson(video))
//           .toList(),
//     );
//   }
// }
