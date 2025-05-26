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



// class RegistrationHistoryResponse {
//   final int totalStudents;
//   final List<HistorySessionData> sessions;

//   RegistrationHistoryResponse({
//     required this.totalStudents,
//     required this.sessions,
//   });

//   factory RegistrationHistoryResponse.fromJson(Map<String, dynamic> json) {
//     return RegistrationHistoryResponse(
//       totalStudents: json['total_students'] ?? 0,
//       sessions: (json['sessions'] as List<dynamic>?)
//           ?.map((session) => HistorySessionData.fromJson(session))
//           .toList() ?? [],
//     );
//   }
// }

// class HistorySessionData {
//   final int year;
//   final List<HistoryTermData> terms;

//   HistorySessionData({
//     required this.year,
//     required this.terms,
//   });

//   factory HistorySessionData.fromJson(Map<String, dynamic> json) {
//     return HistorySessionData(
//       year: json['year'] ?? 0,
//       terms: (json['terms'] as List<dynamic>?)
//           ?.map((term) => HistoryTermData.fromJson(term))
//           .toList() ?? [],
//     );
//   }
// }

// class HistoryTermData {
//   final String termName;
//   final int termValue;

//   HistoryTermData({
//     required this.termName,
//     required this.termValue,
//   });

//   factory HistoryTermData.fromJson(Map<String, dynamic> json) {
//     return HistoryTermData(
//       termName: json['term_name'] ?? '',
//       termValue: json['term_value'] ?? 0,
//     );
//   }
// }