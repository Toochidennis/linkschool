import 'package:flutter/material.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/utils/registration/subject_selection.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:linkschool/modules/common/custom_toaster.dart';


class CourseRegistrationService {
  final ApiService _apiService = locator<ApiService>();
  
  Future<bool> registerCourses({
    required String classId,
    required int year,
    required int term,
    required List<Map<String, dynamic>> courses,
  }) async {
    try {
      // Validate classId
      if (classId.isEmpty) {
        print('Error: Class ID is empty');
        return false;
      }
      
      // Debug the incoming courses
      print('Raw courses received: $courses');
      
      // Transform and ensure courses match API expected format with proper types
      List<Map<String, dynamic>> registeredCourses = [];
      
      for (var rawCourse in courses) {
        // Explicitly convert each course to the right format
        Map<String, dynamic> typedCourse = Map<String, dynamic>.from(rawCourse);
        
        // Extract course_id carefully
        dynamic courseIdValue = typedCourse["id"] ?? typedCourse["course_id"];
        int courseId;
        
        if (courseIdValue is int) {
          courseId = courseIdValue;
        } else if (courseIdValue is String) {
          courseId = int.parse(courseIdValue);
        } else {
          print('Invalid course ID type: ${courseIdValue.runtimeType}');
          continue; // Skip this course
        }
        
        // Extract course name
        String courseName = typedCourse["name"]?.toString() ?? "";
        
        // Add to registered courses list
        registeredCourses.add({
          "course_id": courseId,
          "name": courseName
        });
      }
      
      final Map<String, dynamic> payload = {
        "year": year,
        "term": term,
        "registered_courses": registeredCourses,
        "_db": EnvConfig.dbName
      };
      
      // Print payload for debugging
      print('Sending payload: ${json.encode(payload)}');
      
      final response = await _apiService.post(
        endpoint: 'portal/classes/$classId/course-registrations',
        body: payload,
      );
      
      // Print response for debugging
      print('Response: ${response.statusCode} - ${response.message}');
      
      return response.success;
    } catch (e) {
      print('Error registering courses: $e');
      return false;
    }
  }

