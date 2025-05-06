import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/utils/registration/subject_selection.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:linkschool/modules/common/custom_toaster.dart';
// import 'package:motion_toast/motion_toast.dart';
// import 'package:linkschool/modules/common/widgets/portal/portal_result_register/button_section.dart';
// import 'package:linkschool/modules/common/utils/custom_toaster.dart';
// import 'package:provider/provider.dart';
// import 'package:linkschool/modules/auth/provider/auth_provider.dart';

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
      
      // Transform courses to match API expected format
      List<Map<String, dynamic>> registeredCourses = courses.map((course) {
        return {
          "course_id": course["id"] ?? course["course_id"],
          "name": course["name"]
        };
      }).toList();
      
      final Map<String, dynamic> payload = {
        "year": year,
        "term": term,
        "registered_courses": registeredCourses, // Changed from "courses" to "registered_courses"
        "_db": "aalmgzmy_linkskoo_practice"
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
}

void showRegistrationDialog(BuildContext context, {required String classId}) {
  // Initialize selected courses list
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
                  // Pass callback to receive selected courses
                  SubjectSelection(
                    onCoursesSelected: (courses) {
                      selectedCourses = courses;
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
                        final settings = userBox.get('settings');
                        
                        if (settings == null) {
                          throw Exception('Settings data not found');
                        }
                        
                        final year = int.parse(settings['year'] ?? '2025');
                        final term = settings['term'] ?? 3;
                        
                        // Print debug information
                        print('Registering courses for class ID: $classId');
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
                        
                        // Show error toast
                        CustomToaster.toastError(
                          context,
                          'Error',
                          'Error: ${e.toString()}',
                        );
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
}


// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/custom_toaster.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/utils/registration/subject_selection.dart';
// import 'package:linkschool/modules/common/widgets/portal/portal_result_register/button_section.dart';
// import 'package:linkschool/modules/services/api/service_locator.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';
// import 'package:hive/hive.dart';
// import 'package:motion_toast/motion_toast.dart';
// // import 'package:linkschool/modules/common/utils/custom_toaster.dart';
// import 'dart:convert';
// // import 'package:provider/provider.dart';
// // import 'package:linkschool/modules/auth/provider/auth_provider.dart';

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
      
//       // Transform courses to match API expected format
//       List<Map<String, dynamic>> registeredCourses = courses.map((course) {
//         return {
//           "course_id": course["id"] ?? course["course_id"],
//           "name": course["name"]
//         };
//       }).toList();
      
//       final Map<String, dynamic> payload = {
//         "year": year,
//         "term": term,
//         "registered_courses": registeredCourses, // Changed from "courses" to "registered_courses"
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

// void showRegistrationDialog(BuildContext context) {
//   // Initialize selected courses list
//   List<Map<String, dynamic>> selectedCourses = [];
//   final courseRegistrationService = CourseRegistrationService();
  
//   // Get the class ID from the parent widget's context
//   final String? classId = context.findAncestorWidgetOfExactType<ButtonSection>()?.classId;
  
//   // Validate class ID before proceeding
//   if (classId == null || classId.isEmpty) {
//     CustomToaster.toastError(
//       context,
//       'Configuration Error',
//       'Class ID is missing or invalid',
//     );
//     return;
//   }
  
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
//                       selectedCourses = courses;
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
//                         final settings = userBox.get('settings');
                        
//                         if (settings == null) {
//                           throw Exception('Settings data not found');
//                         }
                        
//                         final year = int.parse(settings['year'] ?? '2025');
//                         final term = settings['term'] ?? 3;
                        
//                         // Print debug information
//                         print('Registering courses for class ID: $classId');
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
                        
//                         // Show error toast
//                         CustomToaster.toastError(
//                           context,
//                           'Error',
//                           'Error: ${e.toString()}',
//                         );
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