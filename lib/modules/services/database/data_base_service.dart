import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/database/cbt_db_helper.dart';


class CbtExamSyncService {
  static const String _endpoint =
      'https://linkskool.net/api/v3/public/cbt/exams-courses';

  final CbtDbHelper _db = CbtDbHelper.instance;

  /// Call this once at app startup.
  /// First launch  → fetches from API, saves to SQLite, marks seed done.
  /// Every launch after → skips network entirely.
  Future<void> syncOnStartup() async {
    final alreadySeeded = await _db.isSeedDone('exam_types_seed');

    if (alreadySeeded) {
      return;
    }


    try {
      final apiKey = EnvConfig.apiKey;

      final response = await http
          .get(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-API-KEY': apiKey,
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final decoded = json.decode(response.body);

      List<dynamic> rawList;
      if (decoded is List) {
        rawList = decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        rawList = decoded['data'] as List;
      } else {
        throw Exception('Unexpected response format');
      }

      // Save everything to local DB
      await _db.saveExamTypesAndCourses(
        rawList.cast<Map<String, dynamic>>(),
      );

      // Mark as done so we never fetch again
      await _db.markSeedDone('exam_types_seed');

    } catch (e) {
      // Don't mark as seeded — will retry next app launch
    }
  }

  /// Force a re-sync (e.g. from a settings refresh button).
  /// Clears seed_meta so next loadBoards() will re-fetch.
  Future<void> forceResync() async {
    final db = await _db.database;
    await db.delete('seed_meta', where: "name = 'exam_types_seed'");
    await syncOnStartup();
  }
}
