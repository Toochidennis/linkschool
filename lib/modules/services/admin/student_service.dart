import 'package:flutter/foundation.dart';
import 'package:linkschool/modules/model/admin/student_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:hive/hive.dart';

class StudentService {
  final ApiService _apiService;

  StudentService(this._apiService);

  // Helper method to set the auth token from Hive
  Future<void> _setAuthToken() async {
    try {
      final userBox = Hive.box('userData');
      final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
      if (loginData == null) {
        debugPrint('Error: No user data found in Hive');
        throw Exception('No user data found');
      }

      final token = loginData['token']?.toString();
      if (token == null || token.isEmpty) {
        debugPrint('Error: No auth token found in user data');
        throw Exception('No auth token found');
      }

      _apiService.setAuthToken(token);
      debugPrint('Auth token set successfully');
    } catch (e) {
      debugPrint('Error setting auth token: $e');
      throw Exception('Failed to set auth token: $e');
    }
  }

  // Helper method to get year and term from user settings
  Map<String, String> _getYearAndTerm() {
    try {
      final userBox = Hive.box('userData');
      final loginData = userBox.get('userData') ?? userBox.get('loginResponse');

      if (loginData != null) {
        final settings = loginData['data']?['settings'];
        if (settings != null) {
          return {
            'year': settings['year']?.toString() ?? '2025',
            'term': settings['term']?.toString() ?? '3',
          };
        }
      }

      // Fallback values
      return {'year': '2025', 'term': '3'};
    } catch (e) {
      debugPrint('Error getting year and term: $e');
      return {'year': '2025', 'term': '3'};
    }
  }

