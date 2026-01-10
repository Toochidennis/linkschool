import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/explore/study/studies_questions_model.dart';
import 'package:linkschool/config/env_config.dart';

class QuestionsService {
  final String _baseUrl = "https://linkskool.net/api/v3/public";

  Future<QuestionsResponse> fetchQuestions({
    required int topicId,
    required int? courseId,
    required int? examTypeId,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }

      final url =
          "$_baseUrl/cbt/exams/questions/by-topic?topic_id=$topicId&course_id=$courseId&exam_type_id=$examTypeId";
      print("📡 Fetching Questions → $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed: ${response.body}");
      }

      final decoded = json.decode(response.body);
      return QuestionsResponse.fromJson(decoded);
    } catch (e) {
      throw Exception("Error fetching Questions: $e");
    }
  }
}
