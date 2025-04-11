import 'package:flutter/foundation.dart';
import 'package:linkschool/modules/model/admin/student_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:hive/hive.dart';

class StudentService {
  final ApiService _apiService;

  StudentService(this._apiService);

  Future<List<Student>> getStudentsByClass(String classId) async {
    try {
      // Use the new API endpoint and format
      final response = await _apiService.get<List<Student>>(
        endpoint: 'portal/classes/$classId/students',
        queryParams: {
          '_db': 'aalmgzmy_linkskoo_practice',
        },
        fromJson: (json) {
          if (json['students'] is List) {
            return (json['students'] as List)
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




// import 'package:flutter/foundation.dart';
// import 'package:linkschool/modules/model/admin/student_model.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';
// import 'package:hive/hive.dart';

// class StudentService {
//   final ApiService _apiService;

//   StudentService(this._apiService);

//   Future<List<Student>> getStudentsByClass(String classId) async {
//     try {
//       final response = await _apiService.get<List<Student>>(
//         endpoint: 'getStudents.php',
//         queryParams: {
//           'class_id': classId,
//           '_db': 'linkskoo_practice',
//         },
//         fromJson: (json) {
//           if (json['data'] is List) {
//             return (json['data'] as List)
//                 .map((item) => Student.fromJson(item))
//                 .toList();
//           }
//           return [];
//         },
//       );

//       if (response.success) {
//         return response.data ?? [];
//       } else {
//         throw Exception(response.message);
//       }
//     } catch (e) {
//       debugPrint('Error fetching students: $e');
//       throw Exception('Error fetching students: $e');
//     }
//   }

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

//       // Prepare the payload
//       final payload = {
//         'staff': staffId.toString(),
//         'course': courseId,
//         'date': date,
//         'count': studentIds.length.toString(),
//         'class': classId,
//         'year': year.toString(),
//         'term': term.toString(),
//       };

//       // Add student IDs and names to the register array
//       for (int i = 0; i < studentIds.length; i++) {
//         final studentId = studentIds[i];
//         payload['register[$i][id]'] = studentId.toString();
//         payload['register[$i][name]'] = 'Student $studentId';
//       }

//       final response = await _apiService.post<Map<String, dynamic>>(
//         endpoint: 'setAttendance.php',
//         body: payload,
//         payloadType: PayloadType.FORM_DATA,
//       );

//       return response.success;
//     } catch (e) {
//       debugPrint('Error saving attendance: $e');
//       throw Exception('Error saving attendance: $e');
//     }
//   }

//   Future<Map<String, dynamic>> fetchStudentTerms(int studentId) async {
//     try {
//       final response = await _apiService.post<Map<String, dynamic>>(
//         endpoint: 'studentTerms.php',
//         body: {
//           'id': studentId.toString(),
//           '_db': 'linkskoo_practice',
//         },
//         payloadType: PayloadType.FORM_DATA,
//       );

//       if (response.success) {
//         return response.rawData ?? {};
//       } else {
//         throw Exception(response.message);
//       }
//     } catch (e) {
//       debugPrint('Error fetching student terms: $e');
//       throw Exception('Error fetching student terms: $e');
//     }
//   }
// }