class AssessmentContentItem {
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
  final String? duration;
  final String? grade;
  final String? datePosted;
  final List<ContentFile> contentFiles;
  final List<QuizQuestion> questions;

  AssessmentContentItem({
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
    this.duration,
    this.grade,
    this.datePosted,
    this.contentFiles = const [],
    this.questions = const [],
  });

  // Check if this is a quiz
  bool get isQuiz => type == 'quiz';

  // Check if this is an assignment
  bool get isAssignment => type == 'assignment';

  // Check if this is material
  bool get isMaterial => type == 'material';

  factory AssessmentContentItem.fromJson(Map<String, dynamic> json) {
    return AssessmentContentItem(
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
      duration: json['duration'],
      grade: json['grade']?.toString(),
      datePosted: json['date_posted'],
      contentFiles: (json['content_files'] as List<dynamic>?)
              ?.map((e) => ContentFile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
      'grade': grade,
      'date_posted': datePosted,
      'content_files': contentFiles.map((e) => e.toJson()).toList(),
      'questions': questions.map((e) => e.toJson()).toList(),
    };
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class ContentFile {
  final String fileName;
  final String? oldFileName;
  final String type;
  final String file;

  ContentFile({
    required this.fileName,
    this.oldFileName,
    required this.type,
    required this.file,
  });

  factory ContentFile.fromJson(Map<String, dynamic> json) {
    return ContentFile(
      fileName: json['file_name'] ?? '',
      oldFileName: json['old_file_name'],
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
}

class QuizQuestion {
  final int questionId;
  final int questionGrade;
  final List<ContentFile> questionFiles;
  final String questionText;
  final String questionType;
  final List<QuestionOption> options;
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

  bool get isMultipleChoice => questionType == 'multiple_choice';
  bool get isShortAnswer => questionType == 'short_answer';

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      questionId: json['question_id'] ?? 0,
      questionGrade: json['question_grade'] ?? 0,
      questionFiles: (json['question_files'] as List<dynamic>?)
              ?.map((e) => ContentFile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      questionText: json['question_text'] ?? '',
      questionType: json['question_type'] ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => QuestionOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      correct: CorrectAnswer.fromJson(json['correct'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'question_grade': questionGrade,
      'question_files': questionFiles.map((e) => e.toJson()).toList(),
      'question_text': questionText,
      'question_type': questionType,
      'options': options.map((e) => e.toJson()).toList(),
      'correct': correct.toJson(),
    };
  }
}

class QuestionOption {
  final String order;
  final String text;
  final List<ContentFile> optionFiles;

  QuestionOption({
    required this.order,
    required this.text,
    required this.optionFiles,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      order: json['order']?.toString() ?? '',
      text: json['text'] ?? '',
      optionFiles: (json['option_files'] as List<dynamic>?)
              ?.map((e) => ContentFile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'text': text,
      'option_files': optionFiles.map((e) => e.toJson()).toList(),
    };
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
      order: json['order']?.toString() ?? '',
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'text': text,
    };
  }
}

class ContentTopic {
  final int id;
  final String title;
  final String type;
  final String objective;
  final List<ClassInfo> classes;
  final int rank;
  final List<AssessmentContentItem> children;

  ContentTopic({
    required this.id,
    required this.title,
    required this.type,
    required this.objective,
    required this.classes,
    required this.rank,
    required this.children,
  });

  factory ContentTopic.fromJson(Map<String, dynamic> json) {
    return ContentTopic(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      objective: json['objective'] ?? '',
      classes: (json['classes'] as List<dynamic>?)
              ?.map((e) => ClassInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      rank: json['rank'] ?? 0,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) =>
                  AssessmentContentItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
}
