import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/video.dart';
import 'package:flutter/foundation.dart';
class VideoService {
  final String _BaseUrl = 'http://www.cbtportal.linkskool.com/api/getVideo.php';

Future<List<Course>> getAllCourse() async {
    try {
      final response = await http.get(Uri.parse(_BaseUrl));
      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Course.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load videos ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error fetching data: $e');
     ;
      throw Exception('Failed to load videos $e');
    }
  }

}