// Safe JSON parsing utilities
class JsonUtils {
  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed == null) {
      }
      return parsed;
    }
    if (value is double) return value.toInt();
    return null;
  }

  static String parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static bool parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value != 0;
    return false;
  }

  static List<T> parseList<T>(dynamic value, T Function(dynamic) parser) {
    if (value is! List) {
      return [];
    }

    final List<T> result = [];
    for (int i = 0; i < value.length; i++) {
      try {
        final item = parser(value[i]);
        result.add(item);
      } catch (e) {
        // Continue processing other items
      }
    }
    return result;
  }

  static Map<String, dynamic> ensureMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }
}

class ContentResponse {
  final int statusCode;
  final bool success;
  final List<ContentItem> response;

  ContentResponse({
    required this.statusCode,
    required this.success,
    required this.response,
  });

  factory ContentResponse.fromJson(Map<String, dynamic> json) {
    try {

      return ContentResponse(
        statusCode: JsonUtils.parseInt(json['statusCode']) ?? 200,
        success: JsonUtils.parseBool(json['success']),
        response: JsonUtils.parseList(json['response'],
            (item) => ContentItem.fromJson(JsonUtils.ensureMap(item))),
      );
    } catch (e) {
      rethrow;
    }
  }
}

class ContentItem {
  final int? id;
  final String title;
  final String type;
  final List<dynamic> children;

  ContentItem({
    this.id,
    required this.title,
    required this.type,
    required this.children,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    try {

      return ContentItem(
        id: JsonUtils.parseInt(json['id']),
        title: JsonUtils.parseString(json['title']),
        type: JsonUtils.parseString(json['type']),
        children: _parseChildren(json['children']),
      );
    } catch (e) {
      rethrow;
    }
  }

  static List<dynamic> _parseChildren(dynamic children) {
    if (children is! List) {
      return [];
    }

    final List<dynamic> result = [];
    for (int i = 0; i < children.length; i++) {
      try {
        final child = children[i];

        if (child is! Map) {
          continue;
        }

        final childMap = JsonUtils.ensureMap(child);

        // Check if it's a quiz by looking for 'settings' and 'questions'
        if (childMap.containsKey('settings') &&
            childMap.containsKey('questions')) {
          result.add(QuizContent.fromJson(childMap));
        } else {
          result.add(ChildContent.fromJson(childMap));
        }
      } catch (e) {
        // Continue processing other children
      }
    }
    return result;
  }
}

class ChildContent {
  final int? id;
  final int syllabusId;
  final String title;
  final String description;
  final String type;
  final int rank;
  final int topicId;
  final String topic;
  final List<ClassInfo> classes;
  final String? startDate;
  final String? endDate;
  final String? grade;
  final List<ContentFile> contentFiles;
  final String? datePosted;

  ChildContent({
    this.id,
    required this.syllabusId,
    required this.title,
    required this.description,
    required this.type,
    required this.rank,
    required this.topicId,
    required this.topic,
    required this.classes,
    this.startDate,
    this.endDate,
    this.grade,
    required this.contentFiles,
    this.datePosted,
  });

  factory ChildContent.fromJson(Map<String, dynamic> json) {
    try {

      return ChildContent(
        id: JsonUtils.parseInt(json['id']),
        syllabusId: JsonUtils.parseInt(json['syllabus_id']) ?? 0,
        title: JsonUtils.parseString(json['title']),
        description: JsonUtils.parseString(json['description']),
        type: JsonUtils.parseString(json['type']),
        rank: JsonUtils.parseInt(json['rank']) ?? 0,
        topicId: JsonUtils.parseInt(json['topic_id']) ?? 0,
        topic: JsonUtils.parseString(json['topic']),
        classes: _parseClassesList(json['classes']),
        startDate: _parseNullableString(json['start_date']),
        endDate: _parseNullableString(json['end_date']),
        grade: _parseNullableString(json['grade']),
        contentFiles: _parseContentFilesList(json['content_files']),
        datePosted: _parseNullableString(json['date_posted']),
      );
    } catch (e) {
      rethrow;
    }
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    return str.isEmpty ? null : str;
  }

  static List<ClassInfo> _parseClassesList(dynamic classes) {

    if (classes is! List) {
      return [];
    }

    final List<ClassInfo> result = [];
    for (int i = 0; i < classes.length; i++) {
      try {
        final classItem = classes[i];

        if (classItem is Map) {
          result.add(ClassInfo.fromJson(JsonUtils.ensureMap(classItem)));
        } else {
        }
      } catch (e) {
      }
    }
    return result;
  }

