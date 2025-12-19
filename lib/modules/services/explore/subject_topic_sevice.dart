import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/explore/study/topic_model.dart';

class SubjectTopicsService {
  final String _baseUrl = "https://linkskool.net/api/v3/public";

  Future<SyllabusResponse> fetchTopics({
    required int courseId,
    required int examTypeId,
  }) async {
    try {
      final apiKey = dotenv.env["API_KEY"];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }

      final url =
          "$_baseUrl/cbt/topics?course_id=$courseId&exam_type_id=$examTypeId";

      print("📡 Fetching Topics → $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
      );

      print("🔔 Topics Response → ${response.statusCode}");
      print("🔔 Topics Body → ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Failed: ${response.body}");
      }

      final decoded = json.decode(response.body);
      return SyllabusResponse.fromJson(decoded);
    } catch (e) {
      throw Exception("Error fetching Topics: $e");
    }
  }
}
