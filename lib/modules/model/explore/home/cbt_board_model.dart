import 'subject_model.dart';

class CBTBoardModel {
  final String id;
  final String pictureUrl;
  final String title;
  final String boardCode;
  final String shortName;
  final List<SubjectModel> subjects;

  CBTBoardModel({
    required this.id,
    required this.pictureUrl,
    required this.title,
    required this.boardCode,
    required this.shortName,
    required this.subjects,
  });

  factory CBTBoardModel.fromJson(Map<String, dynamic> json) {
    return CBTBoardModel(
      id: json['i'] ?? '',
      pictureUrl: json['p'] ?? '',
      title: json['t'] ?? '',
      boardCode: json['c'] ?? '',
      shortName: json['s'] ?? '',
      subjects: (json['d'] as List<dynamic>?)
          ?.map((subject) => SubjectModel.fromJson(subject))
          .toList() ?? [],
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
      id: json['i'] ?? '',
      year: json['d'] ?? '',
    );
  }
}