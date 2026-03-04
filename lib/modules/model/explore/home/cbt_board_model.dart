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

  // ✅ Matches actual API response fields: id, title, short, pic, courses
  factory CBTBoardModel.fromJson(Map<String, dynamic> json) {
    final String title = json['title'] ?? '';
    final String shortName = json['short'] ?? '';

    return CBTBoardModel(
      id: json['id'].toString(),
      pictureUrl: json['pic'] ?? '',
      title: title,
      boardCode: shortName,
      shortName: shortName,
      subjects: (json['courses'] as List<dynamic>?)
              ?.map((course) => SubjectModel.fromStartupJson(course))
              .toList() ??
          [],
    );
  }

  // ✅ For building from local SQLite rows
  factory CBTBoardModel.fromDb(
    Map<String, dynamic> row,
    List<SubjectModel> subjects,
  ) {
    return CBTBoardModel(
      id: row['id'].toString(),
      pictureUrl: '',
      title: row['name'] ?? '',
      boardCode: row['shortname'] ?? '',
      shortName: row['shortname'] ?? '',
      subjects: subjects,
    );
  }
}