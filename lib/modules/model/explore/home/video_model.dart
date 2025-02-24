class Video {
  final String title;
  final String url;
  final String thumbnail;
  final String author;

  Video({
    required this.title,
    required this.url,
    required this.thumbnail,
    required this.author,
  });
  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      author: json['author'] ?? '',
    );
  }
}