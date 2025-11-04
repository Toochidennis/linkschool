class ClassModel {
  final String id;
  final String name;

  ClassModel({required this.id, required this.name});

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class RecentQuizModel {
  final int id;
  final int? syllabusId; // Made nullable
  final int? courseId; // Made nullable
  final String title;
  final String courseName;
  final String levelId;
  final List<ClassModel> classes;
  final String type;
  final int outline; // Kept for now, with default value
  final String createdBy;
  final String datePosted;

  RecentQuizModel({
    required this.id,
    this.syllabusId, // Nullable
    this.courseId, // Nullable
    required this.title,
    required this.courseName,
    required this.levelId,
    required this.classes,
    required this.type,
    required this.outline,
    required this.createdBy,
    required this.datePosted,
  });

  factory RecentQuizModel.fromJson(Map<String, dynamic> json) {
    return RecentQuizModel(
      id: json['id'] ?? 0, // Provide default if null
      syllabusId: json['syllabus_id'], // Nullable, no need for default
      courseId: json['course_id'], // Nullable, no need for default
      title: json['title'] ?? '',
      courseName: json['course_name'] ?? '',
      levelId: json['level_id'].toString(),
      classes: (json['classes'] as List<dynamic>?)
              ?.map((e) => ClassModel.fromJson(e))
              .toList() ??
          [],
      type: json['type'] ?? '',
      outline: json['outline'] ?? 0, // Default to 0 since field is missing
      createdBy: json['created_by'] ?? '',
      datePosted: json['date_posted'] ?? '',
    );
  }
}

class RecentActivityModel {
  final int id;
  final int? syllabusId; // Made nullable
  final int? courseId; // Made nullable
  final String levelId;
  final String title;
  final String comment;
  final String type;
  final List<ClassModel> classes;
  final String courseName;
  final String createdBy;
  final String datePosted;

  RecentActivityModel({
    required this.id,
    this.syllabusId, // Nullable
    this.courseId, // Nullable
    required this.levelId,
    required this.title,
    required this.comment,
    required this.type,
    required this.classes,
    required this.courseName,
    required this.createdBy,
    required this.datePosted,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      id: json['id'] ?? 0, // Provide default if null
      syllabusId: json['syllabus_id'], // Nullable, no need for default
      courseId: json['course_id'], // Nullable, no need for default
      levelId: json['level_id'].toString(),
      title: json['title'] ?? '',
      comment: json['comment'] ?? '',
      type: json['type'] ?? '',
      classes: (json['classes'] as List<dynamic>?)
              ?.map((e) => ClassModel.fromJson(e))
              .toList() ??
          [],
      courseName: json['course_name'] ?? '',
      createdBy: json['created_by'] ?? '',
      datePosted: json['date_posted'] ?? '',
    );
  }
}
