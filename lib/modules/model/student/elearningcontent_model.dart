class ElearningContentData {
  final int? id; // Changed to nullable
  final String title;
  final String type;
  final String objective;
  final List<ClassInfo> classes;
  final int rank;
  final List<ChildContent> children;

  ElearningContentData({
    this.id, // Now nullable
    required this.title,
    required this.type,
    required this.objective,
    required this.classes,
    required this.rank,
    required this.children,
  });

  factory ElearningContentData.fromJson(Map<String, dynamic> json) {
    final id = json['id']; // Can be null
    final title = json['title'] ?? '';
    final type = json['type'] ?? '';
    final objective = json['objective'] ?? '';
    final classes = (json['classes'] as List<dynamic>?)
            ?.map((e) => ClassInfo.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final rank = json['rank'] ?? 0;
    final children = (json['children'] as List<dynamic>?)
            ?.map((e) => ChildContent.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return ElearningContentData(
      id: id,
      title: title,
      type: type,
      objective: objective,
      classes: classes,
      rank: rank,
      children: children,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'objective': objective,
      'classes': classes.map((e) => e.toJson()).toList(),
      'rank': rank,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'ElearningContentData(id: $id, title: $title, type: $type, objective: $objective, classes: $classes, rank: $rank, children: ${children.length} children)';
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

class ChildContent {
  final QuizSettings? settings;
  final List<Question> questions;
  final int? id;
  final int? syllabusId;
  final String? title;
  final String? description;
  final String? type;
  final int? rank;
  final int? topicId;
  final String? topic;
  final List<ClassInfo>? classes;
  final List<ContentFile>? contentFiles;
  final String? startDate;
  final String? endDate;
  final String? grade;
  final String? datePosted;

  ChildContent({
    this.id,
    this.syllabusId,
    this.title,
    this.description,
    this.type,
    this.rank,
    this.topicId,
    this.topic,
    this.classes,
    this.contentFiles,
    this.startDate,
    this.endDate,
    this.grade,
    this.datePosted,
    this.settings,
    required this.questions,
  });

  factory ChildContent.fromJson(Map<String, dynamic> json) {
    final settings = (json.containsKey('settings') &&
            json['settings'] is Map<String, dynamic>)
        ? QuizSettings.fromJson(json['settings'])
        : null;

    final questions = (json['questions'] as List<dynamic>?)
            ?.map((e) => Question.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Safe handling of nullable lists
    final classes = json['classes'] != null
        ? (json['classes'] as List<dynamic>)
            .map((e) => ClassInfo.fromJson(e))
            .toList()
        : <ClassInfo>[];

    final contentFiles = json['content_files'] != null
        ? (json['content_files'] as List<dynamic>)
            .map((e) => ContentFile.fromJson(e))
            .toList()
        : <ContentFile>[];

    return ChildContent(
      id: json['id'],
      syllabusId: json['syllabus_id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      rank: json['rank'],
      topicId: json['topic_id'],
      topic: json['topic'],
      classes: classes,
      contentFiles: contentFiles,
      startDate: json['start_date'],
      endDate: json['end_date'],
      grade: json['grade'],
      datePosted: json['date_posted'],
      settings: settings,
      questions: questions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (settings != null) 'settings': settings!.toJson(),
      'questions': questions.map((e) => e.toJson()).toList(),
      'id': id,
      'syllabus_id': syllabusId,
      'title': title,
      'description': description,
      'type': type,
      'rank': rank,
      'topic_id': topicId,
      'topic': topic,
      'classes': classes?.map((e) => e.toJson()).toList(),
      'content_files': contentFiles?.map((e) => e.toJson()).toList(),
      'start_date': startDate,
      'end_date': endDate,
      'grade': grade,
      'date_posted': datePosted,
    };
  }

  @override
  String toString() {
    return 'ChildContent(settings: $settings, questions: ${questions.length} questions)';
  }
}

class QuizSettings {
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

  QuizSettings({
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
  });

  factory QuizSettings.fromJson(Map<String, dynamic> json) {
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

    final classes = (json['classes'] as List<dynamic>?)
            ?.map((e) => ClassInfo.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return QuizSettings(
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
    };
  }

  @override
  String toString() {
    return 'QuizSettings(id: $id, title: $title, type: $type, classes: ${classes.length})';
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

    final correct =
        CorrectAnswer.fromJson(json['correct'] as Map<String, dynamic>? ?? {});

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
