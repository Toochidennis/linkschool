import 'category_model.dart';


class SubjectModel2 {
  final String id;
  final String name;
  final List<Category> categories;

  SubjectModel2({required this.id, required this.name, required this.categories});

  factory SubjectModel2.fromJson(Map<String, dynamic> json) {
    return SubjectModel2(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      categories: (json['category'] as List)
          .map((category) => Category.fromJson(category))
          .toList(),
    );
  }
}