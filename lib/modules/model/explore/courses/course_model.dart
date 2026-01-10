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
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? 0,
      courseName: json['course_name'] ?? "",
      description: json['description'] ?? "",
      imageUrl: json['image_url'] ?? "",
      category: json['category'] ?? "",
      slogan: json['slogan'] ?? "",
      icon: json['icon'] ?? "",
      email: json['email'] ?? "",
      hasContent: json['has_content'] ?? false,
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
    };
  }
}
