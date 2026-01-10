class AssignmentResponse {
  final int statusCode;
  final bool success;
  final AssignmentData response;

  AssignmentResponse({
    required this.statusCode,
    required this.success,
    required this.response,
  });

  factory AssignmentResponse.fromJson(Map<String, dynamic> json) {
    return AssignmentResponse(
      statusCode: json['statusCode'] ?? 0,
      success: json['success'] ?? false,
      response: AssignmentData.fromJson(json['response'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'success': success,
        'response': response.toJson(),
      };
}

class AssignmentData {
  final List<Assignment> submitted;
  final List<Assignment> unmarked;
  final List<Assignment> marked;

  AssignmentData({
    required this.submitted,
    required this.unmarked,
    required this.marked,
  });

  factory AssignmentData.fromJson(Map<String, dynamic> json) {
    return AssignmentData(
      submitted: (json['submitted'] as List<dynamic>?)
              ?.map((e) => Assignment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      unmarked: (json['unmarked'] as List<dynamic>?)
              ?.map((e) => Assignment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      marked: (json['marked'] as List<dynamic>?)
              ?.map((e) => Assignment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'submitted': submitted.map((e) => e.toJson()).toList(),
        'unmarked': unmarked.map((e) => e.toJson()).toList(),
        'marked': marked.map((e) => e.toJson()).toList(),
      };
}

class Assignment {
  final int id;
  final int contentId;
  final int studentId;
  final String studentName;
  final List<AssignmentFile> files;
  final String markingScore;
  final String score;
  final String date;

  Assignment({
    required this.id,
    required this.contentId,
    required this.studentId,
    required this.studentName,
    required this.files,
    required this.markingScore,
    required this.score,
    required this.date,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] ?? 0,
      contentId: json['content_id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      studentName: json['student_name'] ?? '',
      files: (json['files'] as List<dynamic>?)?.map((e) {
            if (e is Map<String, dynamic>) {
              return AssignmentFile.fromJson(e);
            } else if (e is AssignmentFile) {
              return e;
            } else {
              throw Exception('Invalid type in files list: ${e.runtimeType}');
            }
          }).toList() ??
          [],
      markingScore: json['marking_score'] ?? '',
      score: json['score'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content_id': contentId,
        'student_id': studentId,
        'student_name': studentName,
        'files': files.map((e) => e.toJson()).toList(),
        'marking_score': markingScore,
        'score': score,
        'date': date,
      };
}

class AssignmentFile {
  final String fileName;
  final String type;
  final String oldFileName;
  final String file;

  AssignmentFile({
    required this.fileName,
    required this.type,
    required this.oldFileName,
    required this.file,
  });

  factory AssignmentFile.fromJson(Map<String, dynamic> json) {
    return AssignmentFile(
      fileName: json['file_name'] ?? '',
      type: json['type'] ?? '',
      oldFileName: json['old_file_name'] ?? '',
      file: json['file'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'file_name': fileName,
        'type': type,
        'old_file_name': oldFileName,
        'file': file,
      };
}
