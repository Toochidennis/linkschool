class Video {
  final String? id;
  final String title;
  final String url;
  final String thumbnail;
  final String? author;

  Video({
    this.id,
    required this.title,
    required this.url,
    required this.thumbnail,
    this.author,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      author: json['author'] ?? '',
    );
  }

  // Add empty constructor
  factory Video.empty() {
    return Video(
      id: '',
      title: '',
      url: '',
      thumbnail: '',
      author: '',
    );
  }
}


// class Video {
//   final String? id;
//   final String title;
//   final String url;
//   final String thumbnail;
//   final String? author;

//   Video({
//     this.id,
//     required this.title,
//     required this.url,
//     required this.thumbnail,
//     this.author,
//   });
//   factory Video.fromJson(Map<String, dynamic> json) {
//     return Video(
//       id: json['id'] ?? '',
//       title: json['title'] ?? '',
//       url: json['url'] ?? '',
//       thumbnail: json['thumbnail'] ?? '',
//       author: json['author'] ?? '',
//     );
//   }
// }