  Future<List<Student>> getStudentsByClass(String classId) async {
    try {
      await _setAuthToken();

      // Database parameter will be automatically added by ApiService
      final response = await _apiService.get<List<Student>>(
        endpoint: 'portal/classes/$classId/students',
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
        debugPrint('Fetched ${response.data?.length ?? 0} students');
        return response.data ?? [];
      } else {
        debugPrint('API error: ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
      throw Exception('Error fetching students: $e');
    }
  }

  Future<List<Student>> getAllStudents() async {
    try {
      await _setAuthToken();

      // Database parameter will be automatically added by ApiService
      final response = await _apiService.get<List<Student>>(
        endpoint: 'portal/students',
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
        debugPrint('API error: ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      debugPrint('Error fetching all students: $e');
      throw Exception('Error fetching all students: $e');
    }
  }

  Future<List<Student>> getStudentsByCourse(
      String courseId, String classId) async {
    try {
      await _setAuthToken();
      final settings = _getYearAndTerm();

      // Database parameter will be automatically added by ApiService
      final response = await _apiService.get<List<Student>>(
        endpoint: 'portal/courses/$courseId/students',
        queryParams: {
          'year': settings['year']!,
          'term': settings['term']!,
          'class_id': classId,
        },
        fromJson: (json) {
          if (json['data'] is List) {
            return (json['data'] as List)
                .map((item) => Student.fromJson({
                      'id': item['id'],
                      'student_name': item['student_name'],
                    }))
                .toList();
          }
          return [];
        },
      );

      if (response.success) {
        debugPrint(
            'Fetched ${response.data?.length ?? 0} students for course $courseId, year ${settings['year']}, term ${settings['term']}');
        return response.data ?? [];
      } else {
        debugPrint('API error: ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      debugPrint('Error fetching students by course: $e');
      throw Exception('Error fetching students by course: $e');
    }
  }

  Future<Map<String, dynamic>> getStudentResultTerms(int studentId) async {
    try {
      await _setAuthToken();

      // Database parameter will be automatically added by ApiService
      final response = await _apiService.get(
        endpoint: 'portal/students/$studentId/result-terms',
      );

      if (response.success) {
        final resultTerms = response.rawData?['result_terms'];
        if (resultTerms == null || resultTerms.isEmpty) {
          return {};
        }

        Map<String, dynamic> formattedData = {};
        for (var yearData in resultTerms) {
          final year = yearData['year'].toString();
          final terms = yearData['terms'] as List;
          formattedData[year] = {
            'terms': terms
                .map((term) => {
                      'term': term['term_value'],
                      'term_name': term['term_name'],
                      'average_score': term['average_score']
                    })
                .toList()
          };
        }
        return formattedData;
      } else {
        debugPrint('API error: ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      debugPrint('Error fetching student result terms: $e');
      throw Exception('Error fetching student result terms: $e');
    }
  }

  Future<bool> saveAttendance({
    required String classId,
    required String courseId,
    required List<int> studentIds,
    required String date,
    required List<Student> selectedStudents,
  }) async {
    try {
      await _setAuthToken();
      final userDataBox = Hive.box('userData');
      final userData = userDataBox.get('userData');
      if (userData == null) {
        throw Exception('User data not found');
      }

      final profile = userData['data']['profile'];
      final settings = userData['data']['settings'];
      if (profile == null || settings == null) {
        throw Exception('Profile or settings data not found');
      }

      final staffId = profile['staff_id'];
      final year = settings['year'];
      final term = settings['term'];

      final dateParts = date.split(' ');
      final dateOnly = dateParts[0];
      final formattedDate = "$dateOnly 00:00:00";

      final students = selectedStudents
          .map((student) => {
                'id': student.id,
                'name': student.name,
              })
          .toList();

      final payload = {
        'year': year,
        'term': term,
        'attendance_date': formattedDate,
        'staff_id': staffId,
        'attendance_count': studentIds.length,
        'students': students,
        // Database parameter will be automatically added by ApiService
      };

      debugPrint('Saving attendance with payload: $payload');

      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/classes/$classId/attendance',
        body: payload,
        payloadType: PayloadType.JSON,
      );

      if (!response.success) {
        debugPrint('API Error: ${response.message}');
      }

      return response.success;
    } catch (e) {
      debugPrint('Error saving attendance: $e');
      throw Exception('Error saving attendance: $e');
    }
  }

  Future<bool> saveCourseAttendance({
    required String classId,
    required String courseId,
    required List<int> studentIds,
    required String date,
    required List<Student> selectedStudents,
  }) async {
    try {
      await _setAuthToken();
      final userDataBox = Hive.box('userData');
      final userData = userDataBox.get('userData');
      if (userData == null) {
        throw Exception('User data not found');
      }

      final profile = userData['data']['profile'];
      final settings = userData['data']['settings'];
      if (profile == null || settings == null) {
        throw Exception('Profile or settings data not found');
      }

      final staffId = profile['staff_id'];
      final year = settings['year'];
      final term = settings['term'];

      final dateOnly = date.split(' ')[0];
      final formattedDate = "$dateOnly 00:00:00";

      final students = selectedStudents
          .map((student) => {
                'id': student.id,
                'name': student.name,
              })
          .toList();

      final payload = {
        'year': year,
        'term': term,
        'attendance_date': formattedDate,
        'staff_id': staffId,
        'attendance_count': studentIds.length,
        'class_id': int.parse(classId),
        'students': students,
        // Database parameter will be automatically added by ApiService
      };

      debugPrint('Saving course attendance with payload: $payload');

      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/courses/$courseId/attendance',
        body: payload,
        payloadType: PayloadType.JSON,
      );

      if (!response.success) {
        debugPrint('API Error: ${response.message}');
      }

      return response.success;
    } catch (e) {
      debugPrint('Error saving course attendance: $e');
      throw Exception('Error saving course attendance: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCourseAttendance({
    required String classId,
    required String date,
    required String courseId,
  }) async {
    try {
      await _setAuthToken();
      final yearAndTerm = _getYearAndTerm();

      debugPrint('Fetching course attendance with date: $date');

      // Database parameter will be automatically added by ApiService
      final response = await _apiService.get<List<Map<String, dynamic>>>(
        endpoint: 'portal/courses/$courseId/attendance/single',
        queryParams: {
          'attendance_date': date,
          'class_id': classId,
          'year': yearAndTerm['year']!,
          'term': yearAndTerm['term']!,
        },
        fromJson: (json) {
          debugPrint('Course Attendance API response: $json');

          if (json.containsKey('data') && json['data'] != null) {
            final data = json['data'];
            if (data is Map<String, dynamic>) {
              return [data];
            }
          }
          return [];
        },
      );

      if (response.success) {
        return response.data ?? [];
      } else {
        // Handle 404 as a normal case (no attendance records exist yet)
        if (response.statusCode == 404 ||
            response.message.contains('No attendance records found')) {
          debugPrint(
              'No attendance records found for course $courseId on $date - this is normal');
          return [];
        }
        debugPrint('API Error: ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      // Check if it's a "no records found" error
      if (e.toString().contains('No attendance records found')) {
        debugPrint(
            'No attendance records found for course $courseId on $date - returning empty list');
        return [];
      }
      debugPrint('Error fetching course attendance records: $e');
      throw Exception('Error fetching course attendance records: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getClassAttendance({
    required String classId,
    required String date,
  }) async {
    try {
      await _setAuthToken();
      final yearAndTerm = _getYearAndTerm();

      debugPrint('Fetching class attendance with date: $date');

      // Database parameter will be automatically added by ApiService
      final response = await _apiService.get<List<Map<String, dynamic>>>(
        endpoint: 'portal/classes/$classId/attendance/single',
        queryParams: {
          'attendance_date': date,
          'year': yearAndTerm['year']!,
          'term': yearAndTerm['term']!,
        },
        fromJson: (json) {
          debugPrint('Class Attendance API response: $json');

          if (json.containsKey('data') && json['data'] != null) {
            final data = json['data'];
            if (data is Map<String, dynamic>) {
              return [data];
            }
          }
          return [];
        },
      );

      if (response.success) {
        return response.data ?? [];
      } else {
        // Handle 404 as a normal case (no attendance records exist yet)
        if (response.statusCode == 404 ||
            response.message.contains('No attendance records found')) {
          debugPrint(
              'No attendance records found for class $classId on $date - this is normal');
          return [];
        }
        debugPrint('API Error: ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      // Check if it's a "no records found" error
      if (e.toString().contains('No attendance records found')) {
        debugPrint(
            'No attendance records found for class $classId on $date - returning empty list');
        return [];
      }
      debugPrint('Error fetching class attendance records: $e');
      throw Exception('Error fetching class attendance records: $e');
    }
  }

  Future<bool> updateAttendance({
    required int attendanceId,
    required List<int> studentIds,
    required List<Student> selectedStudents,
  }) async {
    try {
      await _setAuthToken();
      final userDataBox = Hive.box('userData');
      final userData = userDataBox.get('userData');
      if (userData == null) {
        throw Exception('User data not found');
      }

      final profile = userData['data']['profile'];
      final settings = userData['data']['settings'];
      if (profile == null || settings == null) {
        throw Exception('Profile or settings data not found');
      }

      final staffId = profile['staff_id'];
      final year = settings['year'];
      final term = settings['term'];

      final students = selectedStudents
          .map((student) => {
                'id': student.id,
                'name': student.name,
              })
          .toList();

      final payload = {
        'year': year,
        'term': term,
        'staff_id': staffId,
        'attendance_count': studentIds.length,
        'students': students,
        // Database parameter will be automatically added by ApiService
      };

      debugPrint('Updating attendance with payload: $payload');

      final response = await _apiService.put<Map<String, dynamic>>(
        endpoint: 'portal/attendance/$attendanceId',
        body: payload,
        payloadType: PayloadType.JSON,
      );

      if (!response.success) {
        debugPrint('API Error: ${response.message}');
      }

      return response.success;
    } catch (e) {
      debugPrint('Error updating attendance: $e');
      throw Exception('Error updating attendance: $e');
    }
  }

  Future<Map<String, dynamic>> getStudentTermResults({
    required int studentId,
    required int termId,
    required String classId,
    required String year,
    required String levelId,
  }) async {
    try {
      await _setAuthToken();

      debugPrint(
          'Making API call to: portal/students/$studentId/result/$termId '
          'with queryParams: class_id=$classId, '
          'year=$year, level_id=$levelId');

      // Database parameter will be automatically added by ApiService
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: 'portal/students/$studentId/result/$termId',
        queryParams: {
          'class_id': classId,
          'year': year,
          'level_id': levelId,
        },
        fromJson: (json) {
          debugPrint('Raw API response: $json');
          return json['response'] as Map<String, dynamic>? ?? {};
        },
      );

      if (response.success) {
        debugPrint('Fetched term results: ${response.data}');
        return response.data ?? {};
      } else {
        debugPrint('API error: ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      debugPrint('Error fetching student term results: $e');
      throw Exception('Error fetching student term results: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getStudentAnnualResults({
    required int studentId,
    required String classId,
    required String levelId,
    required String year,
  }) async {
    try {
      await _setAuthToken();

      debugPrint('Making API call to: portal/students/$studentId/result/annual '
          'with queryParams: class_id=$classId, '
          'year=$year, level_id=$levelId');

      // Database parameter will be automatically added by ApiService
      final response = await _apiService.get<List<Map<String, dynamic>>>(
        endpoint: 'portal/students/$studentId/result/annual',
        queryParams: {
          'class_id': classId,
          'year': year,
          'level_id': levelId,
        },
        fromJson: (json) {
          debugPrint('Raw API response: $json');
          if (json['response'] is List) {
            return (json['response'] as List)
                .map((item) => item as Map<String, dynamic>)
                .toList();
          }
          return [];
        },
      );

      if (response.success) {
        debugPrint('Fetched annual results: ${response.data}');
        return response.data ?? [];
      } else {
        debugPrint('API error: ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      debugPrint('Error fetching student annual results: $e');
      throw Exception('Error fetching student annual results: $e');
    }
  }

  void throwException(String s) {}
}
