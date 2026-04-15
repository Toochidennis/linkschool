import 'package:flutter/foundation.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamifyLeaderboardEntry {
  GamifyLeaderboardEntry({
    required this.playerName,
    required this.score,
    this.userId = 0,
    this.courseId = 0,
    this.courseName = '',
    this.examTypeId = 0,
    this.rank = 0,
    this.subject = '',
    this.gamesPlayed = 1,
    this.levelReached = 1,
    this.correctAnswers = 0,
    this.totalAnswered = 0,
    DateTime? playedAt,
    this.subjectScores = const <String, int>{},
  }) : playedAt = playedAt ?? DateTime.now();

  final int userId;
  final String playerName;
  final int courseId;
  final String courseName;
  final int examTypeId;
  final int score;
  final int rank;

  final String subject;
  final int gamesPlayed;
  final int levelReached;
  final int correctAnswers;
  final int totalAnswered;
  final DateTime playedAt;
  final Map<String, int> subjectScores;

  int get subjectsPlayedCount =>
      normalizedSubjectScores.isEmpty ? 1 : normalizedSubjectScores.length;

  String get topSubject {
    if (normalizedSubjectScores.isEmpty) {
      return subjectSummary;
    }

    final sorted = normalizedSubjectScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  String get subjectSummary {
    if (courseName.trim().isNotEmpty) return courseName.trim();
    if (subject.trim().isNotEmpty) return subject.trim();
    if (normalizedSubjectScores.isNotEmpty) {
      return normalizedSubjectScores.keys.first;
    }
    return 'General';
  }

  Map<String, int> get normalizedSubjectScores {
    if (subjectScores.isNotEmpty) return subjectScores;
    final summary = subjectSummary;
    if (summary.isEmpty) return const <String, int>{};
    return <String, int>{summary: score};
  }

  factory GamifyLeaderboardEntry.fromApiJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

    final parsedScore = json['score'] is num
        ? (json['score'] as num).round()
        : double.tryParse('${json['score']}')?.round() ?? int.tryParse('${json['score']}') ?? 0;
    final parsedCourseName = '${json['course_name'] ?? ''}'.trim();

    return GamifyLeaderboardEntry(
      userId: parseInt(json['user_id']),
      playerName: '${json['username'] ?? 'Player'}',
      courseId: parseInt(json['course_id']),
      courseName: parsedCourseName,
      examTypeId: parseInt(json['exam_type_id']),
      score: parsedScore,
      rank: parseInt(json['rank']),
      subject: parsedCourseName,
      subjectScores: parsedCourseName.isEmpty
          ? const <String, int>{}
          : <String, int>{parsedCourseName: parsedScore},
    );
  }

  factory GamifyLeaderboardEntry.fromSummaryTopThreeJson(
    Map<String, dynamic> json,
  ) {
    int parseInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

    final parsedScore = json['total_score'] is num
        ? (json['total_score'] as num).round()
        : double.tryParse('${json['total_score']}')?.round() ?? int.tryParse('${json['total_score']}') ?? 0;

    return GamifyLeaderboardEntry(
      userId: parseInt(json['user_id']),
      playerName: '${json['username'] ?? 'Player'}',
      score: parsedScore,
      rank: parseInt(json['rank']),
      subjectScores: const <String, int>{},
    );
  }

  factory GamifyLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('username') || json.containsKey('course_name')) {
      return GamifyLeaderboardEntry.fromApiJson(json);
    }

    final rawSubjectScores = json['subjectScores'];
    final parsedSubjectScores = <String, int>{};
    if (rawSubjectScores is Map) {
      for (final entry in rawSubjectScores.entries) {
        final key = '${entry.key}'.trim();
        if (key.isEmpty) continue;
        parsedSubjectScores[key] = (entry.value as num?)?.toInt() ?? 0;
      }
    }

    final fallbackSubject =
        '${json['subject'] ?? json['course_name'] ?? 'General'}';
    final fallbackScore = (json['score'] as num?)?.round() ??
        int.tryParse('${json['score']}') ??
        0;

    if (parsedSubjectScores.isEmpty && fallbackSubject.trim().isNotEmpty) {
      parsedSubjectScores[fallbackSubject.trim()] = fallbackScore;
    }

    return GamifyLeaderboardEntry(
      userId: (json['userId'] as num?)?.toInt() ??
          (json['user_id'] as num?)?.toInt() ??
          0,
      playerName: '${json['playerName'] ?? json['username'] ?? 'Player'}',
      courseId: (json['courseId'] as num?)?.toInt() ??
          (json['course_id'] as num?)?.toInt() ??
          0,
      courseName:
          '${json['courseName'] ?? json['course_name'] ?? fallbackSubject}',
      examTypeId: (json['examTypeId'] as num?)?.toInt() ??
          (json['exam_type_id'] as num?)?.toInt() ??
          0,
      score: fallbackScore,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      subject: fallbackSubject,
      gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 1,
      levelReached: (json['levelReached'] as num?)?.toInt() ?? 1,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      totalAnswered: (json['totalAnswered'] as num?)?.toInt() ?? 0,
      playedAt:
          DateTime.tryParse('${json['playedAt'] ?? ''}') ?? DateTime.now(),
      subjectScores: parsedSubjectScores,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'playerName': playerName,
        'courseId': courseId,
        'courseName': courseName,
        'examTypeId': examTypeId,
        'score': score,
        'rank': rank,
        'subject': subject,
        'gamesPlayed': gamesPlayed,
        'levelReached': levelReached,
        'correctAnswers': correctAnswers,
        'totalAnswered': totalAnswered,
        'playedAt': playedAt.toIso8601String(),
        'subjectScores': normalizedSubjectScores,
      };
}

