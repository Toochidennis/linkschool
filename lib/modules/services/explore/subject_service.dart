import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../model/explore/home/subject_model.dart';

class SubjectService {
  final String _baseUrl = kIsWeb
      ? 'https://cors-anywhere.herokuapp.com/http://www.cbtportal.linkskool.com/api/getVideo.php'
      : 'http://www.cbtportal.linkskool.com/api/getVideo.php';
  Future<List<Subject>> getAllSubject() async {
    final response = await http.get(Uri.parse(_baseUrl), headers: {
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest'
    });
    try {
      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => Subject.fromJson(data)).toList();
      } else {
        print('Error: ${response.statusCode}');
        throw Exception('Failed to load subjects');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error fetching News: $e');
    }
  }
}
