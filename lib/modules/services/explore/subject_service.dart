import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../model/explore/home/subject_model2.dart';

class SubjectService {
  // Try these alternative endpoints
  final String _baseUrl = 'https://linkskool.net/api/v3/public/movies/all';

  // Alternative: 'https://linkskool.net/api/v3/movies/all'
  // Alternative: 'https://linkskool.net/api/movies/all'
    
  Future<List<SubjectModel2>> getAllSubject() async {
    try {
      final response = await http.get(
        Uri.parse("https://linkskool.net/api/v3/public/movies/all"),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print(_baseUrl);
      
      debugPrint('API Status Code: ${response.statusCode}');
      debugPrint('API Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        // Handle different response structures
        if (jsonResponse is Map<String, dynamic>) {
          // Try different possible keys
    final dynamic dataField = jsonResponse['data'] ??
                          jsonResponse['movies'] ??
                          jsonResponse['subjects'] ??
                          jsonResponse['results'];

if (dataField is List) {
  return dataField.map((item) => SubjectModel2.fromJson(item)).toList();
} else if (dataField is Map<String, dynamic>) {
  return dataField.values
      .map((item) => SubjectModel2.fromJson(item))
      .toList();
} else {
  throw Exception('Unexpected data format: ${dataField.runtimeType}');
}
        } else if (jsonResponse is List) {
          return jsonResponse.map((data) => SubjectModel2.fromJson(data)).toList();
        } else {
          throw Exception('Unexpected response format: ${jsonResponse.runtimeType}');
        }
      } else if (response.statusCode == 404) {
        throw Exception('API endpoint not found (404). Please check the URL.');
      } else {
        throw Exception('Failed to load subjects: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Service Error: $e');
      throw Exception('Error fetching subjects: $e');
    }
  }
}