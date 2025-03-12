import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:linkschool/modules/model/admin/student_model.dart';
import 'package:hive/hive.dart';

class StudentService {
  static const String _baseUrl = 'http://linkskool.com/developmentportal/api';
  static const String _dbParam = 'linkskoo_practice';

  Future<List<Student>> getStudentsByClass(String classId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/getStudents.php?class_id=$classId&_db=$_dbParam'),
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

  // Save attendance using the setAttendance API
  Future<bool> saveAttendance({
    required String classId,
    required String courseId,
    required List<int> studentIds,
    required String date,
  }) async {
    try {
      // Fetch locally persisted login data
      final userDataBox = Hive.box('userData');
      final profile = userDataBox.get('userData')?['profile'];
      final schoolProfile = userDataBox.get('userData')?['schoolProfile'];

      if (profile == null || schoolProfile == null) {
        throw Exception('Profile or school profile data not found');
      }

      final staffId = profile['id'];
      final year = schoolProfile['year'];
      final term = schoolProfile['term'];

      // Prepare the form-data payload
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/setAttendance.php'),
      );

      request.fields.addAll({
        'staff': staffId.toString(),
        'course': courseId,
        'date': date,
        'count': studentIds.length.toString(),
        'class': classId,
        'year': year.toString(),
        'term': term.toString(),
      });

      // Add student IDs and names to the register array
      for (int i = 0; i < studentIds.length; i++) {
        final studentId = studentIds[i];
        request.fields['register[$i][id]'] = studentId.toString();
        request.fields['register[$i][name]'] = 'Student $studentId'; 
      }

      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);

        if (jsonResponse['status'] == 'success') {
          return true;
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to save attendance');
        }
      } else {
        throw Exception('Failed to save attendance: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error saving attendance: $e');
      throw Exception('Error saving attendance: $e');
    }
  }
}


// // lib/services/student_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'package:linkschool/modules/model/admin/student_model.dart';


// class StudentService {
//   static const String _baseUrl = 'http://linkskool.com/developmentportal/api';
//   static const String _dbParam = 'linkskoo_practice';

//   Future<List<Student>> getStudentsByClass(String classId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/getStudents.php?class_id=$classId&_db=$_dbParam')
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         return data.map((item) => Student.fromJson(item)).toList();
//       } else {
//         throw Exception('Failed to load students: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Error fetching students: $e');
//       throw Exception('Error fetching students: $e');
//     }
//   }

//   // This method would be used to save attendance
//   Future<bool> saveAttendance({
//     required String classId, 
//     required String courseId, 
//     required List<int> studentIds,
//     required String date
//   }) async {
//     // This would be implemented to connect to your backend API
//     // For now, we'll just simulate a successful save
//     try {
//       // Simulate API call with a delay
//       await Future.delayed(const Duration(seconds: 1));
//       debugPrint('Saving attendance for course $courseId, class $classId');
//       debugPrint('Date: $date');
//       debugPrint('Student IDs present: $studentIds');
//       return true;
//     } catch (e) {
//       debugPrint('Error saving attendance: $e');
//       return false;
//     }
//   }
// }