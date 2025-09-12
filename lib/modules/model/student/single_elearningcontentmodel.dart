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
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'ClassInfo(id: $id, name: $name)';
  }
}

class SingleElearningContentData {
  final int id;
  final int syllabusId;
  final String title;
  final String description;
  final String type;
  final int rank;
  final int topicId;
  final String topic;
  final List<ClassInfo> classes;
  final List<dynamic> contentFiles;
  final String datePosted;
  final Settings? settings;
  final List<Question> questions;

  SingleElearningContentData({
    required this.id,
    required this.syllabusId,
    required this.title,
    required this.description,
    required this.type,
    required this.rank,
    required this.topicId,
    required this.topic,
    required this.classes,
    required this.contentFiles,
    required this.datePosted,
    this.settings,
    required this.questions,
  });

  factory SingleElearningContentData.fromJson(Map<String, dynamic> json) {
    // Handle the case where settings and questions are at root level
    if (json.containsKey('settings') && json.containsKey('questions') &&
        !json.containsKey('id')) {
      return SingleElearningContentData.fromRootLevelData(json);
    }

    return SingleElearningContentData(
      id: json['id'] ?? 0,
      syllabusId: json['syllabus_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      rank: json['rank'] ?? 0,
      topicId: json['topic_id'] ?? 0,
      topic: json['topic'] ?? '',
      classes: (json['classes'] as List?)
          ?.map((cls) => ClassInfo.fromJson(cls))
          .toList() ?? [],
      contentFiles: json['content_files'] ?? [],
      datePosted: json['date_posted'] ?? '',
      settings: json['settings'] != null
          ? Settings.fromJson(json['settings'])
          : null,
      questions: json['questions'] != null
          ? (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList()
          : [],
    );
  }

  // Special constructor for when settings and questions are at root level
  factory SingleElearningContentData.fromRootLevelData(Map<String, dynamic> json) {
    final settingsData = json['settings'] as Map<String, dynamic>?;
    final questionsData = json['questions'] as List<dynamic>?;

    final settings = settingsData != null ? Settings.fromJson(settingsData) : null;
    final questions = questionsData != null
        ? questionsData.map((q) => Question.fromJson(q)).toList()
        : <Question>[];

    // Use settings data to populate main fields if available
    return SingleElearningContentData(
      id: settingsData?['id'] ?? 0,
      syllabusId: settingsData?['syllabus_id'] ?? 0,
      title: settingsData?['title'] ?? '',
      description: settingsData?['description'] ?? '',
      type: settingsData?['type'] ?? '',
      rank: settingsData?['rank'] ?? 0,
      topicId: settingsData?['topic_id'] ?? 0,
      topic: settingsData?['topic'] ?? '',
      classes: settingsData?['classes'] != null
          ? (settingsData!['classes'] as List)
          .map((cls) => ClassInfo.fromJson(cls))
          .toList()
          : [],
      contentFiles: [],
      datePosted: settingsData?['date_posted'] ?? '',
      settings: settings,
      questions: questions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'syllabus_id': syllabusId,
      'title': title,
      'description': description,
      'type': type,
      'rank': rank,
      'topic_id': topicId,
      'topic': topic,
      'classes': classes.map((cls) => cls.toJson()).toList(),
      'content_files': contentFiles,
      'date_posted': datePosted,
      'settings': settings?.toJson(),
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class Settings {
  final int id;
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
  final String? datePosted;

  Settings({
    required this.id,
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
    this.datePosted,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? 0;
    final syllabusId = json['syllabus_id'] ?? 0;
    final title = json['title'] ?? '';
    final description = json['description'] ?? '';
    final type = json['type'] ?? '';
    final rank = json['rank'] ?? 0;
    final topicId = json['topic_id'] ?? 0;
    final topic = json['topic'] ?? '';
    final startDate = json['start_date'] ?? '';
    final endDate = json['end_date'] ?? '';
    final duration = json['duration']?.toString() ?? '';
    final datePosted = json['date_posted'];

    final classes = (json['classes'] as List<dynamic>?)
        ?.map((e) => ClassInfo.fromJson(e as Map<String, dynamic>))
        .toList() ??
        [];

    return Settings(
      id: id,
      syllabusId: syllabusId,
      title: title,
      description: description,
      type: type,
      rank: rank,
      topicId: topicId,
      topic: topic,
      classes: classes,
      startDate: startDate,
      endDate: endDate,
      duration: duration,
      datePosted: datePosted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'syllabus_id': syllabusId,
      'title': title,
      'description': description,
      'type': type,
      'rank': rank,
      'topic_id': topicId,
      'topic': topic,
      'classes': classes.map((e) => e.toJson()).toList(),
      'start_date': startDate,
      'end_date': endDate,
      'duration': duration,
      if (datePosted != null) 'date_posted': datePosted,
    };
  }

  @override
  String toString() {
    return 'Settings(id: $id, title: $title, type: $type, classes: ${classes.length})';
  }
}

class Question {
  final int questionId;
  final int questionGrade;
  final List<dynamic> questionFiles;
  final String questionText;
  final String questionType;
  final List<Option> options;
  final CorrectAnswer correct;

  Question({
    required this.questionId,
    required this.questionGrade,
    required this.questionFiles,
    required this.questionText,
    required this.questionType,
    required this.options,
    required this.correct,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final questionId = json['question_id'] ?? 0;
    final questionGrade = json['question_grade'] ?? 0;
    final questionFiles = json['question_files'] ?? [];
    final questionText = json['question_text'] ?? '';
    final questionType = json['question_type'] ?? '';

    final options = (json['options'] as List<dynamic>?)
        ?.map((e) => Option.fromJson(e as Map<String, dynamic>))
        .toList() ??
        [];

    final correct = CorrectAnswer.fromJson(
        json['correct'] as Map<String, dynamic>? ?? {});

    return Question(
      questionId: questionId,
      questionGrade: questionGrade,
      questionFiles: questionFiles,
      questionText: questionText,
      questionType: questionType,
      options: options,
      correct: correct,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'question_grade': questionGrade,
      'question_files': questionFiles,
      'question_text': questionText,
      'question_type': questionType,
      'options': options.map((e) => e.toJson()).toList(),
      'correct': correct.toJson(),
    };
  }

  @override
  String toString() {
    return 'Question(id: $questionId, text: $questionText, type: $questionType)';
  }
}

class Option {
  final String order;
  final String text;
  final List<dynamic> optionFiles;

  Option({
    required this.order,
    required this.text,
    required this.optionFiles,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      order: json['order']?.toString() ?? '0',
      text: json['text'] ?? '',
      optionFiles: json['option_files'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'text': text,
      'option_files': optionFiles,
    };
  }

  @override
  String toString() {
    return 'Option(order: $order, text: $text)';
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
      fileName: json['file_name'] ?? '',
      oldFileName: json['old_file_name'] ?? '',
      type: json['type'] ?? '',
      file: json['file'] ?? '',
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

  @override
  String toString() {
    return 'ContentFile(fileName: $fileName, type: $type)';
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
      order: json['order']?.toString() ?? '0',
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'text': text,
    };
  }

  @override
  String toString() {
    return 'CorrectAnswer(order: $order, text: $text)';
  }
}

// Usage example:
void main() {
  // Example of how to use with the API response format you showed
  final apiResponse = {
    "settings": {
      "id": 862,
      "syllabus_id": 858,
      "title": "Computer Studies Quiz",
      "description": "Answer all questions. write clearly. Multiple choices questions require only one correct answer unless stated otherwise",
      "type": "quiz",
      "rank": 0,
      "topic_id": 859,
      "topic": "introduction to computer",
      "classes": [
        {"id": "74", "name": "SSS3A"}
      ],
      "start_date": "2025-09-01 10:44:39",
      "end_date": "2025-09-02 10:44:39",
      "duration": "20",
      "date_posted": "2025-09-01 06:06:15"
    },
    "questions": [
      {
        "question_id": 1594,
        "question_grade": 2,
        "question_files": [],
        "question_text": "In your own words explain what is computer",
        "question_type": "short_answer",
        "options": [],
        "correct": {"order": "0", "text": "computer explained"}
      },
      {
        "question_id": 1595,
        "question_grade": 2,
        "question_files": [],
        "question_text": "which of the following is a type of computer?",
        "question_type": "multiple_choice",
        "options": [
          {"order": "0", "text": "Television", "option_files": []},
          {"order": "1", "text": "Laptop", "option_files": []},
          {"order": "2", "text": "Radio", "option_files": []},
          {"order": "3", "text": "Fan", "option_files": []}
        ],
        "correct": {"order": "1", "text": "Laptop"}
      }
    ]
  };

  // This will now work with your API response format
  final contentData = SingleElearningContentData.fromJson(apiResponse);
  print('Content: ${contentData.title}');
  print('Questions: ${contentData.questions.length}');
}