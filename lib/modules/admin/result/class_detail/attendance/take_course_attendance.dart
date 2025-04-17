import 'package:flutter/material.dart';
import 'package:linkschool/modules/providers/admin/student_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_floating_save_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';

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
  String _formattedDateForDisplay = '';

  @override
  void initState() {
    super.initState();
    _setCurrentDate();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeData());
  }

  void _initializeData() async {
    final provider = context.read<StudentProvider>();
    await provider.fetchStudents(widget.classId);
    
    if (widget.classId != null && widget.courseId != null) {
      final dateForApi = "${_currentDate.split(' ')[0]} 00:00:00";
      await provider.loadAttendedStudents(
        classId: widget.classId!,
        date: _currentDate,
      );
      await provider.fetchCourseAttendance(
        classId: widget.classId!,
        date: dateForApi,
        courseId: widget.courseId!,
      );
      await provider.fetchLocalAttendance(
        classId: widget.classId!,
        date: _currentDate,
        courseId: widget.courseId!,
      );
    }
  }

  void _setCurrentDate() {
    final now = DateTime.now();
    _currentDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    _formattedDateForDisplay = DateFormat('MMM dd, yyyy').format(now);
  }

  Future<void> _onSavePressed() async {
    final provider = context.read<StudentProvider>();
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDate = formatter.format(now);
    final dateForApi = "${formattedDate.split(' ')[0]} 00:00:00";

    bool success;
    
    if (provider.hasExistingAttendance && provider.currentAttendanceId != null) {
      success = await provider.updateAttendance(
        attendanceId: provider.currentAttendanceId!,
      );
      
      if (success) {
        CustomToaster.toastSuccess(
          context,
          'Success',
          'Course attendance updated successfully',
        );
        await provider.fetchCourseAttendance(
          classId: widget.classId!,
          date: dateForApi,
          courseId: widget.courseId!,
        );
      }
    } else {
      success = await provider.saveCourseAttendance(
        classId: widget.classId,
        courseId: widget.courseId,
        date: formattedDate,
      );
      
      if (success) {
        await provider.saveLocalAttendance(
          classId: widget.classId!,
          date: formattedDate,
          courseId: widget.courseId!,
          studentIds: provider.selectedStudentIds,
        );
        
        CustomToaster.toastSuccess(
          context,
          'Success',
          'Course attendance saved successfully',
        );
      }
    }
    
    if (!success) {
      CustomToaster.toastError(
        context,
        'Error',
        provider.errorMessage.isNotEmpty
            ? provider.errorMessage
            : 'Failed to save course attendance',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: Text(
          _formattedDateForDisplay,
          style: AppTextStyles.normal500(
              fontSize: 18, color: AppColors.backgroundDark),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
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
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.errorMessage.isNotEmpty) return Center(child: Text(provider.errorMessage));
          if (provider.students.isEmpty) return const Center(child: Text('No students found'));

          return Column(
            children: [
              if (provider.hasExistingAttendance)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  color: Colors.green.withOpacity(0.1),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green),
                      SizedBox(width: 8),
                    ],
                  ),
                ),

              GestureDetector(
                onTap: () => provider.toggleSelectAll(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                      trailing: Icon(
                        Icons.check_circle,
                        color: student.isMarkedPresent 
                            ? AppColors.attCheckColor2 
                            : Colors.grey.withOpacity(0.5),
                      ),
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
          return provider.students.any((s) => s.isSelected)
              ? CustomFloatingSaveButton(
                  onPressed: _onSavePressed,
                  icon: provider.hasExistingAttendance ? Icons.update : Icons.save,
                  tooltip: provider.hasExistingAttendance ? 'Update Attendance' : 'Save Attendance',
                )
              : Container();
        },
      ),
    );
  }
}


// import 'package:flutter/material.dart';
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
//   String _formattedDateForDisplay = '';

//   @override
//   void initState() {
//     super.initState();
//     _setCurrentDate();

//     // Initialize provider with needed data
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final provider = context.read<StudentProvider>();
      
//       // First, fetch students
//       await provider.fetchStudents(widget.classId);
      
