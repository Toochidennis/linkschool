class AssignmentFile {
  final String? fileName;
  final String type; // e.g. pdf, image, doc
  final String file; // base64 string

  AssignmentFile({
     this.fileName,
    required this.type,
    required this.file,
  });

  Map<String, dynamic> toJson() {
    return {
      'file_name': fileName,
      'type': type,
      'file': file,
    };
  }

  factory AssignmentFile.fromJson(Map<String, dynamic> json) {
    return AssignmentFile(
      fileName: json['file_name'],
      type: json['type'],
      file: json['file'],
    );
  }
}

class AssignmentSubmission {
  final int assignmentId;
  final int studentId;
  final String studentName;
  final List<AssignmentFile> files;
  final int? mark;
  final int? score;
  final int levelId;
  final int courseId;
  final int classId;
  final String courseName;
  final String className;
  final int term;
  final int year;
  final String db;

  AssignmentSubmission({
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.files,
     this.mark,
     this.score,
    required this.levelId,
    required this.courseId,
    required this.classId,
    required this.courseName,
    required this.className,
    required this.term,
    required this.year,
    required this.db,
  });

  Map<String, dynamic> toJson() {
    return {
      'assignment_id': assignmentId,
      'student_id': studentId,
      'student_name': studentName,
      'files': files.map((f) => f.toJson()).toList(),
      'mark': mark,
      'score': score,
      'level_id': levelId,
      'course_id': courseId,
      'class_id': classId,
      'course_name': courseName,
      'class_name': className,
      'term': term,
      'year': year,
      '_db': db,
    };
  }

  factory AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmission(
      assignmentId: json['assignment_id'],
      studentId: json['student_id'],
      studentName: json['student_name'],
      files: (json['files'] as List)
          .map((f) => AssignmentFile.fromJson(f))
          .toList(),
      mark: json['mark'],
      score: json['score'],
      levelId: json['level_id'],
      courseId: json['course_id'],
      classId: json['class_id'],
      courseName: json['course_name'],
      className: json['class_name'],
      term: json['term'],
      year: json['year'],
      db: json['_db'],
    );
  }
}
