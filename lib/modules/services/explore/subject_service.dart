import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../model/explore/home/subject_model2.dart';

class SubjectService {
  static const String _baseUrl = 'https://linkskool.net/api/v3/public/videos';

  Future<List<SubjectModel2>> getAllSubjects() async {
    try {
      final apiKey = dotenv.env['API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      debugPrint('🌐 Making request to: $_baseUrl');

      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey, // ✅ Include API key here
        },
      );

      debugPrint('📡 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        debugPrint('📊 Response Body Type: ${decoded.runtimeType}');

        if (decoded is List) {
          // ✅ When the response is a List
          return decoded.map((e) => SubjectModel2.fromJson(e)).toList();
        } else if (decoded is Map<String, dynamic>) {
          // ✅ Handle different JSON keys like data/movies/subjects/results
          final data = decoded['data'] ??
              decoded['movies'] ??
              decoded['subjects'] ??
              decoded['results'];

          if (data is List) {
            return data.map((e) => SubjectModel2.fromJson(e)).toList();
          } else if (data is Map<String, dynamic>) {
            return data.values.map((e) => SubjectModel2.fromJson(e)).toList();
          } else {
            throw Exception(
                'Unexpected data format inside response: ${data.runtimeType}');
          }
        } else {
          throw Exception('Unexpected response format: ${decoded.runtimeType}');
        }
      } else {
        debugPrint('🚨 API Error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to load subjects: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e, stackTrace) {
      debugPrint('💥 Service Error: $e');
      debugPrint(stackTrace.toString());
      throw Exception('Error fetching subjects: $e');
    }
  }
}
