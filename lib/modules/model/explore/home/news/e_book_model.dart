// BookModel.dart
class BookModel {
  final int id;
  final String title;
  final String author;
  final String thumbnail;
  final String introduction;
  final List<String> categories; // Instance member
  final Map<String, String> chapters;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.thumbnail,
    required this.introduction,
    required this.categories,
    required this.chapters,
  });

  // Convert a BookModel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'thumbnail': thumbnail,
      'introduction': introduction,
      'categories': categories,
      'chapters': chapters,
    };
  }

  // Create a BookModel instance from a JSON map
  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
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

class BookResponse {
  final List<String> categories;
  final List<BookModel> books;

  BookResponse({
    required this.categories,
    required this.books,
  });

  // Convert a BookResponse instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'categories': categories,
      'books': books.map((book) => book.toJson()).toList(),
    };
  }

  // Create a BookResponse instance from a JSON map
  factory BookResponse.fromJson(Map<String, dynamic> json) {
    return BookResponse(
      categories: List<String>.from(json['categories']),
      books: List<BookModel>.from(
        json['books'].map((book) => BookModel.fromJson(book)),
      ),
    );
  }
}
