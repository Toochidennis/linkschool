class LessonModel {
  final int id;
  final String title;
  final String description;
  final String videoUrl;
  final int displayOrder;
  final int isFinalLesson;

  LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.displayOrder,
    required this.isFinalLesson,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['video_url'] ?? '',
      displayOrder: json['display_order'] ?? 0,
      isFinalLesson: json['is_final_lesson'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'display_order': displayOrder,
      'is_final_lesson': isFinalLesson,
    };
  }
}

class ResourceModel {
  final int id;
  final int lessonId;
  final String name;
  final String url;

  ResourceModel({
    required this.id,
    required this.lessonId,
    required this.name,
    required this.url,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id'] ?? 0,
      lessonId: json['lesson_id'] ?? 0,
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'name': name,
      'url': url,
    };
  }
}

class LessonsResponseModel {
  final int statusCode;
  final bool success;
  final String message;
  final List<LessonModel> lessons;
  final List<ResourceModel> resources;

  LessonsResponseModel({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.lessons,
    required this.resources,
  });

  factory LessonsResponseModel.fromJson(Map<String, dynamic> json) {
    return LessonsResponseModel(
      statusCode: json['statusCode'] ?? 200,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      lessons: (json['data'] as List<dynamic>?)
              ?.map((lesson) => LessonModel.fromJson(lesson))
              .toList() ??
          [],
      resources: [],
    );
  }
}