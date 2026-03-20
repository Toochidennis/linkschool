class UpcomingCohortProgramModel {
  final int id;
  final String slug;
  final String name;
  final String? sponsor;
  final String? videoUrl;
  final String? onboardingSteps;
  final String? whatsappGroupLink;

  UpcomingCohortProgramModel({
    required this.id,
    required this.slug,
    required this.name,
    this.sponsor,
    this.videoUrl,
    this.onboardingSteps,
    this.whatsappGroupLink,
  });

  factory UpcomingCohortProgramModel.fromJson(Map<String, dynamic> json) {
    return UpcomingCohortProgramModel(
      id: json['id'] ?? 0,
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      sponsor: json['sponsor']?.toString(),
      videoUrl: json['video_url']?.toString(),
      onboardingSteps: json['onboarding_steps']?.toString(),
      whatsappGroupLink: json['whatsapp_group_link']?.toString(),
    );
  }
}

class UpcomingCohortCourseModel {
  final int courseId;
  final String slug;
  final String courseName;
  final String description;
  final String imageUrl;

  UpcomingCohortCourseModel({
    required this.courseId,
    required this.slug,
    required this.courseName,
    required this.description,
    required this.imageUrl,
  });

  factory UpcomingCohortCourseModel.fromJson(Map<String, dynamic> json) {
    return UpcomingCohortCourseModel(
      courseId: json['courseId'] ?? json['course_id'] ?? 0,
      slug: json['slug'] ?? '',
      courseName: json['courseName'] ?? json['course_name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class UpcomingCohortItemModel {
  final int cohortId;
  final String slug;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String? instructorName;
  final String deliveryMode;
  final String? videoUrl;
  final String? imageUrl;
  final String learningType;
  final String? whatsappGroupLink;
  final bool isEnrolled;

  UpcomingCohortItemModel({
    required this.cohortId,
    required this.slug,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.instructorName,
    required this.deliveryMode,
    this.videoUrl,
    this.imageUrl,
    required this.learningType,
    this.whatsappGroupLink,
    required this.isEnrolled,
  });

  factory UpcomingCohortItemModel.fromJson(Map<String, dynamic> json) {
    return UpcomingCohortItemModel(
      cohortId: json['cohortId'] ?? json['cohort_id'] ?? 0,
      slug: json['slug'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      instructorName: json['instructor_name']?.toString(),
      deliveryMode: json['delivery_mode'] ?? '',
      videoUrl: json['video_url']?.toString(),
      imageUrl: json['image_url']?.toString(),
      learningType: json['learning_type'] ?? '',
      whatsappGroupLink: json['whatsapp_group_link']?.toString(),
      isEnrolled: json['is_enrolled'] == true || json['is_enrolled'] == 1,
    );
  }
}

class UpcomingCohortDataModel {
  final UpcomingCohortProgramModel program;
  final UpcomingCohortCourseModel course;
  final UpcomingCohortItemModel cohort;

  UpcomingCohortDataModel({
    required this.program,
    required this.course,
    required this.cohort,
  });

  factory UpcomingCohortDataModel.fromJson(Map<String, dynamic> json) {
    return UpcomingCohortDataModel(
      program: UpcomingCohortProgramModel.fromJson(
        Map<String, dynamic>.from(json['program'] ?? const {}),
      ),
      course: UpcomingCohortCourseModel.fromJson(
        Map<String, dynamic>.from(json['course'] ?? const {}),
      ),
      cohort: UpcomingCohortItemModel.fromJson(
        Map<String, dynamic>.from(json['cohort'] ?? const {}),
      ),
    );
  }
}

class UpcomingCohortResponseModel {
  final int statusCode;
  final bool success;
  final String message;
  final UpcomingCohortDataModel? data;

  UpcomingCohortResponseModel({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory UpcomingCohortResponseModel.fromJson(Map<String, dynamic> json) {
    return UpcomingCohortResponseModel(
      statusCode: json['statusCode'] ?? 200,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? UpcomingCohortDataModel.fromJson(
              Map<String, dynamic>.from(json['data']),
            )
          : null,
    );
  }
}
