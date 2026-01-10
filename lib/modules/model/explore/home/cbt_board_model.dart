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
    final String title = json['exam_title'] ?? '';
    final String boardCode =
        json['exam_shortname'] ?? _getBoardCodeFromTitle(title);

    return CBTBoardModel(
      id: json['exam_type_id'].toString() ?? '',
      pictureUrl: json['exam_image'] ?? '',
      title: title,
      boardCode: boardCode,
      shortName: json['exam_shortname'] ?? '',
      subjects: (json['courses'] as List<dynamic>?)
              ?.map((subject) => SubjectModel.fromJson(subject))
              .toList() ??
          [],
    );
  }

  static String _getBoardCodeFromTitle(String title) {
    switch (title) {
      case 'Joint Admission And Matriculation Board':
        return 'JAMB';
      case 'SENIOR SCHOOL CERTIFICATE EXAMINATION':
        return 'WAEC';
      case 'BASIC CERTIFICATE EXAMINATION':
        return 'BECE';
      case 'Millionaire':
        return 'Million';
      case 'PRIMARY SCHOOL TRANSITION EXAMINATION':
        return 'PSTE';
      case 'ESUT POST UTME':
        return 'ESUT';
      case 'PRIMARY SCHOOL LEAVING CERTIFICATE':
        return 'PSLC';
      case 'Scratch Examination':
        return 'SCE';
      case 'Nationwide Common Entrance Examination':
        return 'NCEE';
      default:
        return 'UNKNOWN';
    }
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