class GamifyLeaderboardPagination {
  const GamifyLeaderboardPagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.hasNext,
    required this.hasPrev,
  });

  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final bool hasNext;
  final bool hasPrev;

  const GamifyLeaderboardPagination.empty()
      : total = 0,
        perPage = 25,
        currentPage = 1,
        lastPage = 1,
        hasNext = false,
        hasPrev = false;
}

class GamifyLeaderboardFetchResult {
  const GamifyLeaderboardFetchResult({
    required this.entries,
    required this.pagination,
  });

  final List<GamifyLeaderboardEntry> entries;
  final GamifyLeaderboardPagination pagination;
}

class GamifyLeaderboardSummaryMedal {
  const GamifyLeaderboardSummaryMedal({
    required this.rank,
    required this.score,
  });

  final int rank;
  final double score;

  bool get hasData => rank > 0 || score > 0;

  factory GamifyLeaderboardSummaryMedal.fromJson(Map<String, dynamic> json) {
    return GamifyLeaderboardSummaryMedal(
      rank: (json['rank'] as num?)?.toInt() ??
          int.tryParse('${json['rank']}') ??
          0,
      score: (json['score'] as num?)?.toDouble() ??
          double.tryParse('${json['score']}') ??
          0,
    );
  }
}

class GamifyLeaderboardSummaryUserStats {
  const GamifyLeaderboardSummaryUserStats({
    required this.userId,
    required this.overallScore,
    required this.overallRank,
  });

  final int userId;
  final double overallScore;
  final int overallRank;

  bool get hasData => overallScore > 0 || overallRank > 0;

  factory GamifyLeaderboardSummaryUserStats.fromJson(
    Map<String, dynamic> json,
  ) {
    return GamifyLeaderboardSummaryUserStats(
      userId: (json['user_id'] as num?)?.toInt() ??
          int.tryParse('${json['user_id']}') ??
          0,
      overallScore: (json['overall_score'] as num?)?.toDouble() ??
          double.tryParse('${json['overall_score']}') ??
          0,
      overallRank: (json['overall_rank'] as num?)?.toInt() ??
          int.tryParse('${json['overall_rank']}') ??
          0,
    );
  }
}

