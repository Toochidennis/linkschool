class StreamsModel {
  final int id;
  final String title;
  final String type;
  final List<Commentinfo> comments;

  StreamsModel({
    required this.id,
    required this.title,
    required this.type,
    required this.comments,
  });

  factory StreamsModel.fromJson(Map<String, dynamic> json) {
    return StreamsModel(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      comments: (json['comments'] as List)
          .map((comment) => Commentinfo.fromJson(comment))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }
}

class Commentinfo {
  final int id;
  final String contentId;
  final String contentTitle;
  final String levelId;
  final int courseId;
  final String courseName;
  final String term;
  final int authorId;
  final String authorName;
  final String comment;
  final String uploadDate;

  Commentinfo({
    required this.id,
    required this.contentId,
    required this.contentTitle,
    required this.levelId,
    required this.courseId,
    required this.courseName,
    required this.term,
    required this.authorId,
    required this.authorName,
    required this.comment,
    required this.uploadDate,
  });

  factory Commentinfo.fromJson(Map<String, dynamic> json) {
    return Commentinfo(
      id: json['id'],
      contentId: json['content_id'],
      contentTitle: json['content_title'],
      levelId: json['level_id'],
      courseId: json['course_id'],
      courseName: json['course_name'],
      term: json['term'],
      authorId: json['author_id'],
      authorName: json['author_name'],
      comment: json['comment'],
      uploadDate: json['upload_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content_id': contentId,
      'content_title': contentTitle,
      'level_id': levelId,
      'course_id': courseId,
      'course_name': courseName,
      'term': term,
      'author_id': authorId,
      'author_name': authorName,
      'comment': comment,
      'upload_date': uploadDate,
    };
  }
}
