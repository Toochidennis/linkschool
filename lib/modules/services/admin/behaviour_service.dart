import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../model/admin/behaviour_model.dart';

class SkillService {
  final String baseUrl = 'http://linkskool.com/developmentportal/api';

  Future<List<Skills>> getSkills() async {
    final response = await http.get(
      Uri.parse('$baseUrl/skills.php'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print(" hellllllllllooooooo i am ${response.body}");
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == "success") {
        List<dynamic> skillsJson = data['skills'];
        return skillsJson.map((json) => Skills.fromJson(json)).toList();
      } else {
        throw Exception('API returned error: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load skills: ${response.statusCode}');
    }
  }

  // Add skills to the API
  Future<void> addSkills(List<Skills> skills) async {
    final List<Map<String, String>> requestBody = skills
        .map((skill) => {
              'skill_name':
                  skill.skillName!, // Update fields to match Skills model
              'type': skill.type!,
              'level': skill.level!,
              '_db': 'linkskoo_practice', // Add any additional required fields
            })
        .toList();

    final response = await http.post(
      Uri.parse('$baseUrl/skills.php'), // Update the endpoint
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] != 'success') {
        throw Exception('Failed to add skills: ${data['message']}');
      }
    } else {
      throw Exception('Failed to add skills: ${response.statusCode}');
    }
  }

  // Delete a skill from the API
  Future<void> deleteSkill(String id) async {
    final Map<String, String> requestBody = {'id': id};

    final response = await http.delete(
      Uri.parse('$baseUrl/skills.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] != 'success') {
        throw Exception('Failed to delete skill: ${data['message']}');
      }
    } else {
      throw Exception('Failed to delete skill: ${response.statusCode}');
    }
  }
}