  // New method to fetch registered courses for a class
  Future<List<Map<String, dynamic>>> getRegisteredCourses({
    required String classId,
    required int year,
    required int term,
  }) async {
    try {
      // Validate classId
      if (classId.isEmpty) {
        print('Error: Class ID is empty');
        return [];
      }

      final Map<String, dynamic> queryParams = {
        "_db": EnvConfig.dbName,
        "year": year.toString(),
        "term": term.toString(),
      };

      print('Fetching registered courses for class: $classId');
      print('Query params: $queryParams');

      final response = await _apiService.get(
        endpoint: 'portal/classes/$classId/registered-courses',
        queryParams: queryParams,
      );

      print('Get registered courses response: ${response.statusCode} - ${response.message}');

      if (response.success && response.rawData != null) {
        final data = response.rawData!['data'];
        if (data is List) {
          // Convert the response data to the expected format
          return data.map((course) {
            if (course is Map<String, dynamic>) {
              return {
                'id': course['course_id'],
                'course_name': course['course_name'],
              };
            }
            return <String, dynamic>{};
          }).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching registered courses: $e');
      return [];
    }
  }
}

void showRegistrationDialog(BuildContext context, {required String classId}) {
  // Initialize selected courses list with proper typing
  List<Map<String, dynamic>> selectedCourses = [];
  final courseRegistrationService = CourseRegistrationService();
  
  // Validate class ID before proceeding
  if (classId.isEmpty) {
    CustomToaster.toastError(
      context,
      'Configuration Error',
      'Class ID is missing or invalid',
    );
    return;
  }
  
  print('Opening registration dialog for class ID: $classId');
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _getRegisteredCoursesWithSettings(courseRegistrationService, classId),
            builder: (context, snapshot) {
              final List<Map<String, dynamic>> registeredCourses = snapshot.data ?? [];
              
              return Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Select courses to register',
                        style: AppTextStyles.normal600(
                            fontSize: 18, color: AppColors.backgroundDark),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Pass callback to receive selected courses and pre-registered courses
                      SubjectSelection(
                        preRegisteredCourses: registeredCourses,
                        onCoursesSelected: (courses) {
                          // Ensure we're working with List<Map<String, dynamic>>
                          selectedCourses = List<Map<String, dynamic>>.from(
                            courses.map((dynamic course) {
                              if (course is Map) {
                                return Map<String, dynamic>.from(course);
                              }
                              return <String, dynamic>{}; // Empty map as fallback
                            }).toList()
                          );
                          
                          // Debug the selected courses
                          print('Selected courses (updated): $selectedCourses');
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.videoColor4,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Register',
                          style: AppTextStyles.normal600(
                              fontSize: 16, color: AppColors.backgroundLight),
                        ),
                        onPressed: () async {
                          if (selectedCourses.isEmpty) {
                            // Show a warning toast if no courses are selected
                            CustomToaster.toastWarning(
                              context,
                              'Selection Required',
                              'Please select at least one course to register',
                            );
                            return;
                          }
                          
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                          
                          try {
                            // Get settings data from Hive
                            final userBox = Hive.box('userData');
                            final dynamic rawSettings = userBox.get('settings');
                            
                            if (rawSettings == null) {
                              throw Exception('Settings data not found');
                            }
                            
                            // Ensure proper type casting from Hive
                            // This is critical as Hive often returns Map<dynamic, dynamic>
                            final Map<String, dynamic> typedSettings;
                            
                            if (rawSettings is Map) {
                              typedSettings = Map<String, dynamic>.from(rawSettings);
                            } else {
                              throw Exception('Invalid settings format');
                            }
                            
                            // Get the year and term with proper error handling
                            int year;
                            int term;
                            
                            try {
                              // Handle year
                              if (typedSettings['year'] is int) {
                                year = typedSettings['year'];
                              } else {
                                year = int.parse(typedSettings['year']?.toString() ?? '2025');
                              }
                              
                              // Handle term
                              if (typedSettings['term'] is int) {
                                term = typedSettings['term'];
                              } else {
                                term = int.parse(typedSettings['term']?.toString() ?? '3');
                              }
                            } catch (e) {
                              // Fallback values if parsing fails
                              print('Error parsing settings: $e');
                              year = 2025;
                              term = 3;
                            }
                            
                            // Print debug information
                            print('Registering courses for class ID: $classId');
                            print('Year: $year, Term: $term');
                            print('Selected courses: $selectedCourses');
                            
                            // Call API to register courses
                            final success = await courseRegistrationService.registerCourses(
                              classId: classId,
                              year: year,
                              term: term,
                              courses: selectedCourses,
                            );
                            
                            // Close loading dialog
                            Navigator.pop(context);
                            
                            if (success) {
                              // Close registration dialog
                              Navigator.pop(context);
                              
                              // Show success toast
                              CustomToaster.toastSuccess(
                                context,
                                'Success',
                                'Courses registered successfully',
                              );
                            } else {
                              // Show error toast
                              CustomToaster.toastError(
                                context,
                                'Registration Failed',
                                'Failed to register courses',
                              );
                            }
                          } catch (e) {
                            // Close loading dialog
                            Navigator.pop(context);
                            
                            // Show error toast with detailed error message for debugging
                            CustomToaster.toastError(
                              context,
                              'Error',
                              'Error: ${e.toString()}',
                            );
                            
                            // Print the full error to the console
                            print('Registration error: $e');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

// Helper function to get registered courses with settings
Future<List<Map<String, dynamic>>> _getRegisteredCoursesWithSettings(
  CourseRegistrationService service, 
  String classId
) async {
  try {
    // Get settings data from Hive
    final userBox = Hive.box('userData');
    final dynamic rawSettings = userBox.get('settings');
    
    if (rawSettings == null) {
      print('Settings data not found, using default values');
      return await service.getRegisteredCourses(
        classId: classId,
        year: 2025,
        term: 3,
      );
    }
    
    // Ensure proper type casting from Hive
    final Map<String, dynamic> typedSettings;
    
    if (rawSettings is Map) {
      typedSettings = Map<String, dynamic>.from(rawSettings);
    } else {
      print('Invalid settings format, using default values');
      return await service.getRegisteredCourses(
        classId: classId,
        year: 2025,
        term: 3,
      );
    }
    
    // Get the year and term with proper error handling
    int year;
    int term;
    
    try {
      // Handle year
      if (typedSettings['year'] is int) {
        year = typedSettings['year'];
      } else {
        year = int.parse(typedSettings['year']?.toString() ?? '2025');
      }
      
      // Handle term
      if (typedSettings['term'] is int) {
        term = typedSettings['term'];
      } else {
        term = int.parse(typedSettings['term']?.toString() ?? '3');
      }
    } catch (e) {
      // Fallback values if parsing fails
      print('Error parsing settings: $e');
      year = 2025;
      term = 3;
    }
    
    return await service.getRegisteredCourses(
      classId: classId,
      year: year,
      term: term,
    );
  } catch (e) {
    print('Error getting registered courses with settings: $e');
    return [];
  }
}





// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/utils/registration/subject_selection.dart';
// import 'package:linkschool/modules/services/api/service_locator.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';
// import 'package:hive/hive.dart';
// import 'dart:convert';
// import 'package:linkschool/modules/common/custom_toaster.dart';


// class CourseRegistrationService {
//   final ApiService _apiService = locator<ApiService>();
  
//   Future<bool> registerCourses({
//     required String classId,
//     required int year,
//     required int term,
//     required List<Map<String, dynamic>> courses,
//   }) async {
//     try {
//       // Validate classId
//       if (classId.isEmpty) {
//         print('Error: Class ID is empty');
//         return false;
//       }
      
//       // Debug the incoming courses
//       print('Raw courses received: $courses');
      
//       // Transform and ensure courses match API expected format with proper types
//       List<Map<String, dynamic>> registeredCourses = [];
      
//       for (var rawCourse in courses) {
//         // Explicitly convert each course to the right format
//         Map<String, dynamic> typedCourse = Map<String, dynamic>.from(rawCourse);
        
//         // Extract course_id carefully
//         dynamic courseIdValue = typedCourse["id"] ?? typedCourse["course_id"];
//         int courseId;
        
//         if (courseIdValue is int) {
//           courseId = courseIdValue;
//         } else if (courseIdValue is String) {
//           courseId = int.parse(courseIdValue);
//         } else {
//           print('Invalid course ID type: ${courseIdValue.runtimeType}');
//           continue; // Skip this course
//         }
        
//         // Extract course name
//         String courseName = typedCourse["name"]?.toString() ?? "";
        
//         // Add to registered courses list
//         registeredCourses.add({
//           "course_id": courseId,
//           "name": courseName
//         });
//       }
      
//       final Map<String, dynamic> payload = {
//         "year": year,
//         "term": term,
//         "registered_courses": registeredCourses,
//         "_db": "aalmgzmy_linkskoo_practice"
//       };
      
//       // Print payload for debugging
//       print('Sending payload: ${json.encode(payload)}');
      
//       final response = await _apiService.post(
//         endpoint: 'portal/classes/$classId/course-registrations',
//         body: payload,
//       );
      
//       // Print response for debugging
//       print('Response: ${response.statusCode} - ${response.message}');
      
//       return response.success;
//     } catch (e) {
//       print('Error registering courses: $e');
//       return false;
//     }
//   }
// }

// void showRegistrationDialog(BuildContext context, {required String classId}) {
//   // Initialize selected courses list with proper typing
//   List<Map<String, dynamic>> selectedCourses = [];
//   final courseRegistrationService = CourseRegistrationService();
  
//   // Validate class ID before proceeding
//   if (classId.isEmpty) {
//     CustomToaster.toastError(
//       context,
//       'Configuration Error',
//       'Class ID is missing or invalid',
//     );
//     return;
//   }
  
//   print('Opening registration dialog for class ID: $classId');
  
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (BuildContext context) {
//       return StatefulBuilder(
//         builder: (BuildContext context, StateSetter setState) {
//           return Padding(
//             padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//             child: Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Select courses to register',
//                     style: AppTextStyles.normal600(
//                         fontSize: 18, color: AppColors.backgroundDark),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 20),
//                   // Pass callback to receive selected courses
//                   SubjectSelection(
//                     onCoursesSelected: (courses) {
//                       // Ensure we're working with List<Map<String, dynamic>>
//                       selectedCourses = List<Map<String, dynamic>>.from(
//                         courses.map((dynamic course) {
//                           if (course is Map) {
//                             return Map<String, dynamic>.from(course);
//                           }
//                           return <String, dynamic>{}; // Empty map as fallback
//                         }).toList()
//                       );
                      
//                       // Debug the selected courses
//                       print('Selected courses (updated): $selectedCourses');
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.videoColor4,
//                       minimumSize: const Size(double.infinity, 50),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text(
//                       'Register',
//                       style: AppTextStyles.normal600(
//                           fontSize: 16, color: AppColors.backgroundLight),
//                     ),
//                     onPressed: () async {
//                       if (selectedCourses.isEmpty) {
//                         // Show a warning toast if no courses are selected
//                         CustomToaster.toastWarning(
//                           context,
//                           'Selection Required',
//                           'Please select at least one course to register',
//                         );
//                         return;
//                       }
                      
//                       // Show loading indicator
//                       showDialog(
//                         context: context,
//                         barrierDismissible: false,
//                         builder: (BuildContext context) {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         },
//                       );
                      
//                       try {
//                         // Get settings data from Hive
//                         final userBox = Hive.box('userData');
//                         final dynamic rawSettings = userBox.get('settings');
                        
//                         if (rawSettings == null) {
//                           throw Exception('Settings data not found');
//                         }
                        
//                         // Ensure proper type casting from Hive
//                         // This is critical as Hive often returns Map<dynamic, dynamic>
//                         final Map<String, dynamic> typedSettings;
                        
//                         if (rawSettings is Map) {
//                           typedSettings = Map<String, dynamic>.from(rawSettings);
//                         } else {
//                           throw Exception('Invalid settings format');
//                         }
                        
//                         // Get the year and term with proper error handling
//                         int year;
//                         int term;
                        
//                         try {
//                           // Handle year
//                           if (typedSettings['year'] is int) {
//                             year = typedSettings['year'];
//                           } else {
//                             year = int.parse(typedSettings['year']?.toString() ?? '2025');
//                           }
                          
//                           // Handle term
//                           if (typedSettings['term'] is int) {
//                             term = typedSettings['term'];
//                           } else {
//                             term = int.parse(typedSettings['term']?.toString() ?? '3');
//                           }
//                         } catch (e) {
//                           // Fallback values if parsing fails
//                           print('Error parsing settings: $e');
//                           year = 2025;
//                           term = 3;
//                         }
                        
//                         // Print debug information
//                         print('Registering courses for class ID: $classId');
//                         print('Year: $year, Term: $term');
//                         print('Selected courses: $selectedCourses');
                        
//                         // Call API to register courses
//                         final success = await courseRegistrationService.registerCourses(
//                           classId: classId,
//                           year: year,
//                           term: term,
//                           courses: selectedCourses,
//                         );
                        
//                         // Close loading dialog
//                         Navigator.pop(context);
                        
//                         if (success) {
//                           // Close registration dialog
//                           Navigator.pop(context);
                          
//                           // Show success toast
//                           CustomToaster.toastSuccess(
//                             context,
//                             'Success',
//                             'Courses registered successfully',
//                           );
//                         } else {
//                           // Show error toast
//                           CustomToaster.toastError(
//                             context,
//                             'Registration Failed',
//                             'Failed to register courses',
//                           );
//                         }
//                       } catch (e) {
//                         // Close loading dialog
//                         Navigator.pop(context);
                        
//                         // Show error toast with detailed error message for debugging
//                         CustomToaster.toastError(
//                           context,
//                           'Error',
//                           'Error: ${e.toString()}',
//                         );
                        
//                         // Print the full error to the console
//                         print('Registration error: $e');
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     },
//   );
// }