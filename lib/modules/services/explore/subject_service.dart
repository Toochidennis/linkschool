import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/explore/home/subject_model.dart';

class SubjectService {
  final String _baseUrl = kIsWeb
      ? 'https://cors-anywhere.herokuapp.com/http://www.cbtportal.linkskool.com/api/getVideo.php'
      : 'http://www.cbtportal.linkskool.com/api/getVideo.php';
  
  Future<List<Subject>> getAllSubjects() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        print("Response body: ${response.body}");
        final List<dynamic> data = json.decode(response.body);
        return data.map((subject) => Subject.fromJson(subject)).toList();
      } else {
        print("Failed to load subjects. Status Code: ${response.statusCode}");
        throw Exception("Failed to load subjects. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching subjects: $e");
      throw Exception("Error fetching subjects: $e");
    }
  }
}