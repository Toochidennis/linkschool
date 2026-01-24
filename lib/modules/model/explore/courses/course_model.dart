class CourseModel {
  final int id;
  final int? programId;
  final String courseName;
  final String description;
  final String imageUrl;

  final bool hasActiveCohort;
  final int? cohortId;
  final bool isFree;
  final String? trialType;
  final int trialValue;
  final double cost;
  final bool isEnrolled;
  final bool isCompleted;
  final String? enrollmentStatus;
  final String? paymentStatus;
  final int? lessonsTaken;
  final String? trialExpiryDate;

  CourseModel({
    required this.id,
    this.programId,
    required this.courseName,
    required this.description,
    required this.imageUrl,
    required this.hasActiveCohort,
    required this.cohortId,
    required this.isFree,
    required this.trialType,
    required this.trialValue,
    required this.cost,
    required this.isEnrolled,
    required this.isCompleted,
    required this.enrollmentStatus,
    this.paymentStatus,
    this.lessonsTaken,
    this.trialExpiryDate,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json, {int? programIdOverride}) {
    final int idVal = json['course_id'] ?? json['id'] ?? 0;

    double parseCost(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return CourseModel(
      programId: programIdOverride ?? json['program_id'] as int?,
      id: idVal,
      courseName: json['course_name'] ?? "",
      description: json['description'] ?? "",
      imageUrl: json['image_url'] ?? "",
      hasActiveCohort: json['has_active_cohort'] ?? false,
      cohortId: json['cohort_id'],
      isFree: (json['is_free'] == true) || (json['is_free'] == 1),
      trialType: json['trial_type']?.toString(),
      trialValue: json['trial_value'] is int
          ? json['trial_value']
          : (json['trial_value'] != null
              ? int.tryParse(json['trial_value'].toString()) ?? 0
              : 0),
      cost: parseCost(json['cost']),
      isEnrolled: json['is_enrolled'] ?? false,
      isCompleted: json['is_completed'] ?? false,
      enrollmentStatus: json['enrollment_status']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      lessonsTaken: json['lessons_taken'] is int
          ? json['lessons_taken']
          : (json['lessons_taken'] != null
              ? int.tryParse(json['lessons_taken'].toString())
              : null),
      trialExpiryDate: json['trial_expiry_date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': id,
      'program_id': programId,
      'course_name': courseName,
      'description': description,
      'image_url': imageUrl,
      'has_active_cohort': hasActiveCohort,
      'cohort_id': cohortId,
      'is_free': isFree,
      'trial_type': trialType,
      'trial_value': trialValue,
      'cost': cost,
      'is_enrolled': isEnrolled,
      'is_completed': isCompleted,
      'enrollment_status': enrollmentStatus,
      'payment_status': paymentStatus,
      'lessons_taken': lessonsTaken,
      'trial_expiry_date': trialExpiryDate,
    };
  }

  bool get hasTrial => (trialType != null && trialValue > 0);

  String get trialLabel {
    if (!hasTrial) return '';
    final t = trialType?.toLowerCase();
    if (t == 'days' || t == 'day') return '${trialValue}d trial';
    if (t == 'percentage' || t == 'percent') return 'Trial $trialValue%';
    return 'Trial ${trialValue.toString()}';
  }

  String get priceLabel => isFree ? 'FREE' : 'PAID';
}



