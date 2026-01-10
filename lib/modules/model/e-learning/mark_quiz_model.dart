class QuizResponse {
  final int statusCode;
  final bool success;
  final QuizData data;

  QuizResponse({
    required this.statusCode,
    required this.success,
    required this.data,
  });

  factory QuizResponse.fromJson(Map<String, dynamic> json) {
    return QuizResponse(
      statusCode: json['statusCode'] as int,
      success: json['success'] as bool,
      data: QuizData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'success': success,
      'data': data.toJson(),
    };
  }
}

class QuizData {
  final List<QuizSubmission> submitted;
  final List<QuizSubmission> unmarked;
  final List<QuizSubmission> marked;
  final List<QuizSubmission> notSubmitted;

  QuizData({
    required this.submitted,
    required this.unmarked,
    required this.marked,
    required this.notSubmitted,
  });

  factory QuizData.fromJson(Map<String, dynamic> json) {
    return QuizData(
      submitted: (json['submitted'] as List<dynamic>?)
              ?.map((e) => QuizSubmission.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      unmarked: (json['unmarked'] as List<dynamic>?)
              ?.map((e) => QuizSubmission.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      marked: (json['marked'] as List<dynamic>?)
              ?.map((e) => QuizSubmission.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notSubmitted: (json['not_submitted'] as List<dynamic>?)
              ?.map((e) => QuizSubmission.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'submitted': submitted.map((e) => e.toJson()).toList(),
      'unmarked': unmarked.map((e) => e.toJson()).toList(),
      'marked': marked.map((e) => e.toJson()).toList(),
      'not_submitted': notSubmitted.map((e) => e.toJson()).toList(),
    };
  }
}

class QuizSubmission {
  final int id;
  final int contentId;
  final int studentId;
  final String studentName;
  final List<QuizAnswer> answers;
  final String markingScore;
  final String? published;
  final String score;
  final String date;

  QuizSubmission({
    required this.id,
    required this.contentId,
    required this.studentId,
    required this.studentName,
    required this.answers,
    required this.markingScore,
    this.published,
    required this.score,
    required this.date,
  });

  factory QuizSubmission.fromJson(Map<String, dynamic> json) {
    return QuizSubmission(
      id: json['id'] as int,
      contentId: json['content_id'] as int,
      studentId: json['student_id'] as int,
      studentName: json['student_name'] as String,
      answers: (json['answers'] as List<dynamic>?)
              ?.map((e) => QuizAnswer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      markingScore: json['marking_score'] as String,
      published: json['published'] as String?,
      score: json['score'] as String,
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content_id': contentId,
      'student_id': studentId,
      'student_name': studentName,
      'answers': answers.map((e) => e.toJson()).toList(),
      'marking_score': markingScore,
      'published': published,
      'score': score,
      'date': date,
    };
  }
}

class QuizAnswer {
  final String questionId;
  final String question;
  final String correct;
  final String answer;
  final String type;

  QuizAnswer({
    required this.questionId,
    required this.question,
    required this.correct,
    required this.answer,
    required this.type,
  });

  factory QuizAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAnswer(
      questionId: json['question_id'] as String,
      question: json['question'] as String,
      correct: json['correct'] as String,
      answer: json['answer'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'question': question,
      'correct': correct,
      'answer': answer,
      'type': type,
    };
  }
}
