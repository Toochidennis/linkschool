import 'package:linkschool/modules/model/explore/courses/course_model.dart';

class ProgramCoursesResponseModel {
  final int statusCode;
  final bool success;
  final String message;
  final ProgramCoursesDataModel data;

  ProgramCoursesResponseModel({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProgramCoursesResponseModel.fromJson(Map<String, dynamic> json) {
    return ProgramCoursesResponseModel(
      statusCode: json['statusCode'] ?? 0,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ProgramCoursesDataModel.fromJson(
        Map<String, dynamic>.from(json['data'] ?? const {}),
      ),
    );
  }
}

class ProgramCoursesDataModel {
  final ProgramModel program;
  final List<ProgramCourseModel> courses;

  ProgramCoursesDataModel({
    required this.program,
    required this.courses,
  });

  factory ProgramCoursesDataModel.fromJson(Map<String, dynamic> json) {
    return ProgramCoursesDataModel(
      program: ProgramModel.fromJson(
        Map<String, dynamic>.from(json['program'] ?? const {}),
      ),
      courses: (json['courses'] as List<dynamic>?)
              ?.map((item) => ProgramCourseModel.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          [],
    );
  }
}

class ProgramModel {
  final int id;
  final String slug;
  final String name;
  final String description;
  final String? imageUrl;
  final String? shortname;
  final String? sponsor;
  final String? startDate;
  final String? videoUrl;
  final String? whatsappGroupLink;
  final int? courseCount;
  final dynamic onboardingSteps;

  ProgramModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    this.imageUrl,
    this.shortname,
    this.sponsor,
    this.startDate,
    this.videoUrl,
    this.whatsappGroupLink,
    this.courseCount,
    this.onboardingSteps,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'] ?? 0,
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      shortname: json['shortname']?.toString(),
      sponsor: json['sponsor']?.toString(),
      startDate: json['start_date']?.toString(),
      videoUrl: json['video_url']?.toString(),
      whatsappGroupLink: json['whatsapp_group_link']?.toString(),
      courseCount: json['course_count'] is int
          ? json['course_count'] as int
          : int.tryParse(json['course_count']?.toString() ?? ''),
      onboardingSteps: json['onboarding_steps'],
    );
  }
}

class ProgramCourseModel {
  final int courseId;
  final String courseName;
  final String description;
  final String? imageUrl;
  final String? startDate;
  final String? videoUrl;
  final ProgramCourseCohortModel? cohort;

  ProgramCourseModel({
    required this.courseId,
    required this.courseName,
    required this.description,
    this.imageUrl,
    this.startDate,
    this.videoUrl,
    this.cohort,
  });

  factory ProgramCourseModel.fromJson(Map<String, dynamic> json) {
    return ProgramCourseModel(
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      startDate: json['start_date']?.toString(),
      videoUrl: json['video_url']?.toString(),
      cohort: json['cohort'] is Map<String, dynamic>
          ? ProgramCourseCohortModel.fromJson(
              Map<String, dynamic>.from(json['cohort'] as Map),
            )
          : null,
    );
  }

  CourseModel toCourseModel({int? programId}) {
    final cohortSlug = cohort?.slug?.trim();

    return CourseModel(
      id: courseId,
      programId: programId,
      courseName: courseName,
      courseTitle: courseName,
      description: description,
      imageUrl: imageUrl ?? '',
      hasActiveCohort: cohort != null,
      cohortId: cohort?.cohortId,
      isFree: cohort?.isFree ?? false,
      trialType: cohort?.trialType,
      trialValue: cohort?.trialValue ?? 0,
      cost: cohort?.cost ?? 0,
      isEnrolled: false,
      isCompleted: false,
      enrollmentStatus: null,
      paymentStatus: null,
      lessonsTaken: null,
      trialExpiryDate: null,
      slug: cohortSlug?.isNotEmpty == true ? cohortSlug : null,
      discount: cohort?.discount ?? 0,
      learningType: cohort?.learningType,
      videoUrl: videoUrl ?? cohort?.videoUrl,
      enrollmentDeadline: cohort?.enrollmentDeadline,
      cohortStartDate: startDate,
      cohortEndDate: null,
    );
  }
}

class ProgramCourseCohortModel {
  final int cohortId;
  final String? slug;
  final String? title;
  final int discount;
  final double cost;
  final String? trialType;
  final int trialValue;
  final bool isFree;
  final String? enrollmentDeadline;
  final String? learningType;
  final String? whatsappGroupLink;
  final String? videoUrl;

  ProgramCourseCohortModel({
    required this.cohortId,
    this.slug,
    this.title,
    required this.discount,
    required this.cost,
    this.trialType,
    required this.trialValue,
    required this.isFree,
    this.enrollmentDeadline,
    this.learningType,
    this.whatsappGroupLink,
    this.videoUrl,
  });

  factory ProgramCourseCohortModel.fromJson(Map<String, dynamic> json) {
    double parseCost(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return ProgramCourseCohortModel(
      cohortId: json['cohort_id'] ?? 0,
      slug: json['slug']?.toString(),
      title: json['title']?.toString(),
      discount: json['discount'] is int
          ? json['discount'] as int
          : int.tryParse(json['discount']?.toString() ?? '0') ?? 0,
      cost: parseCost(json['cost']),
      trialType: json['trial_type']?.toString(),
      trialValue: json['trial_value'] is int
          ? json['trial_value'] as int
          : int.tryParse(json['trial_value']?.toString() ?? '0') ?? 0,
      isFree: json['is_free'] == true || json['is_free'] == 1,
      enrollmentDeadline: json['enrollment_deadline']?.toString(),
      learningType: json['learning_type']?.toString(),
      whatsappGroupLink: json['whatsapp_group_link']?.toString(),
      videoUrl: json['video_url']?.toString(),
    );
  }
}
