import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/Login/schools_model.dart';


class SchoolService {
  final String baseUrl = "https://linkskool.net/api/v3/portal/schools"; 

  Future<List<School>> fetchSchools() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> schoolsJson = data['data'] ?? [];
      return schoolsJson.map((e) => School.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load schools");
    }
  }
}
