class QuizSubmissionModel {
  final int? quizId;
  final int studentId;
  final String studentName;
  final List<QuizSubmissionAnswer> answers;
  final int mark;
  final int score;
  final int levelId;
  final int courseId;
  final int classId;
  final String courseName;
  final String className;
  final int term;
  final int year;
  final String db;

  QuizSubmissionModel({
    required this.quizId,
    required this.studentId,
    required this.studentName,
    required this.answers,
    required this.mark,
    required this.score,
    required this.levelId,
    required this.courseId,
    required this.classId,
    required this.courseName,
    required this.className,
    required this.term,
    required this.year,
    required this.db,
  });

  factory QuizSubmissionModel.fromJson(Map<String, dynamic> json) {
    return QuizSubmissionModel(
      quizId: json['quiz_id'],
      studentId: json['student_id'],
      studentName: json['student_name'],
      answers: (json['answers'] as List)
          .map((a) => QuizSubmissionAnswer.fromJson(a))
          .toList(),
      mark: json['mark'],
      score: json['score'],
      levelId: json['level_id'],
      courseId: json['course_id'],
      classId: json['class_id'],
      courseName: json['course_name'],
      className: json['class_name'],
      term: json['term'],
      year: json['year'],
      db: json['_db'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "quiz_id": quizId,
      "student_id": studentId,
      "student_name": studentName,
      "answers": answers.map((a) => a.toJson()).toList(),
      "mark": mark,
      "score": score,
      "level_id": levelId,
      "course_id": courseId,
      "class_id": classId,
      "course_name": courseName,
      "class_name": className,
      "term": term,
      "year": year,
      "_db": db,
    };
  }
}

class QuizSubmissionAnswer {
  final int questionId;
  final String question;
  final String correct;
  final String? answer;
  final String type;

  QuizSubmissionAnswer({
    required this.questionId,
    required this.question,
    required this.correct,
    required this.answer,
    required this.type,
  });

  factory QuizSubmissionAnswer.fromJson(Map<String, dynamic> json) {
    return QuizSubmissionAnswer(
      questionId: json['question_id'],
      question: json['question'],
      correct: json['correct'],
      answer: json['answer'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "question_id": questionId,
      "question": question,
      "correct": correct,
      "answer": answer,
      "type": type,
    };
  }
}
