class NewsModel {
  final int id;
  final String title;
  final String content;
  final String date_posted;
  final String author_name;
  final int author_id;
  final String status;
  final int recommended;
  final List<NewsImage> images;
  final String created_at;
  final String? updated_at;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date_posted,
    required this.author_name,
    required this.author_id,
    required this.status,
    required this.recommended,
    required this.images,
    required this.created_at,
    this.updated_at,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      content: json['content'] ?? "",
      date_posted: json['date_posted'] ?? "no date",
      author_name: json['author_name'] ?? "Unknown",
      author_id: json['author_id'] ?? 0,
      status: json['status'] ?? "draft",
      recommended: json['recommended'] ?? 0,
      images: (json['images'] as List<dynamic>?)
              ?.map((image) => NewsImage.fromJson(image))
              .toList() ??
          [],
      created_at: json['created_at'] ?? "",
      updated_at: json['updated_at'],
    );
  }

  // Get first image URL or return empty string
  String get imageUrl {
    if (images.isNotEmpty && images[0].file_name.isNotEmpty) {
      return 'https://linkskool.net/${images[0].file_name}';
    }
    return '';
  }
}

class NewsImage {
  final String file_name;
  final String old_file_name;
  final String type;
  final String file;

  NewsImage({
    required this.file_name,
    required this.old_file_name,
    required this.type,
    required this.file,
  });

  factory NewsImage.fromJson(Map<String, dynamic> json) {
    return NewsImage(
      file_name: json['file_name'] ?? "",
      old_file_name: json['old_file_name'] ?? "",
      type: json['type'] ?? "image",
      file: json['file'] ?? "",
    );
  }
}

class Comment {
  final int userId;
  final String name;
  final String comment;
  final String date;

  Comment(
      {required this.userId,
      required this.name,
      required this.comment,
      required this.date});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? "no name",
      comment: json['comment'] ?? "no comment",
      date: json['date'] ?? "no date",
    );
  }
}
