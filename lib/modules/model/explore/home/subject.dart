class Subject {
  final String id;
  final String name;
  final List<Category> categories;

  Subject({required this.id, required this.name, required this.categories});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      categories: (json['category'] as List)
          .map((category) => Category.fromJson(category))
          .toList(),
    );
  }
}

class Category {
  final String id;
  final String level;
  final String levelName;
  final String name;
  final List<Video> videos;

  Category({
    required this.id,
    required this.level,
    required this.levelName,
    required this.name,
    required this.videos,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      level: json['level'],
      levelName: json['level_name'],
      name: json['name'],
      videos: (json['videos'] as List)
          .map((video) => Video.fromJson(video))
          .toList(),
    );
  }
}

class Video {
  final String id;
  final String title;
  final String url;
  final String thumbnail;

  Video({
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnail,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      thumbnail: json['thumbnail'],
    );
  }
}