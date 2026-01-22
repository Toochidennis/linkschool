class LessonQuizResponse {
  final int statusCode;
  final bool success;
  final String message;
  final List<LessonQuiz> data;

  LessonQuizResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory LessonQuizResponse.fromJson(Map<String, dynamic> json) {
    return LessonQuizResponse(
      statusCode: json['statusCode'],
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((e) => LessonQuiz.fromJson(e))
          .toList(),
    );
  }
}

class LessonQuiz {
  final int questionId;
  final String questionText;
  final String questionType;
  final List<LessonQuizOption> options;
  final CorrectAnswer correct;

  LessonQuiz({
    required this.questionId,
    required this.questionText,
    required this.questionType,
    required this.options,
    required this.correct,
  });

  factory LessonQuiz.fromJson(Map<String, dynamic> json) {
    return LessonQuiz(
      questionId: json['id'] ?? 0,
      questionText: json['question'] ?? '',
      questionType: json['type'] ?? '',
      options: (json['options'] as List? ?? [])
          .asMap()
          .entries
          .map((entry) => LessonQuizOption.fromJson(entry.value, entry.key))
          .toList(),
      correct: CorrectAnswer.fromJson(json['correct'] ?? {}),
    );
  }
}

class LessonQuizOption {
  final int order;
  final String text;
  final List<String> optionFiles;

  LessonQuizOption({
    required this.order,
    required this.text,
    required this.optionFiles,
  });

  factory LessonQuizOption.fromJson(Map<String, dynamic> json, int index) {
    return LessonQuizOption(
      order: index,
      text: json['text'] ?? '',
      optionFiles: (json['option_files'] as List?)
        ?.map((e) => e.toString())
        .toList() ??
    [],
    );
  }
}

class CorrectAnswer {
  final int order;
  final String text;

  CorrectAnswer({
    required this.order,
    required this.text,
  });

  factory CorrectAnswer.fromJson(Map<String, dynamic> json) {
    return CorrectAnswer(
      order: json['order'],
      text: json['text'],
    );
  }
}