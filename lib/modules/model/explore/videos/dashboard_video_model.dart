class DashboardVideoModel {
  final int id;
  final String title;
  final String description;
  final String videoUrl;
  final String? thumbnailUrl;
  final int courseId;
  final int levelId;
  final String courseName;
  final String levelName;
  final String syllabusName;
  final int syllabusId;
  final String? topicName;
  final int? topicId;
  final String authorName;

  DashboardVideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.courseId,
    required this.levelId,
    required this.courseName,
    required this.levelName,
    required this.syllabusName,
    required this.syllabusId,
    this.topicName,
    this.topicId,
    required this.authorName,
  });

  factory DashboardVideoModel.fromJson(Map<String, dynamic> json) {
    return DashboardVideoModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      courseId: json['course_id'] ?? 0,
      levelId: json['level_id'] ?? 0,
      courseName: json['course_name'] ?? '',
      levelName: json['level_name'] ?? '',
      syllabusName: json['syllabus_name'] ?? '',
      syllabusId: json['syllabus_id'] ?? 0,
      topicName: json['topic_name'],
      topicId: json['topic_id'],
      authorName: json['author_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'course_id': courseId,
      'level_id': levelId,
      'course_name': courseName,
      'level_name': levelName,
      'syllabus_name': syllabusName,
      'syllabus_id': syllabusId,
      'topic_name': topicName,
      'topic_id': topicId,
      'author_name': authorName,
    };
  }
}

class DashboardCourseModel {
  final int id;
  final String courseName;
  final String? description;

  DashboardCourseModel({
    required this.id,
    required this.courseName,
    this.description,
  });

  factory DashboardCourseModel.fromJson(Map<String, dynamic> json) {
    return DashboardCourseModel(
      id: json['id'] ?? 0,
      courseName: json['course_name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_name': courseName,
      'description': description,
    };
  }
}

class DashboardDataModel {
  final List<DashboardVideoModel> recommended;
  final List<DashboardCourseModel> courses;

  DashboardDataModel({
    required this.recommended,
    required this.courses,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardDataModel(
      recommended: (json['recommended'] as List<dynamic>?)
              ?.map((video) => DashboardVideoModel.fromJson(video))
              .toList() ??
          [],
      courses: (json['courses'] as List<dynamic>?)
              ?.map((course) => DashboardCourseModel.fromJson(course))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommended': recommended.map((v) => v.toJson()).toList(),
      'courses': courses.map((c) => c.toJson()).toList(),
    };
  }
}

class DashboardResponseModel {
  final int statusCode;
  final bool success;
  final DashboardDataModel data;

  DashboardResponseModel({
    required this.statusCode,
    required this.success,
    required this.data,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) {
    return DashboardResponseModel(
      statusCode: json['statusCode'] ?? 200,
      success: json['success'] ?? false,
      data: DashboardDataModel.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'success': success,
      'data': data.toJson(),
    };
  }
}
