class SyllabusModel {
  final int id;
  final String title;
  final String description;
  final String authorName;
  final String term;
  final String uploadDate; // This exists in JSON
  final List<ClassModel> classes;
  
  // Optional fields that may not exist in all responses
  final String? courseId;
  final String? courseName;
  final String? levelId;
  final String? creatorId;

  SyllabusModel({
    required this.id,
    required this.title,
    required this.description,
    required this.authorName,
    required this.term,
    required this.uploadDate,
    required this.classes,
    this.courseId,
    this.courseName,
    this.levelId,
    this.creatorId,
  });

  factory SyllabusModel.fromJson(Map<String, dynamic> json) {
    return SyllabusModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      authorName: json['author_name'] as String? ?? '',
      term: json['term'] as String? ?? '',
      uploadDate: json['upload_date'] as String? ?? '',
      classes: (json['classes'] as List? ?? [])
          .map((classJson) => ClassModel.fromJson(classJson))
          .toList(),
      // Optional fields with null safety
      courseId: json['course_id'] as String?,
      courseName: json['course_name'] as String?,
      levelId: json['level_id'] as String?,
      creatorId: json['creator_id'] as String?,
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
      if (courseId != null) 'course_id': courseId,
      if (courseName != null) 'course_name': courseName,
      if (levelId != null) 'level_id': levelId,
      if (creatorId != null) 'creator_id': creatorId,
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
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
