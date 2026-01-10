class StudentComment {
  final String? contentTitle;
  int? id; // Assuming id is an integer, adjust if it's a string
  final int? userId;
  final String? userName;
  final String text; // Maps to "comment" in JSON
  final String? levelId;
  final String? courseId;
  final String? courseName;
  final int? term;
  final DateTime date;
  final String author; // For UI display (maps to userName)

  StudentComment({
    this.contentTitle,
    this.userId,
    this.id,
    this.userName,
    required this.text,
    this.levelId,
    this.courseId,
    this.courseName,
    this.term,
    required this.date,
    required this.author,
  });

  // Factory to create Comment from JSON (if API returns the comment)
  factory StudentComment.fromJson(Map<String, dynamic> json) {
    return StudentComment(
      contentTitle: json['content_title'] as String?,
      id: json['id'] as int?,
      userId: json['author_id'] as int?, // mapped from author_id
      userName: json['author_name'] as String?,
      // mapped from author_name
      text: json['comment'] ?? '',
      levelId: json['level_id']?.toString(),
      courseId: json['course_id']?.toString(),
      courseName: json['course_name'] as String?,
      term: json['term'] is int
          ? json['term']
          : int.tryParse(json['term']?.toString() ?? ''),
      date: DateTime.tryParse(json['upload_date'] ?? '') ?? DateTime.now(),
      author: json['author_name'] ?? 'Unknown', // For UI display
    );
  }
}
