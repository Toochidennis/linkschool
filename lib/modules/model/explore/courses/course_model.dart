class CourseModel {
  final int id;
  final String courseName;
  final String description;
  final String imageUrl;
  final String category;
  final String slogan;
  final String icon;
  final String email;
  final bool hasContent;

  // New fields from API
  final bool hasActiveCohort;
  final int? cohortId;
  final bool isFree;
  final String? trialType;
  final int trialValue;
  final double cost;
  final bool isEnrolled;
  final bool isCompleted;
  final String? enrollmentStatus;
  final String? paymentStatus; // payment status from API (e.g., "paid", "pending")
  final int? lessonsTaken; // number of lessons taken
  final String? trialExpiryDate; // new: expiry date string from API (ISO 8601)

  CourseModel({
    required this.id,
    required this.courseName,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.slogan,
    required this.icon,
    required this.email,
    required this.hasContent,
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

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    // support both 'course_id' and 'id'
    final int idVal = json['course_id'] ?? json['id'] ?? 0;

    // normalize cost to double
    double parseCost(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return CourseModel(
      id: idVal,
      courseName: json['course_name'] ?? "",
      description: json['description'] ?? "",
      imageUrl: json['image_url'] ?? "",
      category: json['category'] ?? "",
      slogan: json['slogan'] ?? "",
      icon: json['icon'] ?? "",
      email: json['email'] ?? "",
      hasContent: json['has_content'] ?? false,

      // new fields
      hasActiveCohort: json['has_active_cohort'] ?? false,
      cohortId: json['cohort_id'],
      isFree: (json['is_free'] == true) || (json['is_free'] == 1),
      trialType: json['trial_type'] != null ? json['trial_type'].toString() : null,
      trialValue: (json['trial_value'] ?? 0) is int ? (json['trial_value'] ?? 0) : (int.tryParse((json['trial_value'] ?? 0).toString()) ?? 0),
      cost: parseCost(json['cost']),
      isEnrolled: json['is_enrolled'] ?? false,
      isCompleted: json['is_completed'] ?? false,
      enrollmentStatus: json['enrollment_status']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      lessonsTaken: json['lessons_taken'] is int ? json['lessons_taken'] : (json['lessons_taken'] != null ? int.tryParse(json['lessons_taken'].toString()) : null),
      trialExpiryDate: json['trial_expiry_date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_name': courseName,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'slogan': slogan,
      'icon': icon,
      'email': email,
      'has_content': hasContent,

      // new fields
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

  // Convenience helpers
  bool get hasTrial => (trialType != null && trialValue > 0);

  String get trialLabel {
    if (!hasTrial) return '';
    final t = trialType?.toLowerCase();
    if (t == 'days' || t == 'day') return '${trialValue}d trial';
    if (t == 'percentage' || t == 'percent') return 'Trial ${trialValue}%';
    return 'Trial ${trialValue.toString()}';
  }

  String get priceLabel => isFree ? 'FREE' : 'PAID';
}
