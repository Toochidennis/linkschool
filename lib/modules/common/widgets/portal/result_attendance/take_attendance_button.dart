import 'package:flutter/material.dart';
import 'package:linkschool/modules/admin/result/class_detail/attendance/take_class_attendance.dart';
import 'package:linkschool/modules/admin/result/class_detail/attendance/take_course_attendance.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/utils/registration_util.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/utils/registration/registration_utils.dart';

class TakeAttendanceButton extends StatefulWidget {
  final String classId;

  const TakeAttendanceButton({super.key, required this.classId});

  @override
  State<TakeAttendanceButton> createState() => _TakeAttendanceButtonState();
}

class _TakeAttendanceButtonState extends State<TakeAttendanceButton> {
  @override
  Widget build(BuildContext context) {
    return CustomLongElevatedButton(
      text: 'Take attendance',
      onPressed: () => _showTakeAttendanceDialog(context),
      backgroundColor: AppColors.videoColor4,
      textStyle: AppTextStyles.normal600(
          fontSize: 16, color: AppColors.backgroundLight),
    );
  }

  void _showTakeAttendanceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildAttendanceButton('Take class attendance', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TakeClassAttendance(classId: widget.classId)),
                );
              }),
              const SizedBox(height: 16),
              _buildAttendanceButton('Take course attendance', () {
                Navigator.pop(context);
                _showSelectCourseDialog(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSelectCourseDialog(BuildContext context) {
    final courseRegistrationService = CourseRegistrationService();

    final userDataBox = Hive.box('userData');
    final dynamic rawSettings = userDataBox.get('settings');
    int year;
    int term;

    try {
      final Map<String, dynamic> typedSettings =
          rawSettings is Map ? Map<String, dynamic>.from(rawSettings) : {};
      year = int.parse(typedSettings['year']?.toString() ?? '2025');
      term = int.parse(typedSettings['term']?.toString() ?? '3');
    } catch (e) {
      print('Error parsing settings: $e');
      year = 2025;
      term = 3;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            Future<List<Map<String, dynamic>>>? coursesFuture;
            
            // Initialize the future
            coursesFuture = courseRegistrationService.getRegisteredCourses(
              classId: widget.classId,
              year: year,
              term: term,
            );

            Future<void> _refreshCourses() async {
              setModalState(() {
                coursesFuture = courseRegistrationService.getRegisteredCourses(
                  classId: widget.classId,
                  year: year,
                  term: term,
                );
              });
            }

            return FutureBuilder<List<Map<String, dynamic>>>(
              future: coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryLight,
                    ),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'No courses available',
                          style: AppTextStyles.normal600(
                            fontSize: 18,
                            color: AppColors.backgroundDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                          ),
                          child: Text(
                            'Close',
                            style: AppTextStyles.normal600(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final courses = snapshot.data!;

                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Select course to take attendance',
                        style: AppTextStyles.normal600(
                          fontSize: 18,
                          color: AppColors.backgroundDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: RefreshIndicator(
                          onRefresh: _refreshCourses,
                          color: AppColors.primaryLight,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: courses.map<Widget>((course) {
                                final courseId = course['id']?.toString();
                                final courseName = course['course_name']?.toString() ?? 'Unknown Course';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: _buildAttendanceButton(courseName, () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TakeCourseAttendance(
                                          courseId: courseId ?? '',
                                          classId: widget.classId,
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAttendanceButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppColors.dialogBtnColor,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              child: Text(
                text,
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: AppColors.backgroundDark,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:linkschool/modules/admin/result/class_detail/attendance/take_class_attendance.dart';
// import 'package:linkschool/modules/admin/result/class_detail/attendance/take_course_attendance.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
// import 'package:linkschool/modules/common/text_styles.dart';

// class TakeAttendanceButton extends StatelessWidget {
//   final String classId;

//   const TakeAttendanceButton({super.key, required this.classId});

//   @override
//   Widget build(BuildContext context) {
//     return CustomLongElevatedButton(
//       text: 'Take attendance',
//       onPressed: () => _showTakeAttendanceDialog(context),
//       backgroundColor: AppColors.videoColor4,
//       textStyle: AppTextStyles.normal600(
//           fontSize: 16, color: AppColors.backgroundLight),
//     );
//   }

//   void _showTakeAttendanceDialog(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               _buildAttendanceButton('Take class attendance', () {
//                 Navigator.pop(context); // Close the bottom sheet
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           TakeClassAttendance(classId: classId)), // Navigate to TakeClassAttendance
//                 );
//               }),
//               const SizedBox(height: 16),
//               _buildAttendanceButton('Take course attendance', () {
//                 Navigator.pop(context);
//                 _showSelectCourseDialog(context);
//               }),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showSelectCourseDialog(BuildContext context) {
//     // Get courses from Hive
//     final userDataBox = Hive.box('userData');
    
//     // Access the courses directly as they were stored during login
//     final List<dynamic> courses = userDataBox.get('courses') ?? [];
    
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               const Text('Select course to take attendance',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 16),
//               // Dynamic course list with corrected data access
//               Flexible(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: courses.map<Widget>((course) {
//                       // Access course data using the correct structure from API
//                       final courseId = course['id'];
//                       final courseName = course['course_name'];
                      
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 8.0),
//                         child: _buildAttendanceButton(courseName, () {
//                           Navigator.pop(context); // Close dialog first
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => TakeCourseAttendance(
//                                       courseId: courseId.toString(), classId: classId))); 
//                         }),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildAttendanceButton(String text, VoidCallback onPressed) {
//     return Container(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//               color: Colors.grey.withOpacity(0.3),
//               spreadRadius: 1,
//               blurRadius: 3,
//               offset: const Offset(0, 2))
//         ],
//       ),
//       child: Material(
//         color: AppColors.dialogBtnColor,
//         child: InkWell(
//           onTap: onPressed,
//           borderRadius: BorderRadius.circular(4),
//           child: Ink(
//             decoration: BoxDecoration(
//                 color: Colors.white, borderRadius: BorderRadius.circular(4)),
//             child: Container(
//               width: double.infinity,
//               height: 50,
//               alignment: Alignment.center,
//               child: Text(text,
//                   style: AppTextStyles.normal600(
//                       fontSize: 16, color: AppColors.backgroundDark)),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }