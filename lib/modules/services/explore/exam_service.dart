import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/database/cbt_db-helper.dart';


class ExamService {
  final CbtDbHelper _db = CbtDbHelper.instance;

  Future<Map<String, dynamic>> fetchExamData({
    required String examType,
    int? limit,
    bool randomizeQuestions = false,
  }) async {
    // ── 1. Try SQLite first ────────────────────────────────────────
    try {
      final localData = await _fetchFromDb(
        examType: examType,
        limit: limit,
        randomizeQuestions: randomizeQuestions,
      );
      if (localData != null) {
        return localData;
      }
    } catch (e) {
    }

    // ── 2. Fallback to network ─────────────────────────────────────
    return await _fetchFromNetwork(examType: examType, limit: limit);
  }

  // ─────────────────────────────────────────────────────────────────
  // Read from SQLite and shape into the same Map structure that
  // ExamProvider/QuestionModel already expects from the network.
  // ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> _fetchFromDb({
    required String examType,
    int? limit,
    bool randomizeQuestions = false,
  }) async {
    final db = await _db.database;

    // examType here is the exam row id (the year-specific exam id)
    final int examId = int.tryParse(examType) ?? 0;
    if (examId == 0) return null;

    // ── Load the exam row ──────────────────────────────────────────
    final examRows = await db.query(
      'exams',
      where: 'id = ?',
      whereArgs: [examId],
      limit: 1,
    );

    if (examRows.isEmpty) {
      return null;
    }

    final examRow = examRows.first;

    // ── Load questions for this exam ───────────────────────────────
    final questionRows = await db.query(
      'questions',
      where: 'exam_id = ?',
      whereArgs: [examId],
      orderBy: randomizeQuestions ? 'RANDOM()' : 'id ASC',
      limit: limit,
    );

    if (questionRows.isEmpty) {
      return null;
    }


    // ── Load options for all questions in one query ────────────────
    final questionIds = questionRows.map((q) => q['id']).toList();
    final placeholders = List.filled(questionIds.length, '?').join(',');
    final optionRows = await db.rawQuery(
      'SELECT * FROM options WHERE question_id IN ($placeholders) ORDER BY question_id, label ASC',
      questionIds,
    );

    // Group options by question_id
    final Map<int, List<Map<String, dynamic>>> optionsByQuestion = {};
    for (final opt in optionRows) {
      final qId = opt['question_id'] as int;
      optionsByQuestion.putIfAbsent(qId, () => []).add(Map<String, dynamic>.from(opt));
    }

    // ── Load images referenced by questions/options ────────────────
    final allImageIds = <String>{};
    for (final q in questionRows) {
      if (q['image_id'] != null) allImageIds.add(q['image_id'] as String);
    }
    for (final opt in optionRows) {
      if (opt['image_id'] != null) allImageIds.add(opt['image_id'] as String);
    }

    final Map<String, String> imageLocalPaths = {};
    if (allImageIds.isNotEmpty) {
      final imgPlaceholders = List.filled(allImageIds.length, '?').join(',');
      final imageRows = await db.rawQuery(
        'SELECT id, local_path FROM images WHERE id IN ($imgPlaceholders)',
        allImageIds.toList(),
      );
      for (final img in imageRows) {
        imageLocalPaths[img['id'] as String] = img['local_path'] as String;
      }
    }

    // ── Build questions in the format QuestionModel.fromJson expects ─
    final List<Map<String, dynamic>> builtQuestions = [];

    for (final q in questionRows) {
      final qId = q['id'] as int;
      final qImageId = q['image_id'] as String?;
      final qImagePath = qImageId != null ? imageLocalPaths[qImageId] : null;

      // Build question_files list (same shape as network response)
      final List<Map<String, dynamic>> questionFiles = qImagePath != null
          ? [{'file_name': qImagePath, 'file': ''}]
          : [];

      // Build options list
      final dbOptions = optionsByQuestion[qId] ?? [];
      String? correctText;
      final List<Map<String, dynamic>> builtOptions = [];

      for (final opt in dbOptions) {
        final optImageId = opt['image_id'] as String?;
        final optImagePath = optImageId != null ? imageLocalPaths[optImageId] : null;

        final List<Map<String, dynamic>> optionFiles = optImagePath != null
            ? [{'file_name': optImagePath, 'file': ''}]
            : [];

        final isCorrect = (opt['is_correct'] as int? ?? 0) == 1;
        final optText = opt['text'] as String? ?? '';
        if (isCorrect) correctText = optText;

        // Convert label (A/B/C/D) back to order number
        final label = opt['label'] as String? ?? 'A';
        final order = _labelToOrder(label);

        builtOptions.add({
          'order': order,
          'text': optText,
          'option_files': optionFiles,
        });
      }

      // Find the correct option order
      final correctOption = dbOptions.firstWhere(
        (o) => (o['is_correct'] as int? ?? 0) == 1,
        orElse: () => {},
      );
      final correctOrder = correctOption.isNotEmpty
          ? _labelToOrder(correctOption['label'] as String? ?? 'A')
          : 1;

      builtQuestions.add({
        'question_id': qId,
        'question_text': q['text'] ?? '',
        'question_files': questionFiles,
        'question_type': q['type'] ?? 'multiple_choice',
        'instruction': q['instruction'] ?? '',
        'passage': q['passage'] ?? '',
        'explanation': q['explanation'] ?? '',
        'topic': q['topic'] ?? '',
        'year': q['year']?.toString() ?? '',
        'options': builtOptions,
        'correct': {
          'order': correctOrder,
          'text': correctText ?? '',
        },
      });
    }

    if (randomizeQuestions && builtQuestions.length > 1) {
      builtQuestions.shuffle(Random());
    }

    // ── Shape into the same envelope ExamProvider expects ──────────
    // ExamProvider checks: data['success'] == true
    //                      data['data']['exam']
    //                      data['data']['questions']
    return {
      'success': true,
      'source': 'local_db',
      'data': {
        'exam': {
          'id': examRow['id'],
          'title': examRow['title'] ?? '',
          'description': '',
          'course_name': examRow['title'] ?? '',
          'course_id': examRow['course_id']?.toString() ?? '',
          'body': '',
          'url': '',
        },
        // ExamProvider handles both List and Map structures.
        // We wrap in a Map with key "0" to match the Map branch.
        'questions': {'0': builtQuestions},
      },
    };
  }

  // ─────────────────────────────────────────────────────────────────
  // Original network fetch — unchanged
  // ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _fetchFromNetwork({
    required String examType,
    int? limit,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;
      if (apiKey.isEmpty) {
        throw Exception('❌ API key not found in .env file');
      }

      var url =
          'https://linkskool.net/api/v3/public/cbt/exams/$examType/questions';
      if (limit != null) {
        url += '?limit=$limit';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );


      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody;
      } else {
        throw Exception('Failed to load exam data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching exam data: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Helper: option label letter → order number
  // A=1, B=2, C=3, D=4, E=5
  // ─────────────────────────────────────────────────────────────────
  int _labelToOrder(String label) {
    const map = {'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5};
    return map[label.toUpperCase()] ?? 1;
  }
}

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:linkschool/config/env_config.dart';

// class ExamService {
//   static const String baseUrl = 'http://www.public.linkskool.com/api';

//   Future<Map<String, dynamic>> fetchExamData({
//     required String examType,
//     int? limit,
//   }) async {
//     try {
//       final apiKey = EnvConfig.apiKey;
//       if (apiKey.isEmpty) {
//         throw Exception("❌ API key not found in .env file");
//       }

//       // Build URL with optional limit parameter
//       var url =
//           "https://linkskool.net/api/v3/public/cbt/exams/$examType/questions";
//       if (limit != null) {
//         url += "?limit=$limit";
//       }

//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'X-API-KEY': apiKey,
//         },
//       );


//       if (response.statusCode == 200) {
//         final responseBody = json.decode(response.body);

//         return responseBody;
//       } else {
//         throw Exception('Failed to load exam data: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching exam data: $e');
//     }
//   }
// }


