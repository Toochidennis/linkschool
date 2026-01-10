class MarkedQuizAnswer {
  final String questionId;
  final String question;
  final String correct;
  final String answer;
  final String type;

  MarkedQuizAnswer({
    required this.questionId,
    required this.question,
    required this.correct,
    required this.answer,
    required this.type,
  });

  factory MarkedQuizAnswer.fromJson(Map<String, dynamic> json) {
    return MarkedQuizAnswer(
      questionId: json['question_id'],
      question: json['question'],
      correct: json['correct'],
      answer: json['answer'],
      type: json['type'],
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

class MarkedQuizModel {
  final String studentName;
  final List<MarkedQuizAnswer> answers;
  final String markingScore;
  final String score;
  final String date;

  MarkedQuizModel({
    required this.studentName,
    required this.answers,
    required this.markingScore,
    required this.score,
    required this.date,
  });

  factory MarkedQuizModel.fromJson(Map<String, dynamic> json) {
    return MarkedQuizModel(
      studentName: json['student_name'],
      answers: (json['answers'] as List)
          .map((a) => MarkedQuizAnswer.fromJson(a))
          .toList(),
      markingScore: json['marking_score'],
      score: json['score'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_name': studentName,
      'answers': answers.map((a) => a.toJson()).toList(),
      'marking_score': markingScore,
      'score': score,
      'date': date,
    };
  }
}
