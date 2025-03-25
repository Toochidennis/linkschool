import 'package:flutter/foundation.dart';
import 'package:linkschool/modules/model/admin/student_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:hive/hive.dart';

class StudentService {
  final ApiService _apiService;

  StudentService(this._apiService);

  Future<List<Student>> getStudentsByClass(String classId) async {
    try {
      final response = await _apiService.get<List<Student>>(
        endpoint: 'getStudents.php',
        queryParams: {
          'class_id': classId,
          '_db': 'linkskoo_practice',
        },
        fromJson: (json) {
          if (json['data'] is List) {
            return (json['data'] as List)
                .map((item) => Student.fromJson(item))
                .toList();
          }
          return [];
        },
      );

      if (response.success) {
        return response.data ?? [];
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
      throw Exception('Error fetching students: $e');
    }
  }

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

      // Prepare the payload
      final payload = {
        'staff': staffId.toString(),
        'course': courseId,
        'date': date,
        'count': studentIds.length.toString(),
        'class': classId,
        'year': year.toString(),
        'term': term.toString(),
      };

      // Add student IDs and names to the register array
      for (int i = 0; i < studentIds.length; i++) {
        final studentId = studentIds[i];
        payload['register[$i][id]'] = studentId.toString();
        payload['register[$i][name]'] = 'Student $studentId';
      }

      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'setAttendance.php',
        body: payload,
        payloadType: PayloadType.FORM_DATA,
      );

      return response.success;
    } catch (e) {
      debugPrint('Error saving attendance: $e');
      throw Exception('Error saving attendance: $e');
    }
  }

  Future<Map<String, dynamic>> fetchStudentTerms(int studentId) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'studentTerms.php',
        body: {
          'id': studentId.toString(),
          '_db': 'linkskoo_practice',
        },
        payloadType: PayloadType.FORM_DATA,
      );

      if (response.success) {
        return response.rawData ?? {};
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      debugPrint('Error fetching student terms: $e');
      throw Exception('Error fetching student terms: $e');
    }
  }
}



// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'package:linkschool/modules/model/admin/student_model.dart';
// import 'package:hive/hive.dart';


// class StudentService {
//   static const String _baseUrl = 'http://linkskool.com/developmentportal/api';
//   static const String _dbParam = 'linkskoo_practice';

//   Future<List<Student>> getStudentsByClass(String classId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/getStudents.php?class_id=$classId&_db=$_dbParam'),
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

//   // Fetch attendance data for a specific class, date, and course
//   Future<List<int>> getAttendance({
//     required String classId,
//     required String date,
//     required String courseId,
//   }) async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//           '$_baseUrl/getAttendance.php?_db=$_dbParam&class=$classId&date=$date&course=$courseId',
//         ),
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         // Extract student IDs from the response
//         return data.map<int>((item) => item['id'] as int).toList();
//       } else {
//         throw Exception('Failed to fetch attendance: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Error fetching attendance: $e');
//       throw Exception('Error fetching attendance: $e');
//     }
//   }

//   // Save attendance using the setAttendance API
//   Future<bool> saveAttendance({
//     required String classId,
//     required String courseId,
//     required List<int> studentIds,
//     required String date,
//   }) async {
//     try {
//       // Fetch locally persisted login data
//       final userDataBox = Hive.box('userData');
//       final profile = userDataBox.get('userData')?['profile'];
//       final schoolProfile = userDataBox.get('userData')?['schoolProfile'];

//       if (profile == null || schoolProfile == null) {
//         throw Exception('Profile or school profile data not found');
//       }

//       final staffId = profile['id'];
//       final year = schoolProfile['year'];
//       final term = schoolProfile['term'];

//       // Prepare the form-data payload
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$_baseUrl/setAttendance.php'),
//       );

//       request.fields.addAll({
//         'staff': staffId.toString(),
//         'course': courseId,
//         'date': date,
//         'count': studentIds.length.toString(),
//         'class': classId,
//         'year': year.toString(),
//         'term': term.toString(),
//       });

//       // Add student IDs and names to the register array
//       for (int i = 0; i < studentIds.length; i++) {
//         final studentId = studentIds[i];
//         request.fields['register[$i][id]'] = studentId.toString();
//         request.fields['register[$i][name]'] = 'Student $studentId'; // Replace with actual student name if available
//       }

//       // Send the request
//       final response = await request.send();

//       if (response.statusCode == 200) {
//         final responseData = await response.stream.bytesToString();
//         final jsonResponse = json.decode(responseData);

//         if (jsonResponse['status'] == 'success') {
//           return true;
//         } else {
//           throw Exception(jsonResponse['message'] ?? 'Failed to save attendance');
//         }
//       } else {
//         throw Exception('Failed to save attendance: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Error saving attendance: $e');
//       throw Exception('Error saving attendance: $e');
//     }
//   }
// }



// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'package:linkschool/modules/model/admin/student_model.dart';
// import 'package:hive/hive.dart';

// class StudentService {
//   static const String _baseUrl = 'http://linkskool.com/developmentportal/api';
//   static const String _dbParam = 'linkskoo_practice';

//   Future<List<Student>> getStudentsByClass(String classId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/getStudents.php?class_id=$classId&_db=$_dbParam'),
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

//   // Save attendance using the setAttendance API
//   Future<bool> saveAttendance({
//     required String classId,
//     required String courseId,
//     required List<int> studentIds,
//     required String date,
//   }) async {
//     try {
//       // Fetch locally persisted login data
//       final userDataBox = Hive.box('userData');
//       final profile = userDataBox.get('userData')?['profile'];
//       final schoolProfile = userDataBox.get('userData')?['schoolProfile'];

//       if (profile == null || schoolProfile == null) {
//         throw Exception('Profile or school profile data not found');
//       }

//       final staffId = profile['id'];
//       final year = schoolProfile['year'];
//       final term = schoolProfile['term'];

//       // Prepare the form-data payload
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$_baseUrl/setAttendance.php'),
//       );

//       request.fields.addAll({
//         'staff': staffId.toString(),
//         'course': courseId,
//         'date': date,
//         'count': studentIds.length.toString(),
//         'class': classId,
//         'year': year.toString(),
//         'term': term.toString(),
//       });

//       // Add student IDs and names to the register array
//       for (int i = 0; i < studentIds.length; i++) {
//         final studentId = studentIds[i];
//         request.fields['register[$i][id]'] = studentId.toString();
//         request.fields['register[$i][name]'] = 'Student $studentId';
//       }

//       // Send the request
//       final response = await request.send();

//       if (response.statusCode == 200) {
//         final responseData = await response.stream.bytesToString();
//         final jsonResponse = json.decode(responseData);

//         if (jsonResponse['status'] == 'success') {
//           return true;
//         } else {
//           throw Exception(
//               jsonResponse['message'] ?? 'Failed to save attendance');
//         }
//       } else {
//         throw Exception('Failed to save attendance: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Error saving attendance: $e');
//       throw Exception('Error saving attendance: $e');
//     }
//   }

//    Future<Map<String, dynamic>> fetchStudentTerms(int studentId) async {
//     try {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$_baseUrl/studentTerms.php'),
//       );

//       // Add form-data fields
//       request.fields['id'] = studentId.toString();
//       request.fields['_db'] = _dbParam;

//       // Send the request
//       final response = await request.send();

//       // Parse the response
//       if (response.statusCode == 200) {
//         final responseData = await response.stream.bytesToString();
//         return json.decode(responseData);
//       } else {
//         throw Exception('Failed to load student terms: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Error fetching student terms: $e');
//       throw Exception('Error fetching student terms: $e');
//     }
//   }

// }