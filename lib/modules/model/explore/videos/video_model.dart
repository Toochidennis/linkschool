class VideoModel {
  final String title;
  final int? topicId;
  final String? topicName;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final String authorName;

  VideoModel({
    required this.title,
    this.topicId,
    this.topicName,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.authorName,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      title: json['title'] ?? '',
      topicId: json['topic_id'],
      topicName: json['topic_name'],
      description: json['description'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      authorName: json['author_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'topic_id': topicId,
      'topic_name': topicName,
      'description': description,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'author_name': authorName,
    };
  }
}

class SyllabusModel {
  final int syllabusId;
  final String syllabusName;
  final List<VideoModel> videos;

  SyllabusModel({
    required this.syllabusId,
    required this.syllabusName,
    required this.videos,
  });

  factory SyllabusModel.fromJson(Map<String, dynamic> json) {
    return SyllabusModel(
      syllabusId: json['syllabus_id'] ?? 0,
      syllabusName: json['syllabus_name'] ?? '',
      videos: (json['videos'] as List<dynamic>?)
              ?.map((video) => VideoModel.fromJson(video))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'syllabus_id': syllabusId,
      'syllabus_name': syllabusName,
      'videos': videos.map((v) => v.toJson()).toList(),
    };
  }
}

class CourseVideoModel {
  final int courseId;
  final String courseName;
  final List<SyllabusModel> syllabi;

  CourseVideoModel({
    required this.courseId,
    required this.courseName,
    required this.syllabi,
  });

  factory CourseVideoModel.fromJson(Map<String, dynamic> json) {
    return CourseVideoModel(
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name'] ?? '',
      syllabi: (json['syllabi'] as List<dynamic>?)
              ?.map((syllabus) => SyllabusModel.fromJson(syllabus))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'course_name': courseName,
      'syllabi': syllabi.map((s) => s.toJson()).toList(),
    };
  }

  // Get total video count for this course
  int get totalVideos {
    return syllabi.fold(0, (sum, syllabus) => sum + syllabus.videos.length);
  }
}

class CourseVideosResponseModel {
  final int statusCode;
  final bool success;
  final List<CourseVideoModel> courses;

  CourseVideosResponseModel({
    required this.statusCode,
    required this.success,
    required this.courses,
  });

  factory CourseVideosResponseModel.fromJson(Map<String, dynamic> json) {
    return CourseVideosResponseModel(
      statusCode: json['statusCode'] ?? 200,
      success: json['success'] ?? false,
      courses: (json['data'] as List<dynamic>?)
              ?.map((course) => CourseVideoModel.fromJson(course))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'success': success,
      'data': courses.map((c) => c.toJson()).toList(),
    };
  }
}