class LessonModel {
  final int id;
  final int courseId;
  final String courseName;
  final String title;
  final String goal;
  final String objectives;
  final String description;
  final String assignmentDescription;
  final String assignmentUrl;
  final String materialUrl;
  final String videoUrl;
  final String? readingUrl;
  final int hasQuiz;
  final int isFinal;
  final String zoomUrl;
  final String recordedUrl;
  final String date;

  LessonModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.title,
    required this.goal,
    required this.objectives,
    required this.description,
    required this.assignmentDescription,
    required this.assignmentUrl,
    required this.materialUrl,
    required this.videoUrl,
    required this.readingUrl,
    required this.hasQuiz,
    required this.isFinal,
    required this.zoomUrl,
    required this.recordedUrl,
    required this.date,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name'] ?? '',
      title: json['title'] ?? '',
      goal: json['goal'] ?? '',
      objectives: json['objectives'] ?? '',
      description: json['description'] ?? '',
      assignmentDescription: json['assignment_description'] ?? '',
      assignmentUrl: json['assignment_url'] ?? '',
      materialUrl: json['material_url'] ?? '',
      videoUrl: json['video_url'] ?? '',
    readingUrl: json['reading_url']?.toString() ?? '',
      hasQuiz: json['has_quiz'] ?? 0,
      isFinal: json['is_final'] ?? 0,
      zoomUrl: json['zoom_url'] ?? '',
      recordedUrl: json['recorded_url'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'course_name': courseName,
      'title': title,
      'goal': goal,
      'objectives': objectives,
      'description': description,
      'assignment_description': assignmentDescription,
      'assignment_url': assignmentUrl,
      'material_url': materialUrl,
      'video_url': videoUrl,
      'reading_url': readingUrl,
      'has_quiz': hasQuiz,
      'is_final': isFinal,
      'zoom_url': zoomUrl,
      'recorded_url': recordedUrl,
      'date': date,
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
      lessons: (json['data']?['lessons'] as List<dynamic>?)
              ?.map((lesson) => LessonModel.fromJson(lesson))
              .toList() ??
          [],
      resources: (json['data']?['resources'] as List<dynamic>?)
              ?.map((resource) => ResourceModel.fromJson(resource))
              .toList() ??
          [],
    );
  }
}