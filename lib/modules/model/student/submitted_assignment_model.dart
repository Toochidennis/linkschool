class SubmittedAssignmentFile {
  final String fileName;
  final String type; // e.g. pdf, image, doc
  final String? file; // base64 string
  final String old_fileName;

  SubmittedAssignmentFile({
    required this.fileName,
    required this.type,
    this.file,
    required this.old_fileName,
  });

  Map<String, dynamic> toJson() {
    return {
      'file_name': fileName,
      'type': type,
      'file': file,
      'old_fileName': old_fileName,
    };
  }

  factory SubmittedAssignmentFile.fromJson(Map<String, dynamic> json) {
    return SubmittedAssignmentFile(
      fileName: json['file_name'],
      type: json['type'],
      file: json['file'],
      old_fileName: json['old_file_name'],
    );
  }
}

class MarkedAssignmentModel {
  final List<SubmittedAssignmentFile> files;
  final String? marking_score;
  final String? score;
  final String? date;

  MarkedAssignmentModel({
    required this.marking_score,
    required this.score,
    required this.date,
    required this.files,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'files': files.map((f) => f.toJson()).toList(),
      'marking_score': marking_score,
      'score': score,
    };
  }

  factory MarkedAssignmentModel.fromJson(Map<String, dynamic> json) {
    return MarkedAssignmentModel(
      files: (json['files'] as List)
          .map((f) => SubmittedAssignmentFile.fromJson(f))
          .toList(),
      marking_score: json['marking_score'],
      score: json['score'],
      date: json['date'],
    );
  }
}
