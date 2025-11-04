class SyllabusContentItem {
  final int? id;
  final int? syllabusId;
  final String title;
  final String description;
  final String type;
  final int rank;
  final int? topicId;
  final String? topic;
  final List<ClassInfo> classes;
  final String? startDate;
  final String? endDate;
  final String? grade;
  final String? duration;
  final List<ContentFile> contentFiles;
  final String? datePosted;
  final Map<String, dynamic>? settings;
  final List<Map<String, dynamic>>? questions;

  SyllabusContentItem({
    this.id,
    this.syllabusId,
    required this.title,
    required this.description,
    required this.type,
    required this.rank,
    this.topicId,
    this.topic,
    required this.classes,
    this.startDate,
    this.endDate,
    this.grade,
    this.duration,
    required this.contentFiles,
    this.datePosted,
    this.settings,
    this.questions,
  });

  factory SyllabusContentItem.fromJson(Map<String, dynamic> json) {
    return SyllabusContentItem(
      id: json['id'],
      syllabusId: json['syllabus_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      rank: json['rank'] ?? 0,
      topicId: json['topic_id'],
      topic: json['topic'],
      classes: (json['classes'] as List<dynamic>?)
              ?.map((e) => ClassInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      startDate: json['start_date'],
      endDate: json['end_date'],
      grade: json['grade'],
      duration: json['duration'],
      contentFiles: (json['content_files'] as List<dynamic>?)
              ?.map((e) => ContentFile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      datePosted: json['date_posted'],
      settings: json['settings'],
      questions: json['questions'] != null
          ? List<Map<String, dynamic>>.from(json['questions'])
          : null,
    );
  }
}

class ClassInfo {
  final String id;
  final String name;

  ClassInfo({
    required this.id,
    required this.name,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class ContentFile {
  final String fileName;
  final String oldFileName;
  final String type;
  final String file;

  ContentFile({
    required this.fileName,
    required this.oldFileName,
    required this.type,
    required this.file,
  });

  factory ContentFile.fromJson(Map<String, dynamic> json) {
    return ContentFile(
      fileName: json['file_name']?.toString() ?? '',
      oldFileName: json['old_file_name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      file: json['file']?.toString() ?? '',
    );
  }
}

class TopicContent {
  final int? id;
  final String name;
  final String type;
  final List<SyllabusContentItem> children;

  TopicContent({
    this.id,
    required this.name,
    required this.type,
    required this.children,
  });

  factory TopicContent.fromJson(Map<String, dynamic> json) {
    return TopicContent(
      id: json['id'],
      name: json['title'] ?? '',
      type: json['type'] ?? '',
      children: (json['children'] as List<dynamic>?)
              ?.map((e) =>
                  SyllabusContentItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
