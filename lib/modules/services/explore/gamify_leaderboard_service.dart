import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class GamifyLeaderboardEntry {
  const GamifyLeaderboardEntry({
    required this.playerName,
    required this.subject,
    required this.score,
    this.gamesPlayed = 1,
    required this.levelReached,
    required this.correctAnswers,
    required this.totalAnswered,
    required this.playedAt,
    this.subjectScores = const {},
  });

  final String playerName;
  final String subject;
  final int score;
  final int gamesPlayed;
  final int levelReached;
  final int correctAnswers;
  final int totalAnswered;
  final DateTime playedAt;
  final Map<String, int> subjectScores;

  int get subjectsPlayedCount => subjectScores.length;

  String get topSubject {
    if (subjectScores.isEmpty) {
      return subject;
    }

    final sorted = subjectScores.entries.toList()
      ..sort((a, b) {
        final scoreCompare = b.value.compareTo(a.value);
        if (scoreCompare != 0) return scoreCompare;
        return a.key.toLowerCase().compareTo(b.key.toLowerCase());
      });
    return sorted.first.key;
  }

  String get subjectSummary {
    if (subjectScores.isEmpty) {
      return subject;
    }
    if (subjectScores.length == 1) {
      return topSubject;
    }
    return '$topSubject + ${subjectScores.length - 1} more';
  }

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'subject': subject,
        'score': score,
        'gamesPlayed': gamesPlayed,
        'levelReached': levelReached,
        'correctAnswers': correctAnswers,
        'totalAnswered': totalAnswered,
        'playedAt': playedAt.toIso8601String(),
        'subjectScores': subjectScores,
      };

  factory GamifyLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    final rawSubjectScores = json['subjectScores'];
    final parsedSubjectScores = <String, int>{};

    if (rawSubjectScores is Map) {
      for (final entry in rawSubjectScores.entries) {
        final key = entry.key?.toString().trim() ?? '';
        if (key.isEmpty) continue;
        parsedSubjectScores[key] = (entry.value as num?)?.toInt() ?? 0;
      }
    }

    final fallbackSubject = json['subject']?.toString() ?? 'Unknown Subject';
    final fallbackScore = (json['score'] as num?)?.toInt() ?? 0;
    if (parsedSubjectScores.isEmpty && fallbackSubject.trim().isNotEmpty) {
      parsedSubjectScores[fallbackSubject] = fallbackScore;
    }

    return GamifyLeaderboardEntry(
      playerName: json['playerName']?.toString() ?? 'Player',
      subject: fallbackSubject,
      score: fallbackScore,
      gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 1,
      levelReached: (json['levelReached'] as num?)?.toInt() ?? 1,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      totalAnswered: (json['totalAnswered'] as num?)?.toInt() ?? 0,
      playedAt: DateTime.tryParse(json['playedAt']?.toString() ?? '') ??
          DateTime.now(),
      subjectScores: parsedSubjectScores,
    );
  }
}

class GamifyLeaderboardService {
  static const String _leaderboardKey = 'gamify_local_leaderboard';
  static const int _maxEntries = 100;

  Future<List<GamifyLeaderboardEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_leaderboardKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = json.decode(raw) as List<dynamic>;
      final entries = decoded
          .whereType<Map>()
          .map((item) => GamifyLeaderboardEntry.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(growable: false);
      return _sortEntries(_aggregateEntries(entries));
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveEntry(GamifyLeaderboardEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getEntries();
    final updated = _aggregateEntries([...entries, entry]);
    final sorted =
        _sortEntries(updated).take(_maxEntries).toList(growable: false);

    await prefs.setString(
      _leaderboardKey,
      json.encode(sorted.map((item) => item.toJson()).toList(growable: false)),
    );
  }

  List<GamifyLeaderboardEntry> _aggregateEntries(
      List<GamifyLeaderboardEntry> entries) {
    final aggregated = <String, GamifyLeaderboardEntry>{};

    for (final entry in entries) {
      final playerKey = entry.playerName.trim().toLowerCase();
      if (playerKey.isEmpty) continue;

      final existing = aggregated[playerKey];
      if (existing == null) {
        aggregated[playerKey] = entry;
        continue;
      }

      final mergedSubjectScores = <String, int>{
        ...existing.subjectScores,
      };

      for (final subjectEntry in entry.subjectScores.entries) {
        mergedSubjectScores.update(
          subjectEntry.key,
          (value) => value + subjectEntry.value,
          ifAbsent: () => subjectEntry.value,
        );
      }

      aggregated[playerKey] = GamifyLeaderboardEntry(
        playerName: existing.playerName,
        subject: mergedSubjectScores.isEmpty ? existing.subject : entry.subject,
        score: existing.score + entry.score,
        gamesPlayed: existing.gamesPlayed + entry.gamesPlayed,
        levelReached: existing.levelReached > entry.levelReached
            ? existing.levelReached
            : entry.levelReached,
        correctAnswers: existing.correctAnswers + entry.correctAnswers,
        totalAnswered: existing.totalAnswered + entry.totalAnswered,
        playedAt: existing.playedAt.isAfter(entry.playedAt)
            ? existing.playedAt
            : entry.playedAt,
        subjectScores: mergedSubjectScores,
      );
    }

    return aggregated.values.toList(growable: false);
  }

  List<GamifyLeaderboardEntry> _sortEntries(
      List<GamifyLeaderboardEntry> entries) {
    final sorted = List<GamifyLeaderboardEntry>.from(entries);
    sorted.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;

      final levelCompare = b.levelReached.compareTo(a.levelReached);
      if (levelCompare != 0) return levelCompare;

      return b.playedAt.compareTo(a.playedAt);
    });
    return sorted;
  }
}
