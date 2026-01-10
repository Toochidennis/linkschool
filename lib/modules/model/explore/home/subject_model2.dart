import 'category_model.dart';

class SubjectModel2 {
  final int id;
  final String name;
  final List<Category> categories;

  SubjectModel2({
    required this.id,
    required this.name,
    required this.categories,
  });

  factory SubjectModel2.fromJson(Map<String, dynamic> json) {
    return SubjectModel2(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      categories: (json['category'] as List<dynamic>)
          .map((category) => Category.fromJson(category))
          .toList(),
    );
  }
}
