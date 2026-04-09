import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class GamifyLeaderboardEntry {
  const GamifyLeaderboardEntry({
    required this.playerName,
    required this.subject,
    required this.score,
    required this.levelReached,
    required this.correctAnswers,
    required this.totalAnswered,
    required this.playedAt,
  });

  final String playerName;
  final String subject;
  final int score;
  final int levelReached;
  final int correctAnswers;
  final int totalAnswered;
  final DateTime playedAt;

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'subject': subject,
        'score': score,
        'levelReached': levelReached,
        'correctAnswers': correctAnswers,
        'totalAnswered': totalAnswered,
        'playedAt': playedAt.toIso8601String(),
      };

  factory GamifyLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return GamifyLeaderboardEntry(
      playerName: json['playerName']?.toString() ?? 'Player',
      subject: json['subject']?.toString() ?? 'Unknown Subject',
      score: json['score'] as int? ?? 0,
      levelReached: json['levelReached'] as int? ?? 1,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      totalAnswered: json['totalAnswered'] as int? ?? 0,
      playedAt: DateTime.tryParse(json['playedAt']?.toString() ?? '') ??
          DateTime.now(),
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
      return _sortEntries(entries);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveEntry(GamifyLeaderboardEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getEntries();
    final updated = [...entries, entry];
    final sorted =
        _sortEntries(updated).take(_maxEntries).toList(growable: false);

    await prefs.setString(
      _leaderboardKey,
      json.encode(sorted.map((item) => item.toJson()).toList(growable: false)),
    );
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
