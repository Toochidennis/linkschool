import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/admin/course_registration_model.dart';
import 'package:linkschool/modules/providers/admin/course_registration_provider.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';

class CourseRegistrationScreen extends StatefulWidget {
  final String studentName;
  final int coursesRegistered;
  final String classId;
  final int studentId;

  const CourseRegistrationScreen({
    super.key,
    required this.studentName,
    required this.coursesRegistered,
    required this.classId,
    required this.studentId,
  });

  @override
  State createState() => _CourseRegistrationScreenState();
}

class _CourseRegistrationScreenState extends State<CourseRegistrationScreen> {
  late List<bool> selectedSubjects;
  late List<Color> subjectColors;
  late List<Map<String, dynamic>> courses;
  bool _hasSelectedCourses = false;
  bool _isSaving = false;
  bool _isLoadingRegisteredCourses = true;
  List<int> _registeredCourseIds = [];

  @override
  void initState() {
    super.initState();
    courses = getCoursesFromHive();
    selectedSubjects = List<bool>.filled(courses.length, false);
    subjectColors = List.generate(
      courses.length,
      (index) => Colors.primaries[index % Colors.primaries.length],
    );

    // Initialize with cached data
    _registeredCourseIds = _getRegisteredCoursesFromHive();
    for (int i = 0; i < courses.length; i++) {
      selectedSubjects[i] = _registeredCourseIds.contains(courses[i]['id']);
    }
    _hasSelectedCourses = selectedSubjects.contains(true);

    // Fetch fresh data from server
    _fetchRegisteredCoursesForStudent();
  }

  // Save registered courses to Hive
  Future<void> _saveRegisteredCoursesToHive(List<int> courseIds) async {
    final userBox = Hive.box('userData');
    await userBox.put('registeredCourses_${widget.studentId}_${widget.classId}', courseIds);
  }

  // Get registered courses from Hive
  List<int> _getRegisteredCoursesFromHive() {
    final userBox = Hive.box('userData');
    final cachedCourses = userBox.get('registeredCourses_${widget.studentId}_${widget.classId}');
    return cachedCourses != null ? List<int>.from(cachedCourses) : [];
  }

  // Fetch already registered courses for this student
  Future<void> _fetchRegisteredCoursesForStudent() async {
    setState(() {
      _isLoadingRegisteredCourses = true;
    });

    try {
      final userBox = Hive.box('userData');
      final userData = userBox.get('userData');
      final settings = userData?['data']?['settings'];

      if (userData == null || settings == null) {
        throw Exception('User data not found');
      }

      final year = settings['year'] ?? '2025';
      final term = settings['term'] ?? '3';
      final dbName = userData['_db'] ?? 'aalmgzmy_linkskoo_practice';

      // Debug logging
      print('Fetching registered courses with params:');
      print('Student ID: ${widget.studentId}');
      print('Class ID: ${widget.classId}');
      print('Year: $year');
      print('Term: $term');
      print('DB Name: $dbName');

      final provider = Provider.of<CourseRegistrationProvider>(context, listen: false);
      final response = await provider.fetchStudentRegisteredCourses(
        studentId: widget.studentId,
        classId: widget.classId,
        year: year.toString(),
        term: term.toString(),
        dbName: dbName,
      );

      if (response.isNotEmpty) {
        _registeredCourseIds = response;
        await _saveRegisteredCoursesToHive(response);
      } else {
        _registeredCourseIds = _getRegisteredCoursesFromHive();
        print('No courses returned from API, using cached data: $_registeredCourseIds');
      }

      for (int i = 0; i < courses.length; i++) {
        selectedSubjects[i] = _registeredCourseIds.contains(courses[i]['id']);
      }

      _hasSelectedCourses = selectedSubjects.contains(true);
    } catch (e) {
      print('Error fetching registered courses: $e');
      _registeredCourseIds = _getRegisteredCoursesFromHive();
      for (int i = 0; i < courses.length; i++) {
        selectedSubjects[i] = _registeredCourseIds.contains(courses[i]['id']);
      }
      _hasSelectedCourses = selectedSubjects.contains(true);
    } finally {
      setState(() {
        _isLoadingRegisteredCourses = false;
      });
    }
  }

