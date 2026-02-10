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
    final options = (json['options'] as List? ?? [])
        .asMap()
        .entries
        .map((entry) => LessonQuizOption.fromJson(entry.value, entry.key))
        .toList();
    final parsedCorrect = CorrectAnswer.fromJson(json['correct'] ?? {});

    int resolvedOrder = parsedCorrect.order;

    // Prefer matching by text to avoid off-by-one ambiguity.
    if (parsedCorrect.text.isNotEmpty) {
      final matchIndex =
          options.indexWhere((opt) => opt.text == parsedCorrect.text);
      if (matchIndex != -1) {
        resolvedOrder = matchIndex;
      }
    }

    // If still out of bounds, attempt 1-based to 0-based conversion.
    if (resolvedOrder < 0 || resolvedOrder >= options.length) {
      if (resolvedOrder > 0 && resolvedOrder <= options.length) {
        resolvedOrder = resolvedOrder - 1;
      }
    }

    return LessonQuiz(
      questionId: json['id'] ?? 0,
      questionText: json['question'] ?? '',
      questionType: json['type'] ?? '',
      options: options,
      correct: CorrectAnswer(
        order: resolvedOrder,
        text: parsedCorrect.text,
      ),
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
    int parsedOrder = 0;
    final rawOrder = json['order'];
    if (rawOrder is int) {
      parsedOrder = rawOrder;
    } else if (rawOrder is String) {
      parsedOrder = int.tryParse(rawOrder) ?? 0;
    } else if (rawOrder != null) {
      parsedOrder = int.tryParse(rawOrder.toString()) ?? 0;
    }

    return CorrectAnswer(
      order: parsedOrder,
      text: json['text']?.toString() ?? '',
    );
  }
}
