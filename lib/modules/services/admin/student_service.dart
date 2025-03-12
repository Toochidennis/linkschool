// lib/services/student_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:linkschool/modules/model/admin/student_model.dart';


class StudentService {
  static const String _baseUrl = 'http://linkskool.com/developmentportal/api';
  static const String _dbParam = 'linkskoo_practice';

  Future<List<Student>> getStudentsByClass(String classId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/getStudents.php?class_id=$classId&_db=$_dbParam')
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Student.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load students: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
      throw Exception('Error fetching students: $e');
    }
  }

  // This method would be used to save attendance
  Future<bool> saveAttendance({
    required String classId, 
    required String courseId, 
    required List<int> studentIds,
    required String date
  }) async {
    // This would be implemented to connect to your backend API
    // For now, we'll just simulate a successful save
    try {
      // Simulate API call with a delay
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('Saving attendance for course $courseId, class $classId');
      debugPrint('Date: $date');
      debugPrint('Student IDs present: $studentIds');
      return true;
    } catch (e) {
      debugPrint('Error saving attendance: $e');
      return false;
    }
  }
}