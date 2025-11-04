class StaffSyllabusModel {
  final int? id;
  final String title;
  final String description;
  final String? authorName;
  final String? term;
  final String? uploadDate;
  final List<ClassModel> classes;
  final int? courseId; // Changed to int
  final String? courseName;
  final int? levelId; // Changed to int
  final int? creatorId; // Changed to int

  StaffSyllabusModel({
    this.id,
    required this.title,
    required this.description,
    this.authorName,
    required this.term,
    this.uploadDate,
    required this.classes,
    this.courseId,
    this.courseName,
    this.levelId,
    this.creatorId,
  });

  factory StaffSyllabusModel.fromJson(Map<String, dynamic> json) {
    return StaffSyllabusModel(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      authorName: json['author_name'] as String? ?? '',
      term: json['term']?.toString() ?? '', // Ensure string conversion
      uploadDate: json['upload_date'] as String? ?? '',
      classes: (json['classes'] as List? ?? [])
          .map((classJson) => ClassModel.fromJson(classJson))
          .toList(),
      courseId: json['course_id'] as int?,
      courseName: json['course_name'] as String?,
      levelId: json['level_id'] as int?,
      creatorId: json['creator_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author_name': authorName,
      'term': term,
      'upload_date': uploadDate,
      'classes': classes.map((classItem) => classItem.toJson()).toList(),
      'course_id': courseId,
      'course_name': courseName,
      'level_id': levelId,
      'creator_id': creatorId,
    };
  }
}

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
