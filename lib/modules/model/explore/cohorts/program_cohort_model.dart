import 'package:linkschool/modules/model/explore/courses/course_model.dart';

int _intValue(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

class ProgramCohortProgramModel {
  final int id;
  final String slug;
  final String name;
  final String? description;
  final String? imageUrl;

  ProgramCohortProgramModel({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory ProgramCohortProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramCohortProgramModel(
      id: _intValue(json['id'], fallback: _intValue(json['program_id'])),
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }
}

class ProgramCohortCourseModel {
  final int id;
  final String slug;
  final String courseName;
  final String description;
  final String? imageUrl;
  final String? videoUrl;
  final int? cohortId;
  final int? programId;
  final String? startDate;

  ProgramCohortCourseModel({
    required this.id,
    required this.slug,
    required this.courseName,
    required this.description,
    this.imageUrl,
    this.videoUrl,
    this.cohortId,
    this.programId,
    this.startDate,
  });

  factory ProgramCohortCourseModel.fromJson(Map<String, dynamic> json) {
    return ProgramCohortCourseModel(
      id: _intValue(json['course_id'], fallback: _intValue(json['id'])),
      slug: json['slug']?.toString() ?? '',
      courseName: json['course_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      videoUrl: json['video_url']?.toString(),
      cohortId: _intValue(json['cohort_id'], fallback: -1) >= 0
          ? _intValue(json['cohort_id'])
          : null,
      programId: _intValue(json['program_id'], fallback: -1) >= 0
          ? _intValue(json['program_id'])
          : null,
      startDate: json['start_date']?.toString(),
    );
  }
}

class ProgramCohortItemModel {
  final int id;
  final String slug;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? startDate;
  final String? endDate;
  final String? trialType;
  final int trialValue;
  final int isFree;
  final String cost;
  final String? learningType;
  final int? courseId;
  final int? programId;
  final String? enrollmentDeadline;
  final String? whatsappGroupLink;
  final String? videoUrl;

  ProgramCohortItemModel({
    required this.id,
    required this.slug,
    required this.title,
    this.description,
    this.imageUrl,
    this.startDate,
    this.endDate,
    this.trialType,
    required this.trialValue,
    required this.isFree,
    required this.cost,
    this.learningType,
    this.courseId,
    this.programId,
    this.enrollmentDeadline,
    this.whatsappGroupLink,
    this.videoUrl,
  });

  factory ProgramCohortItemModel.fromJson(Map<String, dynamic> json) {
    return ProgramCohortItemModel(
      id: _intValue(json['id'], fallback: _intValue(json['cohort_id'])),
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      trialType: json['trial_type']?.toString(),
      trialValue: _intValue(json['trial_value']),
      isFree: json['is_free'] == true || json['is_free'] == 1 ? 1 : 0,
      cost: json['cost']?.toString() ?? '',
      learningType: json['learning_type']?.toString(),
      courseId: _intValue(json['course_id'], fallback: -1) >= 0
          ? _intValue(json['course_id'])
          : null,
      programId: _intValue(json['program_id'], fallback: -1) >= 0
          ? _intValue(json['program_id'])
          : null,
      enrollmentDeadline: json['enrollment_deadline']?.toString(),
      whatsappGroupLink: json['whatsapp_group_link']?.toString(),
      videoUrl: json['video_url']?.toString(),
    );
  }
}

class ProgramCohortDataModel {
  final ProgramCohortProgramModel? program;
  final ProgramCohortCourseModel? course;
  final ProgramCohortItemModel? cohort;

  ProgramCohortDataModel({
    required this.program,
    required this.course,
    required this.cohort,
  });

  factory ProgramCohortDataModel.fromJson(Map<String, dynamic> json) {
    return ProgramCohortDataModel(
      program: json['program'] is Map<String, dynamic>
          ? ProgramCohortProgramModel.fromJson(
              Map<String, dynamic>.from(json['program'] as Map),
            )
          : null,
      course: json['course'] is Map<String, dynamic>
          ? ProgramCohortCourseModel.fromJson(
              Map<String, dynamic>.from(json['course'] as Map),
            )
          : null,
      cohort: json['cohort'] is Map<String, dynamic>
          ? ProgramCohortItemModel.fromJson(
              Map<String, dynamic>.from(json['cohort'] as Map),
            )
          : null,
    );
  }

  CourseModel toCourseModel() {
    final programId = program?.id ?? course?.programId ?? cohort?.programId;
    final cohortId = cohort?.id ?? course?.cohortId;
    final courseId = course?.id ?? cohort?.courseId ?? 0;
    final courseName = course?.courseName ?? '';
    final description = course?.description ?? cohort?.description ?? '';
    final imageUrl = course?.imageUrl ?? cohort?.imageUrl ?? '';
    final trialType = cohort?.trialType;
    final trialValue = cohort?.trialValue ?? 0;
    final cost = double.tryParse(cohort?.cost ?? '') ?? 0.0;
    final isFree = (cohort?.isFree ?? 0) == 1;
    final learningType = cohort?.learningType;
    final cohortSlug = cohort?.slug ?? '';
    final slug = cohortSlug.isNotEmpty
        ? cohortSlug
        : (course?.slug ?? '');

    return CourseModel(
      id: courseId,
      programId: programId,
      courseName: courseName,
      description: description,
      imageUrl: imageUrl,
      hasActiveCohort: cohortId != null,
      cohortId: cohortId,
      isFree: isFree,
      trialType: trialType,
      trialValue: trialValue,
      cost: cost,
      isEnrolled: false,
      isCompleted: false,
      enrollmentStatus: null,
      paymentStatus: null,
      lessonsTaken: null,
      trialExpiryDate: null,
      slug: slug.isNotEmpty ? slug : null,
      learningType: learningType,
      videoUrl: cohort?.videoUrl ?? course?.videoUrl,
      enrollmentDeadline: cohort?.enrollmentDeadline,
      cohortStartDate: cohort?.startDate,
      cohortEndDate: cohort?.endDate,
    );
  }
}

class ProgramCohortResponseModel {
  final int statusCode;
  final bool success;
  final String message;
  final ProgramCohortDataModel? data;

  ProgramCohortResponseModel({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProgramCohortResponseModel.fromJson(Map<String, dynamic> json) {
    return ProgramCohortResponseModel(
      statusCode: json['statusCode'] ?? 200,
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? ProgramCohortDataModel.fromJson(
              Map<String, dynamic>.from(json['data'] as Map),
            )
          : null,
    );
  }
}
