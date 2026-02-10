class QuestionsResponse {
  final int statusCode;
  final bool success;
  final String message;
  final List<Question> data;

  QuestionsResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory QuestionsResponse.fromJson(Map<String, dynamic> json) {
    return QuestionsResponse(
      statusCode: json['statusCode'],
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((e) => Question.fromJson(e))
          .toList(),
    );
  }
}

class Question {
  final int questionId;
  final String questionText;
  final List<String> questionFiles;
  final String topic;
  final int topicId;
  final String passage;
  final int passageId;
  final String instruction;
  final int? instructionId;
  final String explanation;
  final int explanationId;
  final String questionType;
  final List<QuestionOption> options;
  final CorrectAnswer correct;
  final String year;

  Question({
    required this.questionId,
    required this.questionText,
    required this.questionFiles,
    required this.topic,
    required this.topicId,
    required this.passage,
    required this.passageId,
    required this.instruction,
    required this.instructionId,
    required this.explanation,
    required this.explanationId,
    required this.questionType,
    required this.options,
    required this.correct,
    required this.year,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionId: json['question_id'],
      questionText: json['question_text'],
      questionFiles: (json['question_files'] as List?)
        ?.map((e) => e.toString())
        .toList() ??
    [],

      topic: json['topic'],
      topicId: json['topic_id'],
      passage: json['passage'] ?? '',
      passageId: json['passage_id'] ?? 0,
      instruction: json['instruction'] ?? '',
      instructionId: json['instruction_id'],
      explanation: json['explanation'] ?? '',
      explanationId: json['explanation_id'] ?? 0,
      questionType: json['question_type'],
      options: (json['options'] as List)
          .map((e) => QuestionOption.fromJson(e))
          .toList(),
      correct: CorrectAnswer.fromJson(json['correct']),
      year: json['year'],
    );
  }
}

class QuestionOption {
  final int order;
  final String text;
  final List<String> optionFiles;

  QuestionOption({
    required this.order,
    required this.text,
    required this.optionFiles,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      order: json['order'],
      text: json['text'],
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
    int parsedOrder = 0;
    final rawOrder = json['order'];
    if (rawOrder is int) {
      parsedOrder = rawOrder;
    } else if (rawOrder is String) {
      parsedOrder = int.tryParse(rawOrder) ?? 0;
    } else if (rawOrder != null) {
      parsedOrder = int.tryParse(rawOrder.toString()) ?? 0;
    }

    // API returns 1-based order (e.g., 1,2,3). Convert to 0-based index to match options list.
    final int zeroBasedOrder = parsedOrder > 0 ? parsedOrder - 1 : 0;

    return CorrectAnswer(
      order: zeroBasedOrder,
      text: json['text']?.toString() ?? '',
    );
  }
}