class GamifyLeaderboardSubjectSummary {
  const GamifyLeaderboardSubjectSummary({
    required this.courseId,
    required this.courseName,
    required this.examTypeId,
    required this.totalParticipants,
    required this.champion,
    required this.runnerUp,
    required this.thirdPlace,
  });

  final int courseId;
  final String courseName;
  final int examTypeId;
  final int totalParticipants;
  final GamifyLeaderboardSummaryMedal? champion;
  final GamifyLeaderboardSummaryMedal? runnerUp;
  final GamifyLeaderboardSummaryMedal? thirdPlace;

  bool get hasData {
    return courseName.trim().isNotEmpty ||
        totalParticipants > 0 ||
        (champion?.hasData ?? false) ||
        (runnerUp?.hasData ?? false) ||
        (thirdPlace?.hasData ?? false);
  }

  factory GamifyLeaderboardSubjectSummary.fromJson(Map<String, dynamic> json) {
    final championMap = GamifyLeaderboardService.staticAsMap(json['champion']);
    final runnerUpMap = GamifyLeaderboardService.staticAsMap(json['runner_up']);
    final thirdPlaceMap =
        GamifyLeaderboardService.staticAsMap(json['third_place']);

    return GamifyLeaderboardSubjectSummary(
      courseId: (json['course_id'] as num?)?.toInt() ??
          int.tryParse('${json['course_id']}') ??
          0,
      courseName: '${json['course_name'] ?? ''}'.trim(),
      examTypeId: (json['exam_type_id'] as num?)?.toInt() ??
          int.tryParse('${json['exam_type_id']}') ??
          0,
      totalParticipants: (json['total_participants'] as num?)?.toInt() ??
          int.tryParse('${json['total_participants']}') ??
          0,
      champion: championMap.isEmpty
          ? null
          : GamifyLeaderboardSummaryMedal.fromJson(championMap),
      runnerUp: runnerUpMap.isEmpty
          ? null
          : GamifyLeaderboardSummaryMedal.fromJson(runnerUpMap),
      thirdPlace: thirdPlaceMap.isEmpty
          ? null
          : GamifyLeaderboardSummaryMedal.fromJson(thirdPlaceMap),
    );
  }
}

class GamifyLeaderboardSummary {
  const GamifyLeaderboardSummary({
    required this.userStats,
    required this.subjects,
    required this.topThreeOverall,
  });

  final GamifyLeaderboardSummaryUserStats? userStats;
  final List<GamifyLeaderboardSubjectSummary> subjects;
  final List<GamifyLeaderboardEntry> topThreeOverall;

  bool get isEmpty {
    return !(userStats?.hasData ?? false) &&
        subjects.isEmpty &&
        topThreeOverall.isEmpty;
  }

  factory GamifyLeaderboardSummary.fromJson(Map<String, dynamic> json) {
    final userStatsMap =
        GamifyLeaderboardService.staticAsMap(json['user_stats']);

    return GamifyLeaderboardSummary(
      userStats: userStatsMap.isEmpty
          ? null
          : GamifyLeaderboardSummaryUserStats.fromJson(userStatsMap),
      subjects: GamifyLeaderboardService.staticAsList(json['subjects'])
          .map(
            (item) => GamifyLeaderboardSubjectSummary.fromJson(
              GamifyLeaderboardService.staticAsMap(item),
            ),
          )
          .where((item) => item.hasData)
          .toList(growable: false),
      topThreeOverall:
          GamifyLeaderboardService.staticAsList(json['top_three_overall'])
              .map(
                (item) => GamifyLeaderboardEntry.fromSummaryTopThreeJson(
                  GamifyLeaderboardService.staticAsMap(item),
                ),
              )
              .toList(growable: false),
    );
  }
}

class GamifyLeaderboardService {
  GamifyLeaderboardService({ApiService? apiService})
      : _apiService = apiService ?? locator<ApiService>();

  static const String _bestScorePrefix = 'gamify_best_score_v2_debug';
  final ApiService _apiService;

