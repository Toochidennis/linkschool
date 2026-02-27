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
  final NextCourseModel? nextCourse;

  LessonsResponseModel({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.lessons,
    required this.resources,
    this.nextCourse,
  });

  factory LessonsResponseModel.fromJson(Map<String, dynamic> json) {
    final lessonsJson = _extractLessonsList(json);
    final nextCourseJson = _extractNextCourse(json);
    return LessonsResponseModel(
      statusCode: json['statusCode'] ?? 200,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      lessons: lessonsJson
              ?.map((lesson) => LessonModel.fromJson(lesson))
              .toList() ??
          [],
      resources: [],
      nextCourse: nextCourseJson is Map<String, dynamic>
          ? NextCourseModel.fromJson(nextCourseJson)
          : null,
    );
  }
}

List<dynamic>? _extractLessonsList(Map<String, dynamic> json) {
  final direct = json['lessons'];
  if (direct is List) return direct;
  final data = json['data'];
  if (data is List) return data;
  if (data is Map<String, dynamic>) {
    final nested = data['lessons'];
    if (nested is List) return nested;
  }
  return null;
}

Map<String, dynamic>? _extractNextCourse(Map<String, dynamic> json) {
  final direct = json['next_course'];
  if (direct is Map<String, dynamic>) return direct;
  final data = json['data'];
  if (data is Map<String, dynamic>) {
    final nested = data['next_course'];
    if (nested is Map<String, dynamic>) return nested;
  }
  return null;
}

class NextCourseModel {
  final String id;
  final String courseName;
  final String description;
  final int? courseId;
  final String? image;
  final bool isEnrolled;

  NextCourseModel({
    required this.id,
    required this.courseName,
    required this.description,
    required this.courseId,
    required this.isEnrolled,
    required this.image,
  });

  factory NextCourseModel.fromJson(Map<String, dynamic> json) {
    final rawCourseId = json['course_id'];
    final rawImage = json['image'];
    final parsedCourseId = rawCourseId is int
        ? rawCourseId
        : int.tryParse(rawCourseId?.toString() ?? '');
    final rawIsEnrolled = json['is_enrolled'];
    final isEnrolled = rawIsEnrolled is bool
        ? rawIsEnrolled
        : rawIsEnrolled is num
            ? rawIsEnrolled == 1
            : rawIsEnrolled?.toString().toLowerCase() == 'true';
    return NextCourseModel(
      id: json['id']?.toString() ?? '',
      courseName: json['course_name'] ?? '',
      description: json['description'] ?? '',
      image: rawImage is String && rawImage.trim().isNotEmpty ? rawImage : null,
      courseId: parsedCourseId,
      isEnrolled: isEnrolled,
    );
  }
}
