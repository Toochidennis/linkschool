class Book {
  final int id;
  final String title;
  final String author;
  final String thumbnail;
  final String introduction;
  final List<String> categories;
  final Map<String, String> chapters;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.thumbnail,
    required this.introduction,
    required this.categories,
    required this.chapters,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      introduction: json['introduction'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      chapters: Map<String, String>.from(json['chapters'] ?? {}),
    );
  }

  // Add empty constructor
  factory Book.empty() {
    return Book(
      id: 0,
      title: '',
      author: '',
      thumbnail: '',
      introduction: '',
      categories: [],
      chapters: {},
    );
  }
}

// class Book {
//   final int id;
//   final String title;
//   final String author;
//   final String thumbnail;
//   final String introduction;
//   final List<String> categories;
//   final Map<String, String> chapters;

//   Book({
//     required this.id,
//     required this.title,
//     required this.author,
//     required this.thumbnail,
//     required this.introduction,
//     required this.categories,
//     required this.chapters,
//   });

//   factory Book.fromJson(Map<String, dynamic> json) {
//     return Book(
//       id: json['id'] ?? 0,
//       title: json['title'] ?? '',
//       author: json['author'] ?? '',
//       thumbnail: json['thumbnail'] ?? '',
//       introduction: json['introduction'] ?? '',
//       categories: List<String>.from(json['categories'] ?? []),
//       chapters: Map<String, String>.from(json['chapters'] ?? {}),
//     );
//   }
// }
