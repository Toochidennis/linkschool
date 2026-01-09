class Video {
  final String? id;
  final String title;
  final String url;
  final String thumbnail;
  final String? author;
  final String? description;

  Video({
    this.id,
    required this.title,
    required this.url,
    required this.thumbnail,
    this.author,
      this.description,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id']?.toString(), // ✅ convert int -> String
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      author: json['author']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  factory Video.empty() {
    return Video(
      id: '',
      title: '',
      url: '',
      thumbnail: '',
      author: '',
      description: '',
    );
  }
}
