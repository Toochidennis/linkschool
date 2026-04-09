import 'package:linkschool/database/cbt_db_helper.dart';
import 'package:linkschool/modules/model/explore/study/studies_questions_model.dart';

class OfflineGameQuestionService {
  static const int defaultQuestionLimit = 20;

  final CbtDbHelper _db = CbtDbHelper.instance;

  Future<QuestionsResponse> fetchQuestions({
    required int courseId,
    required int examTypeId,
    int limit = defaultQuestionLimit,
  }) async {
    final db = await _db.database;

    final examRows = await db.query(
      'exams',
      columns: ['id'],
      where: 'course_id = ? AND exam_type_id = ?',
      whereArgs: [courseId, examTypeId],
    );

    if (examRows.isEmpty) {
      return QuestionsResponse(
        statusCode: 200,
        success: true,
        message: 'No downloaded questions available for this subject.',
        data: [],
      );
    }

    final examIds = examRows
        .map((row) => row['id'] as int?)
        .whereType<int>()
        .toList(growable: false);

    if (examIds.isEmpty) {
      return QuestionsResponse(
        statusCode: 200,
        success: true,
        message: 'No downloaded questions available for this subject.',
        data: [],
      );
    }

    final examPlaceholders = List.filled(examIds.length, '?').join(',');
    final queryArgs = [...examIds];
    final limitClause = limit > 0 ? ' LIMIT ?' : '';

    if (limit > 0) {
      queryArgs.add(limit);
    }

    final questionRows = await db.rawQuery(
      '''
      SELECT q.*, e.year AS exam_year
      FROM questions q
      INNER JOIN exams e ON e.id = q.exam_id
      WHERE q.exam_id IN ($examPlaceholders)
      ORDER BY RANDOM()$limitClause
      ''',
      queryArgs,
    );

    if (questionRows.isEmpty) {
      return QuestionsResponse(
        statusCode: 200,
        success: true,
        message: 'No downloaded questions available for this subject.',
        data: [],
      );
    }

    final questionIds = questionRows
        .map((row) => row['id'] as int?)
        .whereType<int>()
        .toList(growable: false);

    final optionRows = await db.rawQuery(
      '''
      SELECT *
      FROM options
      WHERE question_id IN (${List.filled(questionIds.length, '?').join(',')})
      ORDER BY question_id ASC, label ASC
      ''',
      questionIds,
    );

    final optionsByQuestion = <int, List<Map<String, dynamic>>>{};
    for (final option in optionRows) {
      final questionId = option['question_id'] as int?;
      if (questionId == null) continue;
      optionsByQuestion
          .putIfAbsent(questionId, () => <Map<String, dynamic>>[])
          .add(Map<String, dynamic>.from(option));
    }

    final imageIds = <String>{};
    for (final question in questionRows) {
      final imageId = question['image_id']?.toString();
      if (imageId != null && imageId.isNotEmpty) {
        imageIds.add(imageId);
      }
    }

    for (final option in optionRows) {
      final imageId = option['image_id']?.toString();
      if (imageId != null && imageId.isNotEmpty) {
        imageIds.add(imageId);
      }
    }

    final imagePaths = <String, String>{};
    if (imageIds.isNotEmpty) {
      final imageRows = await db.rawQuery(
        '''
        SELECT id, local_path
        FROM images
        WHERE id IN (${List.filled(imageIds.length, '?').join(',')})
        ''',
        imageIds.toList(),
      );

      for (final image in imageRows) {
        final id = image['id']?.toString();
        final localPath = image['local_path']?.toString();
        if (id != null && localPath != null && localPath.isNotEmpty) {
          imagePaths[id] = localPath;
        }
      }
    }

    final questions = questionRows.map((row) {
      final questionId = row['id'] as int? ?? 0;
      final questionImageId = row['image_id']?.toString();
      final questionOptions = optionsByQuestion[questionId] ?? const [];

      final options = questionOptions.asMap().entries.map((entry) {
        final option = entry.value;
        final optionImageId = option['image_id']?.toString();

        return QuestionOption(
          order: entry.key,
          text: option['text']?.toString() ?? '',
          optionFiles:
              optionImageId != null && imagePaths.containsKey(optionImageId)
                  ? [imagePaths[optionImageId]!]
                  : const [],
        );
      }).toList(growable: false);

      final correctIndex = questionOptions.indexWhere(
        (option) => (option['is_correct'] as int? ?? 0) == 1,
      );

      final resolvedCorrectIndex = correctIndex >= 0 ? correctIndex : 0;
      final correctText = resolvedCorrectIndex < options.length
          ? options[resolvedCorrectIndex].text
          : '';

      return Question(
        questionId: questionId,
        questionText: row['text']?.toString() ?? '',
        questionFiles:
            questionImageId != null && imagePaths.containsKey(questionImageId)
                ? [imagePaths[questionImageId]!]
                : const [],
        topic: '',
        topicId: 0,
        passage: row['passage']?.toString() ?? '',
        passageId: 0,
        instruction: row['instruction']?.toString() ?? '',
        instructionId: null,
        explanation: row['explanation']?.toString() ?? '',
        explanationId: 0,
        questionType: row['type']?.toString() ?? 'multiple_choice',
        options: options,
        correct: CorrectAnswer(
          order: resolvedCorrectIndex,
          text: correctText,
        ),
        year: row['year']?.toString() ?? row['exam_year']?.toString() ?? '',
      );
    }).toList(growable: false);

    return QuestionsResponse(
      statusCode: 200,
      success: true,
      message: 'Downloaded questions loaded successfully.',
      data: questions,
    );
  }
}
