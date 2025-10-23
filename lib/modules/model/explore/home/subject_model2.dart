class SubjectModel2 {
  final String id;
  final String title;
  final String description;
  final List<String> genres;
  final String posterPortrait;
  final String posterLandscape;
  final String videoUrl;

  SubjectModel2({
    required this.id,
    required this.title,
    required this.description,
    required this.genres,
    required this.posterPortrait,
    required this.posterLandscape,
    required this.videoUrl,
  });

  factory SubjectModel2.fromJson(Map<String, dynamic> json) {
    return SubjectModel2(
      id: json['id'].toString(), // Convert int → String safely
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      genres: (json['genres'] as List?)?.map((g) => g.toString()).toList() ?? [],
      posterPortrait: json['poster_portrait'] ?? '',
      posterLandscape: json['poster_landscape'] ?? '',
      videoUrl: json['video_url'] ?? '',
    );
  }
}
