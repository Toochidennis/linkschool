import 'package:linkschool/modules/model/explore/courses/course_model.dart';

class CategoryModel {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final List<CourseModel> courses;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.courses,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final int idVal = json['program_id'] ?? json['id'] ?? 0;

    return CategoryModel(
      id: idVal,
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      imageUrl: json['image_url'],
      courses: (json['courses'] as List<dynamic>?)
              ?.map((item) => CourseModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'program_id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'courses': courses.map((course) => course.toJson()).toList(),
    };
  }
}
