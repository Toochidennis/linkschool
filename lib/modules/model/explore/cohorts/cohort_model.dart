class CohortModel {
  final int id;
  final int programId;
  final int courseId;
  final String slug;
  final String courseName;
  final String title;
  final String description;
  final String benefits;
  final String? code;
  final String startDate;
  final String endDate;
  final String status;
  final String imageUrl;
  final int capacity;
  final String deliveryMode;
  final String zoomLink;
  final int isFree;
  final String trialType;
  final int trialValue;
  final String cost;
  final String? instructorName;
  final String createdAt;
  final String updatedAt;

  CohortModel({
    required this.id,
    required this.programId,
    required this.courseId,
    required this.slug,
    required this.courseName,
    required this.title,
    required this.description,
    required this.benefits,
    this.code,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.imageUrl,
    required this.capacity,
    required this.deliveryMode,
    required this.zoomLink,
    required this.isFree,
    required this.trialType,
    required this.trialValue,
    required this.cost,
    this.instructorName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CohortModel.fromJson(Map<String, dynamic> json) {
    return CohortModel(
      id: json['id'] ?? 0,
      programId: json['program_id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      slug: json['slug'] ?? '',
      courseName: json['course_name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      benefits: json['benefits'] ?? '',
      code: json['code']?.toString(),
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      status: json['status'] ?? '',
      imageUrl: json['image_url'] ?? '',
      capacity: json['capacity'] ?? 0,
      deliveryMode: json['delivery_mode'] ?? '',
      zoomLink: json['zoom_link'] ?? '',
      isFree: json['is_free'] ?? 0,
      trialType: json['trial_type'] ?? '',
      trialValue: json['trial_value'] ?? 0,
      cost: json['cost']?.toString() ?? '',
      instructorName: json['instructor_name']?.toString(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'program_id': programId,
      'course_id': courseId,
      'slug': slug,
      'course_name': courseName,
      'title': title,
      'description': description,
      'benefits': benefits,
      'code': code,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'image_url': imageUrl,
      'capacity': capacity,
      'delivery_mode': deliveryMode,
      'zoom_link': zoomLink,
      'is_free': isFree,
      'trial_type': trialType,
      'trial_value': trialValue,
      'cost': cost,
      'instructor_name': instructorName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class CohortResponseModel {
  final int statusCode;
  final bool success;
  final String message;
  final CohortModel? data;

  CohortResponseModel({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory CohortResponseModel.fromJson(Map<String, dynamic> json) {
    return CohortResponseModel(
      statusCode: json['statusCode'] ?? 200,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? CohortModel.fromJson(json['data']) : null,
    );
  }
}
