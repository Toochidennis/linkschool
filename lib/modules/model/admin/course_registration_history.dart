class CourseRegistrationHistory {
  final int totalStudents;
  final List<Session> sessions;

  CourseRegistrationHistory({
    required this.totalStudents,
    required this.sessions,
  });

  factory CourseRegistrationHistory.fromJson(Map<String, dynamic> json) {
    var sessionsJson = json['sessions'] as List;
    List<Session> sessionsList = sessionsJson
        .map((sessionJson) => Session.fromJson(sessionJson))
        .toList();

    return CourseRegistrationHistory(
      totalStudents: json['total_students'] ?? 0,
      sessions: sessionsList,
    );
  }
}

class Session {
  final int year;
  final List<Term> terms;

  Session({
    required this.year,
    required this.terms,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    var termsJson = json['terms'] as List;
    List<Term> termsList =
        termsJson.map((termJson) => Term.fromJson(termJson)).toList();

    return Session(
      year: json['year'] ?? 0,
      terms: termsList,
    );
  }
}

class Term {
  final String termName;
  final int termValue;

  Term({
    required this.termName,
    required this.termValue,
  });

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      termName: json['term_name'] ?? '',
      termValue: json['term_value'] ?? 0,
    );
  }
}
