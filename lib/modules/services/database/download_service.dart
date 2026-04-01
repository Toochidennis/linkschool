import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/database/cbt_db_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:linkschool/config/env_config.dart';

import 'package:sqflite/sqflite.dart';

/// Tracks the download state of a single subject
class DownloadState {
  final bool isDownloading;
  final bool isDownloaded;
  final double progress; // 0.0 to 1.0

  const DownloadState({
    this.isDownloading = false,
    this.isDownloaded = false,
    this.progress = 0.0,
  });

  DownloadState copyWith({
    bool? isDownloading,
    bool? isDownloaded,
    double? progress,
  }) {
    return DownloadState(
      isDownloading: isDownloading ?? this.isDownloading,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      progress: progress ?? this.progress,
    );
  }
}

class CbtDownloadService {
  static const String _baseUrl = 'https://linkskool.net/api/v3';
  final CbtDbHelper _db = CbtDbHelper.instance;

  Future<void> clearSubjectData({
    required String examTypeId,
    required String courseId,
  }) async {
    final db = await _db.database;
    final examType = int.tryParse(examTypeId) ?? 0;
    final course = int.tryParse(courseId) ?? 0;

    final examRows = await db.query(
      'exams',
      columns: ['id'],
      where: 'exam_type_id = ? AND course_id = ?',
      whereArgs: [examType, course],
    );

    if (examRows.isEmpty) return;

    final examIds =
        examRows.map((row) => row['id'] as int).toList(growable: false);

    final List<String> orphanPaths = [];

    await db.transaction((txn) async {
      for (final chunk in _chunk(examIds)) {
        final placeholders = List.filled(chunk.length, '?').join(',');
        await txn.execute(
          'DELETE FROM options WHERE question_id IN (SELECT id FROM questions WHERE exam_id IN ($placeholders))',
          chunk,
        );
        await txn.delete(
          'questions',
          where: 'exam_id IN ($placeholders)',
          whereArgs: chunk,
        );
        await txn.delete(
          'exams',
          where: 'id IN ($placeholders)',
          whereArgs: chunk,
        );
      }

      final rows = await txn.rawQuery('''
        SELECT i.id, i.local_path
        FROM images i
        LEFT JOIN questions q ON q.image_id = i.id
        LEFT JOIN options o ON o.image_id = i.id
        WHERE q.id IS NULL AND o.id IS NULL
      ''');

      if (rows.isNotEmpty) {
        final imageIds = rows
            .map((row) => row['id']?.toString())
            .whereType<String>()
            .toList(growable: false);

        for (final row in rows) {
          final path = row['local_path']?.toString();
          if (path != null && path.isNotEmpty) {
            orphanPaths.add(path);
          }
        }

        for (final chunk in _chunk(imageIds)) {
          if (chunk.isEmpty) continue;
          final placeholders = List.filled(chunk.length, '?').join(',');
          await txn.execute(
            'DELETE FROM images WHERE id IN ($placeholders)',
            chunk,
          );
        }
      }
    });

    for (final path in orphanPaths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
      // Intentionally ignored.
    }
    }
  }

  Future<void> downloadSubject({
    required String examTypeId,
    required String courseId,
    required void Function(double progress) onProgress,
    required void Function() onComplete,
    required void Function(String error) onError,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;
      final url =
          '$_baseUrl/public/cbt/exams/$examTypeId/download?course_id=$courseId';

      onProgress(0.05);

      // ── 1. Stream download with progress ──────────────────────────
      final request = http.Request('GET', Uri.parse(url));
      request.headers.addAll({
        'Accept': 'application/zip',
        'X-API-KEY': apiKey,
      });

      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 5),
      );

      if (streamedResponse.statusCode != 200) {
        throw Exception('HTTP ${streamedResponse.statusCode}');
      }

      final contentLength = streamedResponse.contentLength ?? 0;
      final List<int> bytes = [];
      int received = 0;

      await for (final chunk in streamedResponse.stream) {
        bytes.addAll(chunk);
        received += chunk.length;
        if (contentLength > 0) {
          onProgress((received / contentLength) * 0.7);
        } else {
          onProgress(0.3);
        }
      }

      onProgress(0.75);

      // ── 2. Save zip to temp file ───────────────────────────────────
      final tempDir = await getTemporaryDirectory();
      final zipFile = File(
          '${tempDir.path}/exam_${examTypeId}_${courseId}_${DateTime.now().millisecondsSinceEpoch}.zip');
      await zipFile.writeAsBytes(bytes);

      onProgress(0.80);

      // ── 3. Extract zip ─────────────────────────────────────────────
      final extractDir =
          Directory('${tempDir.path}/exam_extract_${examTypeId}_$courseId');
      if (await extractDir.exists()) {
        await extractDir.delete(recursive: true);
      }
      await extractDir.create(recursive: true);

      final inputStream = InputFileStream(zipFile.path);
   final archive = ZipDecoder().decodeBytes(await zipFile.readAsBytes());
    await  extractArchiveToDisk(archive, extractDir.path);
      inputStream.close();

      onProgress(0.85);

      // ── 4. Read JSON files ──────────Stream─────────────────────────
      final examsFile = File('${extractDir.path}/exams.json');
      final questionsFile = File('${extractDir.path}/questions.json');

      if (!await examsFile.exists() || !await questionsFile.exists()) {
        throw Exception('Invalid zip: missing exams.json or questions.json');
      }

      final examsJson =
          jsonDecode(await examsFile.readAsString()) as List<dynamic>;
      final questionsJson =
          jsonDecode(await questionsFile.readAsString()) as List<dynamic>;

      onProgress(0.90);

      // ── 5. Copy images to permanent storage BEFORE transaction ─────
      // Do all file I/O outside the DB transaction to avoid locking
      final imagePathMap = await _copyImagesToAppStorage(
        extractDir: extractDir,
        questions: questionsJson,
      );

      onProgress(0.93);

      // ── 6. Save everything to DB in ONE transaction ────────────────
      await _saveToDb(
        examTypeId: int.parse(examTypeId),
        courseId: int.parse(courseId),
        exams: examsJson,
        questions: questionsJson,
        imagePathMap: imagePathMap, // pre-copied paths, no file I/O in txn
      );

      onProgress(1.0);

      // ── 7. Cleanup temp files ──────────────────────────────────────
      await zipFile.delete();
      await extractDir.delete(recursive: true);

      onComplete();
    } catch (e) {
      onError(e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Copy all images to app documents BEFORE the transaction.
  // Returns a map of imageId → destPath so the transaction can just
  // INSERT the paths without doing any file I/O.
  // ─────────────────────────────────────────────────────────────────
  Future<Map<String, _ImageMeta>> _copyImagesToAppStorage({
    required Directory extractDir,
    required List<dynamic> questions,
  }) async {
    final appDocs = await getApplicationDocumentsDirectory();
    final imgDir = Directory('${appDocs.path}/cbt_images');
    if (!await imgDir.exists()) await imgDir.create(recursive: true);

    final Map<String, _ImageMeta> result = {};

    for (final q in questions) {
      // Question image
      final qFiles = q['question_files'] as List<dynamic>? ?? [];
      for (final f in qFiles) {
        final imageId = f['file_name']?.toString();
        if (imageId != null && !result.containsKey(imageId)) {
          final meta = await _copyImage(imageId, extractDir, imgDir);
          if (meta != null) result[imageId] = meta;
        }
      }

      // Option images
      final options = q['options'] as List<dynamic>? ?? [];
      for (final opt in options) {
        final optFiles = opt['option_files'] as List<dynamic>? ?? [];
        for (final f in optFiles) {
          final imageId = f['file_name']?.toString();
          if (imageId != null && !result.containsKey(imageId)) {
            final meta = await _copyImage(imageId, extractDir, imgDir);
            if (meta != null) result[imageId] = meta;
          }
        }
      }
    }

    return result;
  }

  Future<_ImageMeta?> _copyImage(
    String imageId,
    Directory extractDir,
    Directory imgDir,
  ) async {
    try {
      final srcFile = File('${extractDir.path}/$imageId');
      if (!await srcFile.exists()) return null;

      final fileName = imageId.split('/').last;
      final destPath = '${imgDir.path}/$fileName';
      await srcFile.copy(destPath);

      final ext = fileName.split('.').last.toLowerCase();
      final mimeType = (ext == 'jpg' || ext == 'jpeg')
          ? 'image/jpeg'
          : ext == 'png'
              ? 'image/png'
              : 'image/jpeg';

      return _ImageMeta(localPath: destPath, mimeType: mimeType);
    } catch (e) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Single atomic transaction — pure DB writes, zero file I/O
  // ─────────────────────────────────────────────────────────────────
  Future<void> _saveToDb({
    required int examTypeId,
    required int courseId,
    required List<dynamic> exams,
    required List<dynamic> questions,
    required Map<String, _ImageMeta> imagePathMap,
  }) async {
    final db = await _db.database;

    // Build question lookup map once, outside transaction
    final Map<String, dynamic> questionMap = {};
    for (final q in questions) {
      questionMap[q['question_id'].toString()] = q;
    }

    await db.transaction((txn) async {
      // ── Insert images first (referenced by questions + options) ────
      for (final entry in imagePathMap.entries) {
        await txn.insert(
          'images',
          {
            'id': entry.key,
            'local_path': entry.value.localPath,
            'mime_type': entry.value.mimeType,
            'checksum': null,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // ── Insert exams ───────────────────────────────────────────────
      for (final exam in exams) {
       final examId = _toInt(exam['id']);
        final year = int.tryParse(exam['year'].toString()) ?? 0;

        final List<dynamic> questionIds =
            jsonDecode(exam['question_ids'].toString());
        final totalQuestions = questionIds.length;

        await txn.insert(
          'exams',
          {
            'id': examId,
            'exam_type_id': examTypeId,
            'course_id': courseId,
            'title': '${exam['course_name'] ?? ''} $year',
            'year': year,
            'total_questions': totalQuestions,
            'duration_minutes': 60,
            'version': 1,
            'downloaded_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // ── Insert questions for this exam ─────────────────────────
        for (final qIdRaw in questionIds) {
          final qId = qIdRaw.toString();
          final q = questionMap[qId];
          if (q == null) continue;

          final questionId = _toInt(q['question_id']);

          // Resolve question image id
          String? imageId;
          final qFiles = q['question_files'] as List<dynamic>? ?? [];
          if (qFiles.isNotEmpty) {
            imageId = qFiles[0]['file_name']?.toString();
            // Only reference if we actually copied it
            if (imageId != null && !imagePathMap.containsKey(imageId)) {
              imageId = null;
            }
          }

          await txn.insert(
            'questions',
            {
              'id': questionId,
              'exam_id': examId,
              'text': q['question_text'] ?? '',
              'image_id': imageId,
              'explanation': q['explanation'] ?? '',
              'instruction': q['instruction'] ?? '',
              'passage': q['passage'] ?? '',
              'type': q['question_type'] ?? 'multiple_choice',
              'topic': q['topic'] ?? '',
              'year': int.tryParse(q['year']?.toString() ?? '') ?? year,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          // ── Insert options ───────────────────────────────────────
          final options = q['options'] as List<dynamic>? ?? [];
          final correctText =
              (q['correct'] as Map<String, dynamic>?)?['text']?.toString() ??
                  '';

          for (final option in options) {
            final optionText = option['text']?.toString() ?? '';
            final order = _toInt(option['order']);
            final isCorrect = optionText == correctText ? 1 : 0;

            String? optImageId;
            final optFiles =
                option['option_files'] as List<dynamic>? ?? [];
            if (optFiles.isNotEmpty) {
              optImageId = optFiles[0]['file_name']?.toString();
              if (optImageId != null &&
                  !imagePathMap.containsKey(optImageId)) {
                optImageId = null;
              }
            }

            await txn.insert(
              'options',
              {
                'question_id': questionId,
                'label': _orderToLabel(order),
                'text': optionText,
                'image_id': optImageId,
                'is_correct': isCorrect,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      }
    });
  }

  int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

  // ─────────────────────────────────────────────────────────────────
  // Check if a subject is already downloaded
  // ─────────────────────────────────────────────────────────────────
  Future<bool> isSubjectDownloaded({
    required String examTypeId,
    required String courseId,
  }) async {
    final db = await _db.database;
    final result = await db.query(
      'exams',
      where: 'exam_type_id = ? AND course_id = ?',
      whereArgs: [int.parse(examTypeId), int.parse(courseId)],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  String _orderToLabel(int order) {
    const labels = ['A', 'B', 'C', 'D', 'E'];
    if (order <= 0) return 'A';
    if (order <= labels.length) return labels[order - 1];
    return order.toString();
  }

  Iterable<List<T>> _chunk<T>(List<T> items, {int size = 900}) sync* {
    for (var i = 0; i < items.length; i += size) {
      final end = (i + size < items.length) ? i + size : items.length;
      yield items.sublist(i, end);
    }
  }

}

// Simple value object — no DB or file logic
class _ImageMeta {
  final String localPath;
  final String mimeType;
  const _ImageMeta({required this.localPath, required this.mimeType});
}