  Future<GamifyLeaderboardSummary?> fetchLeaderboardSummary({
    required int examTypeId,
    required int userId,
  }) async {
    if (examTypeId <= 0 || userId <= 0) {
      return null;
    }

    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint: 'public/cbt/gamify/leaderboard/summary',
      queryParams: <String, dynamic>{
        'user_id': userId,
        'exam_type_id': examTypeId,
      },
      addDatabaseParam: false,
      fromJson: (json) => json,
    );

    if (!response.success) {
      debugPrint(
          'Gamify leaderboard summary fetch failed: ${response.message}');
      return null;
    }

    final root = response.data ?? response.rawData ?? <String, dynamic>{};
    final dataObj = _asMap(root['data']);
    if (dataObj.isEmpty) return null;

    final summary = GamifyLeaderboardSummary.fromJson(dataObj);
    return summary.isEmpty ? null : summary;
  }

  Future<GamifyLeaderboardFetchResult> fetchLeaderboard({
    required int examTypeId,
    int? courseId,
    int page = 1,
    int limit = 25,
  }) async {
    if (examTypeId <= 0) {
      return const GamifyLeaderboardFetchResult(
        entries: <GamifyLeaderboardEntry>[],
        pagination: GamifyLeaderboardPagination.empty(),
      );
    }

    final queryParams = <String, dynamic>{
      'exam_type_id': examTypeId,
      'page': page,
      'limit': limit,
    };

    if (courseId != null && courseId > 0) {
      queryParams['course_id'] = courseId;
    }

    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint: 'public/cbt/gamify/leaderboard',
      queryParams: queryParams,
      addDatabaseParam: false,
      fromJson: (json) => json,
    );

    debugPrint('[fetchLeaderboard] success=${response.success} message=${response.message}');
    debugPrint('[fetchLeaderboard] rawData=${response.rawData}');
    debugPrint('[fetchLeaderboard] data=${response.data}');

    if (!response.success) {
      debugPrint('Gamify leaderboard fetch failed: ${response.message}');
      return const GamifyLeaderboardFetchResult(
        entries: <GamifyLeaderboardEntry>[],
        pagination: GamifyLeaderboardPagination.empty(),
      );
    }

    final root = response.data ?? response.rawData ?? <String, dynamic>{};
    debugPrint('[fetchLeaderboard] root=$root');
    final dataObj = _asMap(root['data']);
    final rows = _asList(dataObj['data']);
    debugPrint('[fetchLeaderboard] rows count=${rows.length}');
    if (rows.isNotEmpty) debugPrint('[fetchLeaderboard] first row=${rows.first}');
    final paginationObj = _asMap(dataObj['pagination']);

    final entries = rows.map((item) {
      debugPrint('[fetchLeaderboard] parsing row=$item');
      return GamifyLeaderboardEntry.fromApiJson(_asMap(item));
    }).toList(growable: false);

    final pagination = GamifyLeaderboardPagination(
      total: _asInt(paginationObj['total']) ?? entries.length,
      perPage: _asInt(paginationObj['per_page']) ?? limit,
      currentPage: _asInt(paginationObj['current_page']) ?? page,
      lastPage: _asInt(paginationObj['last_page']) ?? page,
      hasNext: _asBool(paginationObj['has_next']) ?? false,
      hasPrev: _asBool(paginationObj['has_prev']) ?? (page > 1),
    );

    return GamifyLeaderboardFetchResult(
        entries: entries, pagination: pagination);
  }

  Future<List<GamifyLeaderboardEntry>> getEntries({
    required int examTypeId,
    int? courseId,
    int page = 1,
    int limit = 25,
  }) async {
    final result = await fetchLeaderboard(
      examTypeId: examTypeId,
      courseId: courseId,
      page: page,
      limit: limit,
    );
    return result.entries;
  }

  Future<bool> submitScoreIfHigher({
    required int userId,
    required String username,
    required int examTypeId,
    required int courseId,
    required String courseName,
    required num score,
  }) async {
    final trimmedUsername = username.trim();
    final trimmedCourse = courseName.trim();
    final normalizedScore = score.round();

    if (userId <= 0 ||
        trimmedUsername.isEmpty ||
        examTypeId <= 0 ||
        courseId <= 0 ||
        trimmedCourse.isEmpty ||
        normalizedScore <= 0) {
      debugPrint(
        'Gamify score skipped: invalid payload '
        'userId=$userId username=$trimmedUsername examTypeId=$examTypeId '
        'courseId=$courseId courseName=$trimmedCourse score=$normalizedScore',
      );
      return false;
    }

    final previousBest = await _getBestScore(
      username: trimmedUsername,
      examTypeId: examTypeId,
      courseId: courseId,
    );

    debugPrint(
      'Gamify score check: key=${_bestScoreKey(username: trimmedUsername, examTypeId: examTypeId, courseId: courseId)} '
      'previousBest=$previousBest incomingScore=$normalizedScore',
    );

    if (normalizedScore <= previousBest) {
      debugPrint(
        'Gamify score skipped: incoming score is not higher than stored best',
      );
      return false;
    }

    final payload = <String, dynamic>{
      'user_id': userId,
      'username': trimmedUsername,
      'exam_type_id': examTypeId,
      'course_id': courseId,
      'course_name': trimmedCourse,
      'score': normalizedScore,
    };

    debugPrint(
      'Gamify score post request: endpoint=public/cbt/gamify/leaderboard payload=$payload',
    );

    final response = await _apiService.post<Map<String, dynamic>>(
      endpoint: 'public/cbt/gamify/leaderboard',
      body: payload,
      addDatabaseParam: false,
      fromJson: (json) => json,
    );

    debugPrint(
      'Gamify score post response: success=${response.success} '
      'message=${response.message} data=${response.data} rawData=${response.rawData}',
    );

    if (!response.success) {
      debugPrint('Gamify leaderboard save failed: ${response.message}');
      return false;
    }

    await _setBestScore(
      username: trimmedUsername,
      examTypeId: examTypeId,
      courseId: courseId,
      score: normalizedScore,
    );
    debugPrint(
      'Gamify score stored locally: '
      'key=${_bestScoreKey(username: trimmedUsername, examTypeId: examTypeId, courseId: courseId)} '
      'score=$normalizedScore',
    );
    return true;
  }

  Future<void> saveEntry(GamifyLeaderboardEntry entry) async {
    await submitScoreIfHigher(
      userId: entry.userId,
      username: entry.playerName,
      examTypeId: entry.examTypeId,
      courseId: entry.courseId,
      courseName:
          entry.courseName.isNotEmpty ? entry.courseName : entry.subject,
      score: entry.score,
    );
  }

  Future<int> _getBestScore({
    required String username,
    required int examTypeId,
    required int courseId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestScoreKey(
          username: username,
          examTypeId: examTypeId,
          courseId: courseId,
        )) ??
        0;
  }

  Future<void> _setBestScore({
    required String username,
    required int examTypeId,
    required int courseId,
    required int score,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _bestScoreKey(
        username: username,
        examTypeId: examTypeId,
        courseId: courseId,
      ),
      score,
    );
  }

  String _bestScoreKey({
    required String username,
    required int examTypeId,
    required int courseId,
  }) {
    final normalizedUsername = username.trim().toLowerCase();
    return '$_bestScorePrefix:$normalizedUsername:$examTypeId:$courseId';
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry('$k', v));
    return <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List) return value;
    return const <dynamic>[];
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  bool? _asBool(dynamic value) {
    if (value is bool) return value;
    final text = '$value'.trim().toLowerCase();
    if (text == 'true' || text == '1' || text == 'yes') return true;
    if (text == 'false' || text == '0' || text == 'no') return false;
    return null;
  }

  static Map<String, dynamic> staticAsMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry('$k', v));
    return <String, dynamic>{};
  }

  static List<dynamic> staticAsList(dynamic value) {
    if (value is List) return value;
    return const <dynamic>[];
  }
}
