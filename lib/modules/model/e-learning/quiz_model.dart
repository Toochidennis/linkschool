// Safe JSON parsing utilities
class JsonUtils {
  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed == null) {
        print('JsonUtils: Failed to parse int from string: "$value"');
      }
      return parsed;
    }
    if (value is double) return value.toInt();
    print('JsonUtils: Unexpected type for int parsing: ${value.runtimeType} - $value');
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
      print('JsonUtils: Expected List but got ${value.runtimeType}: $value');
      return [];
    }
    
    final List<T> result = [];
    for (int i = 0; i < value.length; i++) {
      try {
        final item = parser(value[i]);
        result.add(item);
      } catch (e) {
        print('JsonUtils: Error parsing list item at index $i: $e');
        print('JsonUtils: Item data: ${value[i]}');
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
    print('JsonUtils: Expected Map but got ${value.runtimeType}: $value');
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
      print('ContentResponse: Parsing JSON');
      
      return ContentResponse(
        statusCode: JsonUtils.parseInt(json['statusCode']) ?? 200,
        success: JsonUtils.parseBool(json['success']),
        response: JsonUtils.parseList(
          json['response'], 
          (item) => ContentItem.fromJson(JsonUtils.ensureMap(item))
        ),
      );
    } catch (e, stackTrace) {
      print('ContentResponse: Error parsing JSON: $e');
      print('ContentResponse: Stack trace: $stackTrace');
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
      print('ContentItem: Parsing item - ${json['title']} (${json['type']})');
      
      return ContentItem(
        id: JsonUtils.parseInt(json['id']),
        title: JsonUtils.parseString(json['title']),
        type: JsonUtils.parseString(json['type']),
        children: _parseChildren(json['children']),
      );
    } catch (e, stackTrace) {
      print('ContentItem: Error parsing JSON: $e');
      print('ContentItem: Stack trace: $stackTrace');
      print('ContentItem: JSON data: $json');
      rethrow;
    }
  }

  static List<dynamic> _parseChildren(dynamic children) {
    if (children is! List) {
      print('ContentItem: Children is not a list: ${children.runtimeType} - $children');
      return [];
    }

    final List<dynamic> result = [];
    for (int i = 0; i < children.length; i++) {
      try {
        final child = children[i];
        print('ContentItem: Processing child at index $i');
        
        if (child is! Map) {
          print('ContentItem: Child at index $i is not a Map: ${child.runtimeType}');
          continue;
        }

        final childMap = JsonUtils.ensureMap(child);
        
        // Check if it's a quiz by looking for 'settings' and 'questions'
        if (childMap.containsKey('settings') && childMap.containsKey('questions')) {
          print('ContentItem: Detected quiz content at index $i');
          result.add(QuizContent.fromJson(childMap));
        } else {
          print('ContentItem: Detected regular content at index $i - ${childMap['title']} (${childMap['type']})');
          result.add(ChildContent.fromJson(childMap));
        }
      } catch (e, stackTrace) {
        print('ContentItem: Error parsing child at index $i: $e');
        print('ContentItem: Stack trace: $stackTrace');
        print('ContentItem: Child data: ${children[i]}');
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
      print('ChildContent: Parsing ${json['title']} (${json['type']})');
      
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
    } catch (e, stackTrace) {
      print('ChildContent: Error parsing JSON: $e');
      print('ChildContent: Stack trace: $stackTrace');
      print('ChildContent: JSON data: $json');
      rethrow;
    }
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    return str.isEmpty ? null : str;
  }

  static List<ClassInfo> _parseClassesList(dynamic classes) {
    print('ChildContent: Parsing classes list: $classes');
    
    if (classes is! List) {
      print('ChildContent: Classes is not a list: ${classes.runtimeType}');
      return [];
    }
    
    final List<ClassInfo> result = [];
    for (int i = 0; i < classes.length; i++) {
      try {
        final classItem = classes[i];
        print('ChildContent: Processing class at index $i: $classItem');
        
        if (classItem is Map) {
          result.add(ClassInfo.fromJson(JsonUtils.ensureMap(classItem)));
        } else {
          print('ChildContent: Class item at index $i is not a Map: ${classItem.runtimeType}');
        }
      } catch (e) {
        print('ChildContent: Error parsing class at index $i: $e');
        print('ChildContent: Class data: ${classes[i]}');
      }
    }
    return result;
  }

  static List<ContentFile> _parseContentFilesList(dynamic contentFiles) {
    print('ChildContent: Parsing content files list: $contentFiles');
    
    if (contentFiles is! List) {
      print('ChildContent: Content files is not a list: ${contentFiles.runtimeType}');
      return [];
    }
    
    final List<ContentFile> result = [];
    for (int i = 0; i < contentFiles.length; i++) {
      try {
        final fileItem = contentFiles[i];
        print('ChildContent: Processing content file at index $i: $fileItem');
        
        if (fileItem is Map) {
          result.add(ContentFile.fromJson(JsonUtils.ensureMap(fileItem)));
        } else {
          print('ChildContent: Content file at index $i is not a Map: ${fileItem.runtimeType}');
        }
      } catch (e) {
        print('ChildContent: Error parsing content file at index $i: $e');
        print('ChildContent: File data: ${contentFiles[i]}');
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
      print('QuizContent: Parsing quiz content');
      
      return QuizContent(
        settings: QuizSettings.fromJson(JsonUtils.ensureMap(json['settings'])),
        questions: JsonUtils.parseList(
          json['questions'], 
          (item) => QuizQuestion.fromJson(JsonUtils.ensureMap(item))
        ),
      );
    } catch (e, stackTrace) {
      print('QuizContent: Error parsing JSON: $e');
      print('QuizContent: Stack trace: $stackTrace');
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
      print('QuizSettings: Parsing quiz settings');
      
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
    } catch (e, stackTrace) {
      print('QuizSettings: Error parsing JSON: $e');
      print('QuizSettings: Stack trace: $stackTrace');
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
      print('QuizQuestion: Parsing quiz question');
      
      return QuizQuestion(
        questionId: JsonUtils.parseInt(json['question_id']),
        questionGrade: JsonUtils.parseInt(json['question_grade']) ?? 0,
        questionFiles: ChildContent._parseContentFilesList(json['question_files']),
        questionText: JsonUtils.parseString(json['question_text']),
        questionType: JsonUtils.parseString(json['question_type']),
        options: json['options'] is List ? json['options'] : [],
        correct: CorrectAnswer.fromJson(JsonUtils.ensureMap(json['correct'])),
      );
    } catch (e, stackTrace) {
      print('QuizQuestion: Error parsing JSON: $e');
      print('QuizQuestion: Stack trace: $stackTrace');
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
    print('ClassInfo: Parsing class info: $json');
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
    print('ContentFile: Parsing content file: $json');
    return ContentFile(
      fileName: JsonUtils.parseString(json['file_name']),
      oldFileName: JsonUtils.parseString(json['old_file_name']),
      type: JsonUtils.parseString(json['type']),
      file: JsonUtils.parseString(json['file']),
    );
  }
}