  static List<ContentFile> _parseContentFilesList(dynamic contentFiles) {

    if (contentFiles is! List) {
      return [];
    }

    final List<ContentFile> result = [];
    for (int i = 0; i < contentFiles.length; i++) {
      try {
        final fileItem = contentFiles[i];

        if (fileItem is Map) {
          result.add(ContentFile.fromJson(JsonUtils.ensureMap(fileItem)));
        } else {
        }
      } catch (e) {
      }
    }
    return result;
  }
}

class QuizContent {
  final QuizSettings settings;
  final List<QuizQuestion> questions;

  QuizContent({
    required this.settings,
    required this.questions,
  });

  factory QuizContent.fromJson(Map<String, dynamic> json) {
    try {

      return QuizContent(
        settings: QuizSettings.fromJson(JsonUtils.ensureMap(json['settings'])),
        questions: JsonUtils.parseList(json['questions'],
            (item) => QuizQuestion.fromJson(JsonUtils.ensureMap(item))),
      );
    } catch (e) {
      rethrow;
    }
  }
}

class QuizSettings {
  final int? id;
  final int syllabusId;
  final String title;
  final String description;
  final String type;
  final int rank;
  final int topicId;
  final String topic;
  final List<ClassInfo> classes;
  final String startDate;
  final String endDate;
  final String duration;

  QuizSettings({
    this.id,
    required this.syllabusId,
    required this.title,
    required this.description,
    required this.type,
    required this.rank,
    required this.topicId,
    required this.topic,
    required this.classes,
    required this.startDate,
    required this.endDate,
    required this.duration,
  });

  factory QuizSettings.fromJson(Map<String, dynamic> json) {
    try {

      return QuizSettings(
        id: JsonUtils.parseInt(json['id']),
        syllabusId: JsonUtils.parseInt(json['syllabus_id']) ?? 0,
        title: JsonUtils.parseString(json['title']),
        description: JsonUtils.parseString(json['description']),
        type: JsonUtils.parseString(json['type']),
        rank: JsonUtils.parseInt(json['rank']) ?? 0,
        topicId: JsonUtils.parseInt(json['topic_id']) ?? 0,
        topic: JsonUtils.parseString(json['topic']),
        classes: ChildContent._parseClassesList(json['classes']),
        startDate: JsonUtils.parseString(json['start_date']),
        endDate: JsonUtils.parseString(json['end_date']),
        duration: JsonUtils.parseString(json['duration']),
      );
    } catch (e) {
      rethrow;
    }
  }
}

class QuizQuestion {
  final int? questionId;
  final int questionGrade;
  final List<ContentFile> questionFiles;
  final String questionText;
  final String questionType;
  final List<dynamic> options;
  final CorrectAnswer correct;

  QuizQuestion({
    required this.questionId,
    required this.questionGrade,
    required this.questionFiles,
    required this.questionText,
    required this.questionType,
    required this.options,
    required this.correct,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    try {

      return QuizQuestion(
        questionId: JsonUtils.parseInt(json['question_id']),
        questionGrade: JsonUtils.parseInt(json['question_grade']) ?? 0,
        questionFiles:
            ChildContent._parseContentFilesList(json['question_files']),
        questionText: JsonUtils.parseString(json['question_text']),
        questionType: JsonUtils.parseString(json['question_type']),
        options: json['options'] is List ? json['options'] : [],
        correct: CorrectAnswer.fromJson(JsonUtils.ensureMap(json['correct'])),
      );
    } catch (e) {
      rethrow;
    }
  }
}

class CorrectAnswer {
  final String order;
  final String text;

  CorrectAnswer({
    required this.order,
    required this.text,
  });

  factory CorrectAnswer.fromJson(Map<String, dynamic> json) {
    return CorrectAnswer(
      order: JsonUtils.parseString(json['order']),
      text: JsonUtils.parseString(json['text']),
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
      id: JsonUtils.parseString(json['id']),
      name: JsonUtils.parseString(json['name']),
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
      fileName: JsonUtils.parseString(json['file_name']),
      oldFileName: JsonUtils.parseString(json['old_file_name']),
      type: JsonUtils.parseString(json['type']),
      file: JsonUtils.parseString(json['file']),
    );
  }
}
