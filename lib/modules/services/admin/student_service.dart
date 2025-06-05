import 'package:flutter/foundation.dart';
import 'package:linkschool/modules/model/admin/student_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:hive/hive.dart';

class StudentService {
  final ApiService _apiService;

  StudentService(this._apiService);



  Future<List<Student>> getStudentsByClass(String classId) async {
    try {
      final response = await _apiService.get<List<Student>>(
        endpoint: 'portal/classes/$classId/students',
        queryParams: {
          '_db': EnvConfig.dbName,
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
      debugPrint('Fetched ${response.data?.length ?? 0} students');
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  } catch (e) {
    debugPrint('Error fetching students: $e');
    throw Exception('Error fetching students: $e');
  }
}

  Future<List<Student>> getAllStudents() async {
    try {
      final userBox = Hive.box('userData');
      final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
      final db = loginData?['_db'] ?? EnvConfig.dbName;
      
      final response = await _apiService.get<List<Student>>(
        endpoint: 'portal/students',
        queryParams: {
          '_db': db,
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
      debugPrint('Error fetching all students: $e');
      throw Exception('Error fetching all students: $e');
    }
  }

  Future<List<Student>> getStudentsByCourse(String courseId, String classId) async {
    try {
      final userBox = Hive.box('userData');
      final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
      final db = loginData?['_db'] ?? EnvConfig.dbName;

      final response = await _apiService.get<List<Student>>(
        endpoint: 'portal/courses/$courseId/students',
        queryParams: {
          '_db': db,
          'year': '2024',
          'term': '1',
          'class_id': classId,
        },
        fromJson: (json) {
          if (json['data'] is List) {
            return (json['data'] as List)
                .map((item) => Student.fromJson({
                      'id': item['id'],
                      'name': item['student_name'],
                    }))
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
      debugPrint('Error fetching students by course: $e');
      throw Exception('Error fetching students by course: $e');
    }
  }

  Future<Map<String, dynamic>> getStudentResultTerms(int studentId) async {
    try {
      final userBox = Hive.box('userData');
      final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
      final db = loginData?['_db'] ?? EnvConfig.dbName;
      
      final response = await _apiService.get(
        endpoint: 'portal/students/$studentId/result-terms',
        queryParams: {
          '_db': db,
        },
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
            'terms': terms.map((term) => {
              'term': term['term_value'],
              'term_name': term['term_name'],
              'average_score': term['average_score']
            }).toList()
          };
        }
        
        return formattedData;
      } else {
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
      
      final register = selectedStudents
          .map((student) => {
                'id': student.id,
                'name': student.name,
              })
          .toList();

      final payload = {
        '_db': EnvConfig.dbName,
        'year': year,
        'term': term,
        'date': formattedDate,
        'staff_id': staffId,
        'count': studentIds.length,
        'register': register,
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
      
      final register = selectedStudents
          .map((student) => {
                'id': student.id,
                'name': student.name,
              })
          .toList();

      final payload = {
        '_db': EnvConfig.dbName,
        'year': year,
        'term': term,
        'date': formattedDate,
        'staff_id': staffId,
        'count': studentIds.length,
        'class': classId,
        'register': register,
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
      debugPrint('Fetching course attendance with date: $date');
      
      final response = await _apiService.get<List<Map<String, dynamic>>>(
        endpoint: 'portal/courses/$courseId/attendance',
        queryParams: {
          '_db': EnvConfig.dbName,
          'date': date,
          'class_id': classId,
        },
        fromJson: (json) {
          debugPrint('Course Attendance API response: $json');
          if (json.containsKey('attendance_records')) {
            var records = json['attendance_records'];
            
            if (records is List) {
              return records.map((item) => item as Map<String, dynamic>).toList();
            } else if (records is Map<String, dynamic>) {
              return [records];
            }
          }
          return [];
        },
      );

      if (response.success) {
        return response.data ?? [];
      } else {
        debugPrint('API Error: ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      debugPrint('Error fetching course attendance records: $e');
      throw Exception('Error fetching course attendance records: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getClassAttendance({
    required String classId,
    required String date,
  }) async {
    try {
      debugPrint('Fetching attendance with date: $date');
      
      final response = await _apiService.get<List<Map<String, dynamic>>>(
        endpoint: 'portal/classes/$classId/attendance',
        queryParams: {
          '_db': EnvConfig.dbName,
          'date': date,
        },
        fromJson: (json) {
          debugPrint('Attendance API response: $json');
          if (json.containsKey('attendance_records')) {
            var records = json['attendance_records'];
            
            if (records is List) {
              return records.map((item) => item as Map<String, dynamic>).toList();
            } else if (records is Map<String, dynamic>) {
              return [records];
            }
          }
          return [];
        },
      );

      if (response.success) {
        return response.data ?? [];
      } else {
        debugPrint('API Error: ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      debugPrint('Error fetching attendance records: $e');
      throw Exception('Error fetching attendance records: $e');
    }
  }

  Future<bool> updateAttendance({
    required int attendanceId,
    required List<int> studentIds,
    required List<Student> selectedStudents,
  }) async {
    try {
      final userDataBox = Hive.box('userData');
      final userData = userDataBox.get('userData');
      
      if (userData == null) {
        throw Exception('User data not found');
      }
      
      final profile = userData['data']['profile'];

      if (profile == null) {
        throw Exception('Profile data not found');
      }

      final staffId = profile['staff_id'];
      
      final register = selectedStudents
          .map((student) => {
                'id': student.id,
                'name': student.name,
              })
          .toList();

      final payload = {
        '_db': EnvConfig.dbName,
        'staff_id': staffId,
        'count': studentIds.length,
        'register': register,
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
}




// import 'package:flutter/foundation.dart';
// import 'package:linkschool/modules/model/admin/student_model.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';
// import 'package:linkschool/config/env_config.dart';
// import 'package:hive/hive.dart';

// class StudentService {
//   final ApiService _apiService;

//   StudentService(this._apiService);

//   Future<List<Student>> getStudentsByClass(String classId) async {
//     try {
//       // Use the dynamic DB name from environment config
//       final response = await _apiService.get<List<Student>>(
//         endpoint: 'portal/classes/$classId/students',
//         queryParams: {
//           '_db': EnvConfig.dbName,
//         },
//         fromJson: (json) {
//           if (json['students'] is List) {
//             return (json['students'] as List)
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

//   // method to fetch all students
//   Future<List<Student>> getAllStudents() async {
//     try {
//       final userBox = Hive.box('userData');
//       final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
//       final db = loginData?['_db'] ?? EnvConfig.dbName;
      
//       final response = await _apiService.get<List<Student>>(
//         endpoint: 'portal/students',
//         queryParams: {
//           '_db': db,
//         },
//         fromJson: (json) {
//           if (json['students'] is List) {
//             return (json['students'] as List)
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
//       debugPrint('Error fetching all students: $e');
//       throw Exception('Error fetching all students: $e');
//     }
//   }

// Future<Map<String, dynamic>> getStudentResultTerms(int studentId) async {
//   try {
//     final userBox = Hive.box('userData');
//     final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
//     final db = loginData?['_db'] ?? EnvConfig.dbName;
    
//     final response = await _apiService.get(
//       endpoint: 'portal/students/$studentId/result-terms',
//       queryParams: {
//         '_db': db,
//       },
//     );

//     if (response.success) {
//       final resultTerms = response.rawData?['result_terms'];
      
//       if (resultTerms == null || resultTerms.isEmpty) {
//         return {};
//       }
      
//       // Transform the data to match the expected format
//       Map<String, dynamic> formattedData = {};
      
//       for (var yearData in resultTerms) {
//         final year = yearData['year'].toString();
//         final terms = yearData['terms'] as List;
        
//         formattedData[year] = {
//           'terms': terms.map((term) => {
//             'term': term['term_value'],
//             'term_name': term['term_name'],
//             'average_score': term['average_score']
//           }).toList()
//         };
//       }
      
//       return formattedData;
//     } else {
//       throw Exception(response.message);
//     }
//   } catch (e) {
//     debugPrint('Error fetching student result terms: $e');
//     throw Exception('Error fetching student result terms: $e');
//   }
// }

//   Future<bool> saveAttendance({
//     required String classId,
//     required String courseId,
//     required List<int> studentIds,
//     required String date,
//     required List<Student> selectedStudents,
//   }) async {
//     try {
//       // Fetch locally persisted login data
//       final userDataBox = Hive.box('userData');
//       final userData = userDataBox.get('userData');
      
//       if (userData == null) {
//         throw Exception('User data not found');
//       }
      
//       final profile = userData['data']['profile'];
//       final settings = userData['data']['settings'];

//       if (profile == null || settings == null) {
//         throw Exception('Profile or settings data not found');
//       }

//       final staffId = profile['staff_id'];
//       final year = settings['year'];
//       final term = settings['term'];
      
//       // Format date for API: YYYY-MM-DD 00:00:00
//     final dateParts = date.split(' ');
//     final dateOnly = dateParts[0]; // Get just the date part
//     final formattedDate = "$dateOnly 00:00:00";

      
//       // Build register array with student IDs and names
//       final register = selectedStudents
//           .map((student) => {
//                 'id': student.id,
//                 'name': student.name,
//               })
//           .toList();

//       // Prepare the payload according to API requirements
//       final payload = {
//         '_db': EnvConfig.dbName,
//         'year': year,
//         'term': term,
//         'date': formattedDate, // properly formatted date
//         'staff_id': staffId,
//         'count': studentIds.length,
//         'register': register,
//       };

//       debugPrint('Saving attendance with payload: $payload');

//       final response = await _apiService.post<Map<String, dynamic>>(
//         endpoint: 'portal/classes/$classId/attendance',
//         body: payload,
//         payloadType: PayloadType.JSON,
//       );

//       if (!response.success) {
//         debugPrint('API Error: ${response.message}');
//       }

//       return response.success;
//     } catch (e) {
//       debugPrint('Error saving attendance: $e');
//       throw Exception('Error saving attendance: $e');
//     }
//   }


// Future<bool> saveCourseAttendance({
//   required String classId,
//   required String courseId,
//   required List<int> studentIds,
//   required String date,
//   required List<Student> selectedStudents,
// }) async {
//   try {
//     // Fetch locally persisted login data
//     final userDataBox = Hive.box('userData');
//     final userData = userDataBox.get('userData');
    
//     if (userData == null) {
//       throw Exception('User data not found');
//     }
    
//     final profile = userData['data']['profile'];
//     final settings = userData['data']['settings'];

//     if (profile == null || settings == null) {
//       throw Exception('Profile or settings data not found');
//     }

//     final staffId = profile['staff_id'];
//     final year = settings['year'];
//     final term = settings['term'];
    
//     // Format date for API: YYYY-MM-DD 00:00:00
//     final dateOnly = date.split(' ')[0];
//     final formattedDate = "$dateOnly 00:00:00";
    
//     // Build register array with student IDs and names
//     final register = selectedStudents
//         .map((student) => {
//               'id': student.id,
//               'name': student.name,
//             })
//         .toList();

//     // Prepare the payload according to API requirements
//     final payload = {
//       '_db': EnvConfig.dbName,
//       'year': year,
//       'term': term,
//       'date': formattedDate,
//       'staff_id': staffId,
//       'count': studentIds.length,
//       'class': classId,
//       'register': register,
//     };

//     debugPrint('Saving course attendance with payload: $payload');

//     final response = await _apiService.post<Map<String, dynamic>>(
//       endpoint: 'portal/courses/$courseId/attendance',
//       body: payload,
//       payloadType: PayloadType.JSON,
//     );

//     if (!response.success) {
//       debugPrint('API Error: ${response.message}');
//     }

//     return response.success;
//   } catch (e) {
//     debugPrint('Error saving course attendance: $e');
//     throw Exception('Error saving course attendance: $e');
//   }
// }

// Future<List<Map<String, dynamic>>> getCourseAttendance({
//   required String classId,
//   required String date,
//   required String courseId,
// }) async {
//   try {
//     debugPrint('Fetching course attendance with date: $date');
    
//     final response = await _apiService.get<List<Map<String, dynamic>>>(
//       endpoint: 'portal/courses/$courseId/attendance',
//       queryParams: {
//         '_db': EnvConfig.dbName,
//         'date': date,
//         'class_id': classId,
//       },
//       fromJson: (json) {
//         debugPrint('Course Attendance API response: $json');
//         if (json.containsKey('attendance_records')) {
//           var records = json['attendance_records'];
          
//           // Handle both array and object responses
//           if (records is List) {
//             return records.map((item) => item as Map<String, dynamic>).toList();
//           } else if (records is Map<String, dynamic>) {
//             // If it's a single object, wrap it in a list
//             return [records];
//           }
//         }
//         return [];
//       },
//     );

//     if (response.success) {
//       return response.data ?? [];
//     } else {
//       debugPrint('API Error: ${response.message}');
//       throw Exception(response.message);
//     }
//   } catch (e) {
//     debugPrint('Error fetching course attendance records: $e');
//     throw Exception('Error fetching course attendance records: $e');
//   }
// }

//   Future<List<Map<String, dynamic>>> getClassAttendance({
//     required String classId,
//     required String date,
//   }) async {
//     try {
//       // // Ensure date is in the right format - the API expects YYYY-MM-DD 00:00:00
//       // final dateForApi = date; // Already formatted correctly in the provider
      
//       debugPrint('Fetching attendance with date: $date');
      
//       final response = await _apiService.get<List<Map<String, dynamic>>>(
//         endpoint: 'portal/classes/$classId/attendance',
//         queryParams: {
//           '_db': EnvConfig.dbName,
//           'date': date,
//         },
//         fromJson: (json) {
//           debugPrint('Attendance API response: $json');
//           if (json.containsKey('attendance_records')) {
//             var records = json['attendance_records'];
            
//             // Handle both array and object responses
//             if (records is List) {
//               return records.map((item) => item as Map<String, dynamic>).toList();
//             } else if (records is Map<String, dynamic>) {
//               // If it's a single object, wrap it in a list
//               return [records];
//             }
//           }
//           return [];
//         },
//       );

//       if (response.success) {
//         return response.data ?? [];
//       } else {
//         debugPrint('API Error: ${response.message}');
//         throw Exception(response.message);
//       }
//     } catch (e) {
//       debugPrint('Error fetching attendance records: $e');
//       throw Exception('Error fetching attendance records: $e');
//     }
//   }

// Future<bool> updateAttendance({
//   required int attendanceId,
//   required List<int> studentIds,
//   required List<Student> selectedStudents,
// }) async {
//   try {
//     // Fetch locally persisted login data
//     final userDataBox = Hive.box('userData');
//     final userData = userDataBox.get('userData');
    
//     if (userData == null) {
//       throw Exception('User data not found');
//     }
    
//     final profile = userData['data']['profile'];

//     if (profile == null) {
//       throw Exception('Profile data not found');
//     }

//     final staffId = profile['staff_id'];
    
//     // Build register array with student IDs and names
//     final register = selectedStudents
//         .map((student) => {
//               'id': student.id,
//               'name': student.name,
//             })
//         .toList();

//     // Prepare the payload according to API requirements
//     final payload = {
//       '_db': EnvConfig.dbName,
//       'staff_id': staffId,
//       'count': studentIds.length,
//       'register': register,
//     };

//     debugPrint('Updating attendance with payload: $payload');

//     // Use the existing put method from ApiService
//     final response = await _apiService.put<Map<String, dynamic>>(
//       endpoint: 'portal/attendance/$attendanceId',
//       body: payload,
//       payloadType: PayloadType.JSON,
//     );

//     if (!response.success) {
//       debugPrint('API Error: ${response.message}');
//     }

//     return response.success;
//   } catch (e) {
//     debugPrint('Error updating attendance: $e');
//     throw Exception('Error updating attendance: $e');
//   }
// }
// }