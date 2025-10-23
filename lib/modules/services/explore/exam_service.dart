import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ExamService {
  static const String baseUrl = 'http://www.public.linkskool.com/api';
 
  Future<Map<String, dynamic>> fetchExamData({
    required String examType,
  }) async {
    try {
      final apiKey = dotenv.env['API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }
      
      final url = "https://linkskool.net/api/v3/public/cbt/exams/$examType/questions";
      print('🌐 Making request to: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );
      
      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        print('📊 Response body type: ${responseBody.runtimeType}');
        print('📊 Response body type: ${responseBody}');

        return responseBody;
      } else {
        print('🚨 API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load exam data: ${response.statusCode}');
      }
    } catch (e) {
      
      print('💥 Service error: $e');
      throw Exception('Error fetching exam data: $e');
    }
  }
}