//       // After students are loaded, load the attendance data
//       if (widget.classId != null && widget.courseId != null) {
//         // Format date for API: YYYY-MM-DD 00:00:00
//         final dateForApi = "${_currentDate.split(' ')[0]} 00:00:00";
        
//         // Load attended students data (previously marked attendance)
//         await provider.loadAttendedStudents(
//           classId: widget.classId!,
//           date: _currentDate,
//         );
        
//         // Fetch latest attendance data from API
//         await provider.fetchCourseAttendance(
//           classId: widget.classId!,
//           date: dateForApi,
//           courseId: widget.courseId!,
//         );
        
//         // Load local attendance data (students selected for current attendance)
//         await provider.fetchLocalAttendance(
//           classId: widget.classId!,
//           date: _currentDate,
//           courseId: widget.courseId!,
//         );
//       }
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
//     final displayFormatter = DateFormat('MMM dd, yyyy'); // Format for display
    
//     _currentDate = formatter.format(now);
//     _formattedDateForDisplay = displayFormatter.format(now);
//   }

//   void _onSavePressed() async {
//     final provider = context.read<StudentProvider>();

//     // Format the current date for API request
//     final now = DateTime.now();
//     final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
//     final formattedDate = formatter.format(now);
//     final dateForApi = "${formattedDate.split(' ')[0]} 00:00:00";

//     bool success;
    
//     // Check if we're updating existing attendance or creating new
//     if (provider.hasExistingAttendance && provider.currentAttendanceId != null) {
//       // Update existing attendance
//       success = await provider.updateAttendance(
//         attendanceId: provider.currentAttendanceId!,
//       );
      
//       if (success) {
//         CustomToaster.toastSuccess(
//           context,
//           'Success',
//           'Course attendance updated successfully',
//         );
//       }
//     } else {
//       // Create new attendance
//       success = await provider.saveCourseAttendance(
//         classId: widget.classId,
//         courseId: widget.courseId,
//         date: formattedDate,
//       );
      
//       if (success) {
//         // Save attendance data locally
//         await provider.saveLocalAttendance(
//           classId: widget.classId!,
//           date: formattedDate,
//           courseId: widget.courseId!,
//           studentIds: provider.selectedStudentIds,
//         );
        
//         CustomToaster.toastSuccess(
//           context,
//           'Success',
//           'Course attendance saved successfully',
//         );
//       }
//     }
    
//     if (success) {
//       // Refresh attendance data from API to update UI
//       await provider.fetchCourseAttendance(
//         classId: widget.classId!,
//         date: dateForApi,
//         courseId: widget.courseId!,
//       );
//     } else {
//       CustomToaster.toastError(
//         context,
//         'Error',
//         provider.errorMessage.isNotEmpty
//             ? provider.errorMessage
//             : 'Failed to save course attendance',
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundLight,
//         title: Text(
//           _formattedDateForDisplay,
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
//               // Status banner for existing attendance
//               if (provider.hasExistingAttendance)
//                 Container(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                   color: Colors.green.withOpacity(0.1),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.info_outline, color: Colors.green),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           'Attendance has already been taken for today. You can update by selecting additional students.',
//                           style: TextStyle(color: Colors.green[800]),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

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
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // Show a green check if the student has already been marked as attended
//                           if (student.hasAttended)
//                             const Icon(Icons.check_circle, color: Colors.green),

//                           // Show a small space between icons if both are shown
//                           if (student.hasAttended && student.isSelected)
//                             const SizedBox(width: 8),

//                           // Show purple check if the student is currently selected
//                           if (student.isSelected)
//                             const Icon(Icons.check_circle,
//                                 color: AppColors.attCheckColor2),
//                         ],
//                       ),
//                       onTap: () {
//                         // If student already has attendance, don't allow deselection
//                         if (student.hasAttended) {
//                           return;
//                         }
//                         provider.toggleStudentSelection(index);
//                       },
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
//                   icon: provider.hasExistingAttendance ? Icons.update : Icons.save,
//                   tooltip: provider.hasExistingAttendance ? 'Update Attendance' : 'Save Attendance',
//                 )
//               : Container();
//         },
//       ),
//     );
//   }
// }