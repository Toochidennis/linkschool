import 'package:flutter/material.dart';
import 'package:linkschool/modules/providers/admin/student_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_floating_save_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
// import 'package:hive/hive.dart';

class TakeCourseAttendance extends StatefulWidget {
  final String? courseId;
  final String? classId;
  const TakeCourseAttendance({super.key, this.courseId, this.classId});

  @override
  State<TakeCourseAttendance> createState() => _TakeCourseAttendanceState();
}

class _TakeCourseAttendanceState extends State<TakeCourseAttendance> {
  final List<Color> _circleColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.brown,
    Colors.lime,
  ];

  String _currentDate = '';

  @override
  void initState() {
    super.initState();
    _setCurrentDate();

    // Initialize provider with needed data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StudentProvider>();
      provider.fetchStudents(widget.classId).then((_) {
        // Fetch attendance data after students are loaded
        provider.fetchAttendance(
          classId: widget.classId!,
          date: _currentDate,
          courseId: widget.courseId!,
        );

        // Fetch local attendance data
        provider.fetchLocalAttendance(
          classId: widget.classId!,
          date: _currentDate,
          courseId: widget.courseId!,
        );
      });
    });
  }

  @override
  void dispose() {
    // Reset provider state when navigating away
    context.read<StudentProvider>().reset();
    super.dispose();
  }

  void _setCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss'); // Format for API
    _currentDate = formatter.format(now);
  }

  void _onSavePressed() {
    final provider = context.read<StudentProvider>();
    provider.saveAttendance(
      classId: widget.classId,
      courseId: widget.courseId,
      date: _currentDate,
    ).then((success) async {
      if (success) {
        // Save attendance data locally
        await provider.saveLocalAttendance(
          classId: widget.classId!,
          date: _currentDate,
          courseId: widget.courseId!,
          studentIds: provider.selectedStudentIds,
        );

        CustomToaster.toastSuccess(
          context,
          'Success',
          'Attendance saved successfully',
        );
      } else {
        CustomToaster.toastError(
          context,
          'Error',
          provider.errorMessage.isNotEmpty
              ? provider.errorMessage
              : 'Failed to save attendance',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: Text(
          _currentDate,
          style: AppTextStyles.normal500(
              fontSize: 18, color: AppColors.backgroundDark),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(child: Text(provider.errorMessage));
          }

          if (provider.students.isEmpty) {
            return const Center(child: Text('No students found'));
          }

          return Column(
            children: [
              // Select All Header
              GestureDetector(
                onTap: () => provider.toggleSelectAll(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                      color: provider.selectAll
                          ? const Color.fromRGBO(239, 227, 255, 1)
                          : AppColors.attBgColor1,
                      border: Border.all(color: AppColors.attBorderColor1)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select all students',
                        style: AppTextStyles.normal500(
                            fontSize: 16.0, color: AppColors.backgroundDark),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                            color: provider.selectAll
                                ? AppColors.attCheckColor1
                                : AppColors.attBgColor1,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.attCheckColor1)),
                        child: Icon(
                          Icons.check,
                          color: provider.selectAll
                              ? Colors.white
                              : AppColors.attCheckColor1,
                          size: 16,
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // Student List
              Expanded(
                child: ListView.separated(
                  itemCount: provider.students.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey[300],
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final student = provider.students[index];
                    final colorIndex = index % _circleColors.length;

                    return ListTile(
                      tileColor: student.isSelected
                          ? const Color.fromRGBO(239, 227, 255, 1)
                          : Colors.transparent,
                      leading: CircleAvatar(
                        backgroundColor: _circleColors[colorIndex],
                        child: Text(
                          student.name.isNotEmpty ? student.name[0] : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(student.name),
                      trailing: student.isSelected
                          ? const Icon(Icons.check_circle,
                              color: AppColors.attCheckColor2)
                          : null,
                      onTap: () => provider.toggleStudentSelection(index),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          // Show the floating button only if at least one student is selected
          return provider.selectedStudentIds.isNotEmpty
              ? CustomFloatingSaveButton(
                  onPressed: _onSavePressed,
                )
              : Container();
        },
      ),
    );
  }
}


// ``import 'package:flutter/material.dart';
// import 'package:linkschool/modules/providers/admin/student_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/buttons/custom_floating_save_button.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/custom_toaster.dart';

// class TakeCourseAttendance extends StatefulWidget {
//   final String? courseId;
//   final String? classId;
//   const TakeCourseAttendance({super.key, this.courseId, this.classId});

//   @override
//   State<TakeCourseAttendance> createState() => _TakeCourseAttendanceState();
// }

// class _TakeCourseAttendanceState extends State<TakeCourseAttendance> {
//   final List<Color> _circleColors = [
//     Colors.red,
//     Colors.blue,
//     Colors.green,
//     Colors.orange,
//     Colors.purple,
//     Colors.teal,
//     Colors.pink,
//     Colors.indigo,
//     Colors.amber,
//     Colors.cyan,
//     Colors.brown,
//     Colors.lime,
//   ];

//   String _currentDate = '';

//   @override
//   void initState() {
//     super.initState();
//     _setCurrentDate();

//     // Initialize provider with needed data
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = context.read<StudentProvider>();
//       provider.fetchStudents(widget.classId).then((_) {
//         // Fetch attendance data after students are loaded
//         provider.fetchAttendance(
//           classId: widget.classId!,
//           date: _currentDate,
//           courseId: widget.courseId!,
//         );
//       });
//     });
//   }

//   @override
//   void dispose() {
//     // Reset provider state when navigating away
//     context.read<StudentProvider>().reset();
//     super.dispose();
//   }

//   void _setCurrentDate() {
//     final now = DateTime.now();
//     final formatter = DateFormat('yyyy-MM-dd HH:mm:ss'); // Format for API
//     _currentDate = formatter.format(now);
//   }

//   void _onSavePressed() {
//     final provider = context.read<StudentProvider>();
//     provider.saveAttendance(
//       classId: widget.classId,
//       courseId: widget.courseId,
//       date: _currentDate,
//     ).then((success) {
//       if (success) {
//         CustomToaster.toastSuccess(
//           context,
//           'Success',
//           'Attendance saved successfully',
//         );
//       } else {
//         CustomToaster.toastError(
//           context,
//           'Error',
//           provider.errorMessage.isNotEmpty
//               ? provider.errorMessage
//               : 'Failed to save attendance',
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundLight,
//         title: Text(
//           _currentDate,
//           style: AppTextStyles.normal500(
//               fontSize: 18, color: AppColors.backgroundDark),
//         ),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.primaryLight,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//       ),
//       body: Consumer<StudentProvider>(
//         builder: (context, provider, child) {
//           if (provider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (provider.errorMessage.isNotEmpty) {
//             return Center(child: Text(provider.errorMessage));
//           }

//           if (provider.students.isEmpty) {
//             return const Center(child: Text('No students found'));
//           }

//           return Column(
//             children: [
//               // Select All Header
//               GestureDetector(
//                 onTap: () => provider.toggleSelectAll(),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 16.0, vertical: 12.0),
//                   decoration: BoxDecoration(
//                       color: provider.selectAll
//                           ? const Color.fromRGBO(239, 227, 255, 1)
//                           : AppColors.attBgColor1,
//                       border: Border.all(color: AppColors.attBorderColor1)),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Select all students',
//                         style: AppTextStyles.normal500(
//                             fontSize: 16.0, color: AppColors.backgroundDark),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.all(4.0),
//                         decoration: BoxDecoration(
//                             color: provider.selectAll
//                                 ? AppColors.attCheckColor1
//                                 : AppColors.attBgColor1,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: AppColors.attCheckColor1)),
//                         child: Icon(
//                           Icons.check,
//                           color: provider.selectAll
//                               ? Colors.white
//                               : AppColors.attCheckColor1,
//                           size: 16,
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),

//               // Student List
//               Expanded(
//                 child: ListView.separated(
//                   itemCount: provider.students.length,
//                   separatorBuilder: (context, index) => Divider(
//                     color: Colors.grey[300],
//                     height: 1,
//                   ),
//                   itemBuilder: (context, index) {
//                     final student = provider.students[index];
//                     final colorIndex = index % _circleColors.length;

//                     return ListTile(
//                       tileColor: student.isSelected
//                           ? const Color.fromRGBO(239, 227, 255, 1)
//                           : Colors.transparent,
//                       leading: CircleAvatar(
//                         backgroundColor: _circleColors[colorIndex],
//                         child: Text(
//                           student.name.isNotEmpty ? student.name[0] : '?',
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       ),
//                       title: Text(student.name),
//                       trailing: student.isSelected
//                           ? const Icon(Icons.check_circle,
//                               color: AppColors.attCheckColor2)
//                           : null,
//                       onTap: () => provider.toggleStudentSelection(index),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//       floatingActionButton: Consumer<StudentProvider>(
//         builder: (context, provider, child) {
//           // Show the floating button only if at least one student is selected
//           return provider.selectedStudentIds.isNotEmpty
//               ? CustomFloatingSaveButton(
//                   onPressed: _onSavePressed,
//                 )
//               : Container();
//         },
//       ),
//     );
//   }
// }``