class Feed {
  final int id;
  final String title;
  late String content;
  final int parentId;
  final String authorName;
  final int authorId;
  final List<Feed> replies;
  final String type;
  final String createdAt;

  Feed({
    required this.id,
    required this.title,
    required this.content,
    required this.parentId,
    required this.authorName,
    required this.authorId,
    required this.replies,
    required this.type,
    required this.createdAt,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      parentId: json['parent_id'] ?? 0,
      authorName: json['author_name'] ?? '',
      authorId: json['author_id'] ?? 0,
      type: json['type']?.toString() ?? '',
      createdAt: json['created_at'] ?? '',
      replies: (json['replies'] as List?)
              ?.map((r) => Feed.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'parent_id': parentId,
      'author_name': authorName,
      'author_id': authorId,
      'type': type,
      'created_at': createdAt,
      'replies': replies.map((r) => r.toJson()).toList(),
    };
  }
}

class SchoolOverview {
  final int students;
  final int staff;
  final int classes;
  final int levels;

  SchoolOverview({
    required this.students,
    required this.staff,
    required this.classes,
    required this.levels,
  });

  factory SchoolOverview.fromJson(Map<String, dynamic> json) {
    return SchoolOverview(
      students: json['students'] ?? 0,
      staff: json['staff'] ?? 0,
      classes: json['classes'] ?? 0,
      levels: json['levels'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'students': students,
      'staff': staff,
      'classes': classes,
      'levels': levels,
    };
  }
}

class DashboardData {
  final SchoolOverview overview;
  final List<Feed> feeds;

  DashboardData({
    required this.overview,
    required this.feeds,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final totals = json['totals'] as Map<String, dynamic>? ?? {};
    final feedsData = json['feeds'] as Map<String, dynamic>? ?? {};

    final news = (feedsData['news'] as List?)
            ?.map((item) => Feed.fromJson(item))
            .toList() ??
        [];
    final questions = (feedsData['questions'] as List?)
            ?.map((item) => Feed.fromJson(item))
            .toList() ??
        [];

    return DashboardData(
      overview: SchoolOverview.fromJson(totals),
      feeds: [...news, ...questions],
    );
  }
}