import 'dart:convert';
import 'package:linkschool/database/cbt_db_helper.dart';
import 'package:linkschool/modules/model/explore/home/cbt_board_model.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';


class CBTService {
  static const String _endpoint =
      'https://linkskool.net/api/v3/public/cbt/exams-courses';

  final CbtDbHelper _db = CbtDbHelper.instance;

 

  Future<List<CBTBoardModel>> fetchCBTBoards({
    bool forceNetwork = false,
  }) async {
    // 1. Try local DB first (unless forced)
    if (!forceNetwork) {
      final localBoards = await _loadFromDb();
      if (localBoards.isNotEmpty) {
        return localBoards;
      }
    }

    // 2. Fetch from network
    return await _fetchFromNetwork();
  }

  // ─────────────────────────────────────────
  // READ FROM LOCAL DB
  // ─────────────────────────────────────────

  Future<List<CBTBoardModel>> _loadFromDb() async {
    try {
      final examTypes = await _db.getExamTypes();
      if (examTypes.isEmpty) return [];

      final List<CBTBoardModel> boards = [];

      for (final examType in examTypes) {
        final examTypeId = examType['id'] as int;

        // Get all courses for this exam type
        final courses = await _db.getCoursesForExamType(examTypeId);

        // For each course, get any downloaded years
        final List<SubjectModel> subjects = [];
        for (final course in courses) {
          final courseId = course['id'] as int;

          final years = await _db.getYearsForCourse(
            examTypeId: examTypeId,
            courseId: courseId,
          );

          subjects.add(
            SubjectModel.fromDb(
              course,
              years: years
                  .map((y) => YearModel.fromDb(y))
                  .toList(),
            ),
          );
        }

        boards.add(CBTBoardModel.fromDb(examType, subjects));
      }

      return boards;
    } catch (e) {
      return [];
    }
  }

  // ─────────────────────────────────────────
  // FETCH FROM NETWORK
  // ─────────────────────────────────────────

  Future<List<CBTBoardModel>> _fetchFromNetwork() async {
    final apiKey = EnvConfig.apiKey;
    if (apiKey.isEmpty) throw Exception('API key not found');

    final response = await http.get(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-KEY': apiKey,
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
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

 

    return rawList
        .map((e) => CBTBoardModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
