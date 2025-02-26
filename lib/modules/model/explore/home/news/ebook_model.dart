class Ebook {
  final int id;
  final String title;
  final String author;
  final String thumbnail;
  final String introduction;
  final List<String> categories;
  final Map<String, String> chapters;

  Ebook({
    required this.id,
    required this.title,
    required this.author,
    required this.thumbnail,
    required this.introduction,
    required this.categories,
    required this.chapters,
  });

  factory Ebook.fromJson(Map<String, dynamic> json) {
    return Ebook(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      thumbnail: json['thumbnail'],
      introduction: json['introduction'],
      categories: List<String>.from(json['categories']),
      chapters: Map<String, String>.from(json['chapters']),
    );
  }
}
