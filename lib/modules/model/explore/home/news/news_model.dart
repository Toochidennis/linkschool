class NewsModel {
  final int id;
  final String title;
  final String content;
  final String date_posted;
  final String image_url;
  final dynamic user_like;
  final dynamic likes;
  final List<Comment> comments;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date_posted,
    required this.image_url,
    required this.user_like,
    required this.likes,
    required this.comments,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    var commentList = json['comments'] as List;
    List<Comment> comments =
        commentList.map((c) => Comment.fromJson(c)).toList();

    // factory NewsModel.fromJson(List<dynamic> json) {
    return NewsModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      content: json['content'] ?? "",
      date_posted: json['date_posted'] ?? "no date",
      image_url: json['image_url'] ?? "",
      user_like: json['user_like'] ?? 0,
      likes: json['likes'] ?? 0,
      comments: (json['comments'] as List<dynamic>?)
              ?.map((comment) => Comment.fromJson(comment))
              .toList() ??
          [],
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