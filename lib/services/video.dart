import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/video.dart';
import 'package:flutter/foundation.dart';
class VideoService {
  final String _BaseUrl = 'http://www.cbtportal.linkskool.com/api/getVideo.php';

Future<List<Course>> getAllCourse() async {
    try {
      print('Fetching data from API: $_BaseUrl');
      final response = await http.get(Uri.parse(_BaseUrl));
      print('Response received with status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Course.fromJson(json)).toList();
      } else {
        print('Failed to load videos, Status Code: ${response.statusCode}');
        throw Exception('Failed to load videos ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error fetching data: $e');
      print('Stack Trace: $stackTrace');
      throw Exception('Failed to load videos $e');
    }
  }

}