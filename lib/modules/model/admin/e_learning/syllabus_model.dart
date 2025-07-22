class Syllabus {
  final String? id;
  final String title;
  final String description;
  final String image;
  final String imageName;
  final String courseId;
  final String levelId;
  final List<Class> classes;
  final String creatorRole;
  final String term;
  final String year;

  Syllabus({
    this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.imageName,
    required this.courseId,
    required this.levelId,
    required this.classes,
    required this.creatorRole,
    required this.term,
    required this.year,
  });

  factory Syllabus.fromJson(Map<String, dynamic> json) {
    return Syllabus(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      imageName: json['image_name'],
      courseId: json['course_id'],
      levelId: json['level_id'],
      classes: (json['classes'] as List)
          .map((classJson) => Class.fromJson(classJson))
          .toList(),
      creatorRole: json['creator_role'],
      term: json['term'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'image': image,
      'image_name': imageName,
      'course_id': courseId,
      'level_id': levelId,
      'classes': classes.map((classObj) => classObj.toJson()).toList(),
      'creator_role': creatorRole,
      'term': term,
      'year': year,
    };
  }
}

class Class {
  final String id;
  final String className;

  Class({
    required this.id,
    required this.className,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['id'],
      className: json['className'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'className': className,
    };
  }
}