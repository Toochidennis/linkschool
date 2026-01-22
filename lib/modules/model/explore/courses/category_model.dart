import 'package:linkschool/modules/model/explore/courses/course_model.dart';

class CategoryModel {
  final int id;
  final String name;
  final String short;
  final int available;
  final int isFree;
  final int limit;
  final String startDate;
  final String endDate;
  final List<CourseModel> courses;

  CategoryModel({
    required this.id,
    required this.name,
    required this.short,
    required this.available,
    required this.isFree,
    required this.limit,
    required this.startDate,
    required this.endDate,
    required this.courses,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // support both 'program_id' and 'id'
    final int idVal = json['program_id'] ?? json['id'] ?? 0;

    return CategoryModel(
      id: idVal,
      name: json['name'] ?? "",
      short: json['short'] ?? "",
      available: json['available'] ?? 0,
      isFree: json['is_free'] ?? 0,
      limit: json['limit'] ?? 0,
      startDate: json['start_date'] ?? "",
      endDate: json['end_date'] ?? "",
      courses: (json['courses'] as List<dynamic>?)
              ?.map((item) => CourseModel.fromJson(item))
              .toList() ??
          [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short': short,
      'available': available,
      'is_free': isFree,
      'limit': limit,
      'start_date': startDate,
      'end_date': endDate,
      'courses': courses.map((course) => course.toJson()).toList(),
    };
  }

  // Check if category is free
  bool get isFreeCourse => isFree == 1;

  // Check if category is available
  bool get isAvailable => available == 1;

  // Get badge text
  String get badgeText => isFree == 1 ? 'Free' : 'Paid';
}