  List<Map<String, dynamic>> getCoursesFromHive() {
    final userDataBox = Hive.box('userData');

    try {
      final userData = userDataBox.get('userData');
      if (userData != null &&
          userData['data'] != null &&
          userData['data']['courses'] != null) {
        final coursesList = userData['data']['courses'] as List;
        return coursesList.map((course) =>
            Map<String, dynamic>.from(course as Map)).toList();
      }

      final courses = userDataBox.get('courses');
      if (courses != null && courses is List) {
        return courses.map((course) =>
            Map<String, dynamic>.from(course as Map)).toList();
      }
    } catch (e) {
      print('Error converting courses data: $e');
    }

    return [];
  }

  Future<void> _saveSelectedCourses() async {
    if (!_hasSelectedCourses) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final userBox = Hive.box('userData');
      final userData = userBox.get('userData');
      final settings = userData?['data']?['settings'];

      if (userData == null || settings == null) {
        throw Exception('User data not found');
      }

      final payload = {
        "year": settings['year'] ?? 2025,
        "term": settings['term'] ?? 3,
        "class_id": widget.classId,
        "registered_courses": courses
            .asMap()
            .entries
            .where((entry) => selectedSubjects[entry.key])
            .map((entry) => {"course_id": entry.value['id']})
            .toList(),
        "_db": userData['_db'] ?? 'aalmgzmy_linkskoo_practice',
      };

      final provider = Provider.of<CourseRegistrationProvider>(context, listen: false);
      final response = await provider.registerCourse(
        CourseRegistrationModel(
          studentId: widget.studentId,
          studentName: widget.studentName,
          courseCount: selectedSubjects.where((selected) => selected).length,
          classId: widget.classId,
          term: settings['term']?.toString(),
          year: settings['year']?.toString(),
        ),
        payload: payload,
      );

      if (response) {
        final selectedCourseIds = courses
            .asMap()
            .entries
            .where((entry) => selectedSubjects[entry.key])
            .map((entry) => entry.value['id'] as int)
            .toList();
        await _saveRegisteredCoursesToHive(selectedCourseIds);
        _registeredCourseIds = selectedCourseIds;

        CustomToaster.toastSuccess(
          context,
          'Success',
          'Courses saved successfully',
        );

        await _fetchRegisteredCoursesForStudent();
      } else {
        CustomToaster.toastError(
          context,
          'Failed',
          'Failed to save courses',
        );
      }
    } catch (e) {
      CustomToaster.toastError(
        context,
        'Error',
        'Error: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _updateSelection(int index, bool isSelected) {
    setState(() {
      selectedSubjects[index] = isSelected;
      _hasSelectedCourses = selectedSubjects.contains(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Course Registration',
          style: AppTextStyles.normal600(fontSize: 20, color: AppColors.backgroundLight),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.backgroundLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/result/bg_course_reg.svg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).padding.top + AppBar().preferredSize.height,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.18,
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    Positioned(
                      top: 16.0,
                      left: 16.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.studentName.toUpperCase(),
                            style: AppTextStyles.normal600(fontSize: 20, color: Colors.white),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '2015/2016 Academic Session',
                            style: AppTextStyles.normal400(fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    if (_hasSelectedCourses)
                      Positioned(
                        bottom: 2.0,
                        right: 8.0,
                        child: FloatingActionButton(
                          onPressed: _isSaving ? null : _saveSelectedCourses,
                          backgroundColor: _isSaving ? Colors.grey : AppColors.primaryLight,
                          shape: const CircleBorder(),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(100)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 7,
                                  spreadRadius: 7,
                                  offset: const Offset(3, 5),
                                ),
                              ],
                            ),
                            child: _isSaving
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  )
                                : const Icon(
                                    Icons.save,
                                    color: AppColors.backgroundLight,
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, -4),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    child: _isLoadingRegisteredCourses
                        ? const Center(child: CircularProgressIndicator())
                        : courses.isEmpty
                            ? const Center(child: Text('No courses available'))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                itemCount: courses.length,
                                itemBuilder: (context, index) {
                                  final course = courses[index];
                                  final courseName = course['course_name'] as String;

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: selectedSubjects[index] ? Colors.grey[200] : Colors.white,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: subjectColors[index],
                                        child: Text(
                                          courseName.isNotEmpty ? courseName[0].toUpperCase() : '?',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      title: Text(courseName),
                                      trailing: GestureDetector(
                                        onTap: () {
                                          _updateSelection(index, !selectedSubjects[index]);
                                        },
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: selectedSubjects[index] ? Colors.green : Colors.white,
                                            border: Border.all(color: Colors.grey),
                                          ),
                                          child: selectedSubjects[index]
                                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                                              : null,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:hive/hive.dart'; 
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/model/admin/course_registration_model.dart';
// import 'package:linkschool/modules/providers/admin/course_registration_provider.dart';
// import 'package:provider/provider.dart';
// // Import CustomToaster
// import 'package:linkschool/modules/common/custom_toaster.dart';

// class CourseRegistrationScreen extends StatefulWidget {
//   final String studentName;
//   final int coursesRegistered;
//   final String classId;
//   final int studentId;
  
//   const CourseRegistrationScreen({
//     super.key, 
//     required this.studentName, 
//     required this.coursesRegistered,
//     required this.classId,
//     required this.studentId,
//   });

//   @override
//   State createState() => _CourseRegistrationScreenState();
// }

// class _CourseRegistrationScreenState extends State<CourseRegistrationScreen> {
//   late List<bool> selectedSubjects;
//   late List<Color> subjectColors;
//   late List<Map<String, dynamic>> courses;
//   bool _hasSelectedCourses = false; // Track if any courses are selected
//   bool _isSaving = false; // Track save operation state
//   bool _isLoadingRegisteredCourses = true; // Track loading state for registered courses
//   List<int> _registeredCourseIds = []; // Store IDs of already registered courses
  
//   @override
//   void initState() {
//     super.initState();
//     // Load courses from Hive on initialization
//     courses = getCoursesFromHive();
//     // Initialize all courses as unchecked by default
//     selectedSubjects = List<bool>.filled(courses.length, false);
//     // Initialize colors with primary colors cycle
//     subjectColors = List.generate(
//       courses.length, 
//       (index) => Colors.primaries[index % Colors.primaries.length]
//     );
    
//     // Load registered courses for this student
//     _fetchRegisteredCoursesForStudent();
//   }

//   // Fetch already registered courses for this student
//   Future<void> _fetchRegisteredCoursesForStudent() async {
//     setState(() {
//       _isLoadingRegisteredCourses = true;
//     });
    
//     try {
//       // Get required parameters from Hive
//       final userBox = Hive.box('userData');
//       final userData = userBox.get('userData');
//       final settings = userData?['data']?['settings'];
      
//       if (userData == null || settings == null) {
//         throw Exception('User data not found');
//       }
      
//       final year = settings['year'] ?? '2025';
//       final term = settings['term'] ?? '3';
//       final dbName = userData['_db'] ?? 'aalmgzmy_linkskoo_practice';
      
//       // Call the API through the provider
//       final provider = Provider.of<CourseRegistrationProvider>(context, listen: false);
//       final response = await provider.fetchStudentRegisteredCourses(
//         studentId: widget.studentId,
//         classId: widget.classId,
//         year: year.toString(),
//         term: term.toString(),
//         dbName: dbName,
//       );
      
//       if (response.isNotEmpty) {
//         // Store the IDs of registered courses
//         _registeredCourseIds = response;
        
//         // Update selected subjects based on registered courses
//         for (int i = 0; i < courses.length; i++) {
//           if (_registeredCourseIds.contains(courses[i]['id'])) {
//             selectedSubjects[i] = true;
//           }
//         }
        
//         // Update hasSelectedCourses flag
//         _hasSelectedCourses = selectedSubjects.contains(true);
//       }
//     } catch (e) {
//       print('Error fetching registered courses: $e');
//     } finally {
//       setState(() {
//         _isLoadingRegisteredCourses = false;
//       });
//     }
//   }

//   List<Map<String, dynamic>> getCoursesFromHive() {
//     final userDataBox = Hive.box('userData');
    
//     try {
//       // Try to get courses from the userData directly
//       final userData = userDataBox.get('userData');
//       if (userData != null && 
//           userData['data'] != null && 
//           userData['data']['courses'] != null) {
//         // Properly convert each map with explicit casting
//         final coursesList = userData['data']['courses'] as List;
//         return coursesList.map((course) => 
//           Map<String, dynamic>.from(course as Map)).toList();
//       }
      
//       // Alternatively, try to get from the specific 'courses' key if saved separately
//       final courses = userDataBox.get('courses');
//       if (courses != null && courses is List) {
//         // Properly convert each map with explicit casting
//         return courses.map((course) => 
//           Map<String, dynamic>.from(course as Map)).toList();
//       }
//     } catch (e) {
//       print('Error converting courses data: $e');
//     }
    
//     // Return empty list if no data is found
//     return [];
//   }

//   Future<void> _saveSelectedCourses() async {
//     if (!_hasSelectedCourses) return;

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       // Get settings from Hive
//       final userBox = Hive.box('userData');
//       final userData = userBox.get('userData');
//       final settings = userData?['data']?['settings'];
      
//       if (userData == null || settings == null) {
//         throw Exception('User data not found');
//       }

//       // Prepare the payload
//       final payload = {
//         "year": settings['year'] ?? 2025,
//         "term": settings['term'] ?? 3,
//         "class_id": widget.classId,
//         "registered_courses": courses
//             .asMap()
//             .entries
//             .where((entry) => selectedSubjects[entry.key])
//             .map((entry) => {"course_id": entry.value['id']})
//             .toList(),
//         "_db": userData['_db'] ?? 'aalmgzmy_linkskoo_practice',
//       };

//       // Call the API through the provider
//       final provider = Provider.of<CourseRegistrationProvider>(context, listen: false);
//       final response = await provider.registerCourse(
//         CourseRegistrationModel(
//           studentId: widget.studentId,
//           studentName: widget.studentName,
//           courseCount: selectedSubjects.where((selected) => selected).length,
//           classId: widget.classId,
//           term: settings['term']?.toString(),
//           year: settings['year']?.toString(),
//         ),
//         payload: payload, // Pass the custom payload
//       );

//       if (response) {
//         // Only show toast on successful save
//         CustomToaster.toastSuccess(
//           context, 
//           'Success', 
//           'Courses saved successfully'
//         );
        
//         // Refresh the registered courses list
//         await _fetchRegisteredCoursesForStudent();
//       } else {
//         // Only show toast on error
//         CustomToaster.toastError(
//           context, 
//           'Failed', 
//           'Failed to save courses'
//         );
//       }
//     } catch (e) {
//       // Only show toast on error
//       CustomToaster.toastError(
//         context, 
//         'Error', 
//         'Error: ${e.toString()}'
//       );
//     } finally {
//       setState(() {
//         _isSaving = false;
//       });
//     }
//   }

//   void _updateSelection(int index, bool isSelected) {
//     setState(() {
//       selectedSubjects[index] = isSelected;
//       // Update hasSelectedCourses based on if any course is selected
//       _hasSelectedCourses = selectedSubjects.contains(true);
//     });
    
//     // Removed the toast that appears on every selection
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text(
//           'Course Registration',
//           style: AppTextStyles.normal600(fontSize: 20, color: AppColors.backgroundLight),
//         ),
//         leading: IconButton(
//           onPressed: () => Navigator.of(context).pop(),
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.backgroundLight,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: SvgPicture.asset(
//               'assets/images/result/bg_course_reg.svg',
//               fit: BoxFit.cover,
//             ),
//           ),
//           Column(
//             children: [
//               SizedBox(
//                 height: MediaQuery.of(context).padding.top + AppBar().preferredSize.height,
//               ),
//               Container(
//                 height: MediaQuery.of(context).size.height * 0.18,
//                 padding: const EdgeInsets.all(16.0),
//                 child: Stack(
//                   children: [
//                     Positioned(
//                       top: 16.0,
//                       left: 16.0,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.studentName.toUpperCase(),
//                             style: AppTextStyles.normal600(fontSize: 20, color: Colors.white),
//                           ),
//                           const SizedBox(height: 4.0),
//                           Text(
//                             '2015/2016 Academic Session',
//                             style: AppTextStyles.normal400(fontSize: 16, color: Colors.white70),
//                           ),
//                         ],
//                       ),
//                     ),
//                     if (_hasSelectedCourses) // Only show when courses are selected
//                       Positioned(
//                         bottom: 2.0,
//                         right: 8.0,
//                         child: FloatingActionButton(
//                           onPressed: _isSaving ? null : _saveSelectedCourses,
//                           backgroundColor: _isSaving 
//                               ? Colors.grey 
//                               : AppColors.primaryLight,
//                           shape: const CircleBorder(),
//                           child: Container(
//                             width: 50,
//                             height: 50,
//                             decoration: BoxDecoration(
//                               borderRadius: const BorderRadius.all(Radius.circular(100)),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.3),
//                                   blurRadius: 7,
//                                   spreadRadius: 7,
//                                   offset: const Offset(3, 5),
//                                 ),
//                               ],
//                             ),
//                             child: _isSaving
//                                 ? const CircularProgressIndicator(
//                                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                   )
//                                 : const Icon(
//                                     Icons.save,
//                                     color: AppColors.backgroundLight,
//                                   ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(20.0),
//                       topRight: Radius.circular(20.0),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black26,
//                         offset: Offset(0, -4),
//                         blurRadius: 4.0,
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(20.0),
//                       topRight: Radius.circular(20.0),
//                     ),
//                     child: _isLoadingRegisteredCourses
//                         ? const Center(child: CircularProgressIndicator())
//                         : courses.isEmpty
//                             ? const Center(child: Text('No courses available'))
//                             : ListView.builder(
//                                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                                 itemCount: courses.length,
//                                 itemBuilder: (context, index) {
//                                   final course = courses[index];
//                                   final courseName = course['course_name'] as String;
                                  
//                                   return Container(
//                                     decoration: BoxDecoration(
//                                       color: selectedSubjects[index] 
//                                           ? Colors.grey[200] 
//                                           : Colors.white,
//                                       border: Border(
//                                         bottom: BorderSide(
//                                           color: Colors.grey[300]!,
//                                           width: 1,
//                                         ),
//                                       ),
//                                     ),
//                                     child: ListTile(
//                                       leading: CircleAvatar(
//                                         backgroundColor: subjectColors[index],
//                                         child: Text(
//                                           courseName.isNotEmpty ? courseName[0].toUpperCase() : '?',
//                                           style: const TextStyle(color: Colors.white),
//                                         ),
//                                       ),
//                                       title: Text(courseName),
//                                       trailing: GestureDetector(
//                                         onTap: () {
//                                           _updateSelection(index, !selectedSubjects[index]);
//                                         },
//                                         child: Container(
//                                           width: 24,
//                                           height: 24,
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: selectedSubjects[index] 
//                                                 ? Colors.green 
//                                                 : Colors.white,
//                                             border: Border.all(color: Colors.grey),
//                                           ),
//                                           child: selectedSubjects[index]
//                                               ? const Icon(Icons.check, 
//                                                   size: 16, 
//                                                   color: Colors.white)
//                                               : null,
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }