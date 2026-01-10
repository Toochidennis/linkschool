class AnnouncementModel {
  final int id;
  final String title;
  final String content;
  final String actionUrl;
  final String actionText;
  final String displayPosition;
  final String status;
  final int isSponsored;
  final int authorId;
  final String authorName;
  final AnnouncementImage image;
  final String createdAt;
  final String? updatedAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.actionUrl,
    required this.actionText,
    required this.displayPosition,
    required this.status,
    required this.isSponsored,
    required this.authorId,
    required this.authorName,
    required this.image,
    required this.createdAt,
    this.updatedAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      content: json['content'] ?? "",
      actionUrl: json['action_url'] ?? "",
      actionText: json['action_text'] ?? "",
      displayPosition: json['display_position'] ?? "center",
      status: json['status'] ?? "draft",
      isSponsored: json['is_sponsored'] ?? 0,
      authorId: json['author_id'] ?? 0,
      authorName: json['author_name'] ?? "Unknown",
      image: AnnouncementImage.fromJson(json['image'] ?? {}),
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'action_url': actionUrl,
      'action_text': actionText,
      'display_position': displayPosition,
      'status': status,
      'is_sponsored': isSponsored,
      'author_id': authorId,
      'author_name': authorName,
      'image': image.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Get full image URL
  String get imageUrl {
    if (image.fileName.isNotEmpty) {
      return 'https://linkskool.net/${image.fileName}';
    }
    return '';
  }

  // Check if announcement is published
  bool get isPublished => status.toLowerCase() == 'published';

  // Check if announcement is sponsored
  bool get sponsored => isSponsored == 1;
}

class AnnouncementImage {
  final String fileName;
  final String oldFileName;
  final String type;
  final String file;

  AnnouncementImage({
    required this.fileName,
    required this.oldFileName,
    required this.type,
    required this.file,
  });

  factory AnnouncementImage.fromJson(Map<String, dynamic> json) {
    return AnnouncementImage(
      fileName: json['file_name'] ?? "",
      oldFileName: json['old_file_name'] ?? "",
      type: json['type'] ?? "image",
      file: json['file'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file_name': fileName,
      'old_file_name': oldFileName,
      'type': type,
      'file': file,
    };
  }
}
