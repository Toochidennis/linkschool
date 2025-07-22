import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_floating_save_button.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/providers/admin/student_provider.dart';
import 'package:linkschool/modules/common/constants.dart';

class StaffTakeAttendanceScreen extends StatefulWidget {
  final String classId;
  final String courseId;
  final String className;
  final String courseName;

  const StaffTakeAttendanceScreen({
    super.key,
    required this.classId,
    required this.courseId,
    required this.className,
    required this.courseName,
  });

  @override
  State<StaffTakeAttendanceScreen> createState() => _StaffTakeAttendanceScreenState();
}

class _StaffTakeAttendanceScreenState extends State<StaffTakeAttendanceScreen> {
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
  late double opacity;

  @override
  void initState() {
    super.initState();
    _setCurrentDate();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeData());
  }

  void _setCurrentDate() {
    final now = DateTime.now();
    _currentDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    _formattedDateForDisplay = DateFormat('MMM dd, yyyy').format(now);
  }

  Future<void> _initializeData() async {
    final provider = context.read<StudentProvider>();
    final userBox = Hive.box('userData');
    final userData = userBox.get('userData');
    final settings = userData?['data']['settings'] ?? {};

    final year = settings['year']?.toString() ?? '2025';
    final term = settings['term']?.toString() ?? '3';

    await provider.fetchStudents(
      widget.classId,
      courseId: widget.courseId,
    );

    if (widget.classId.isNotEmpty && widget.courseId.isNotEmpty) {
      final dateForApi = "${_currentDate.split(' ')[0]} 00:00:00";
      await provider.loadAttendedStudents(
        classId: widget.classId,
        date: _currentDate,
      );
      await provider.fetchCourseAttendance(
        classId: widget.classId,
        date: dateForApi,
        courseId: widget.courseId,
      );
      await provider.fetchLocalAttendance(
        classId: widget.classId,
        date: _currentDate,
        courseId: widget.courseId,
      );
    }
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
          classId: widget.classId,
          date: dateForApi,
          courseId: widget.courseId,
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
          classId: widget.classId,
          date: formattedDate,
          courseId: widget.courseId,
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
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.courseName} - $_formattedDateForDisplay',
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
        backgroundColor: AppColors.backgroundLight,
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Consumer<StudentProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.errorMessage.isNotEmpty) {
              return Center(child: Text(provider.errorMessage));
            }
            if (provider.students.isEmpty) {
              return const Center(child: Text('No students found for this course'));
            }

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
                        Text(
                          'Attendance already taken for this course',
                          style: TextStyle(color: Colors.green),
                        ),
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
                      border: Border.all(color: AppColors.attBorderColor1),
                    ),
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
                            border: Border.all(color: AppColors.attCheckColor1),
                          ),
                          child: Icon(
                            Icons.check,
                            color: provider.selectAll
                                ? Colors.white
                                : AppColors.attCheckColor1,
                            size: 16,
                          ),
                        ),
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
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';

// class StaffTakeAttendanceScreen extends StatefulWidget {
//   const StaffTakeAttendanceScreen({super.key});

//   @override
//   State<StaffTakeAttendanceScreen> createState() => _StaffTakeAttendanceScreenState();
// }

// class _StaffTakeAttendanceScreenState extends State<StaffTakeAttendanceScreen> {
//   List<bool> _selectedStudents = List.generate(12, (_) => false);
//   bool _selectAll = false;
//   List<int> _selectedRowIndices = [];
//     late double opacity;

//   final List<String> _studentNames = [
//     'Toochi Dennis',
//     'Bob John',
//     'Charlie Ifeanyi',
//     'David Oyeleke',
//     'Emma Chinonso',
//     'Frank Oga',
//     'Grace Okoro',
//     'Henry Onwe',
//     'Ivy John',
//     'Jack Sunday',
//     'Kate Joseph',
//     'Liam Dennis',
//   ];

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

//   void _toggleSelectAll() {
//     setState(() {
//       _selectAll = !_selectAll;
//       _selectedStudents = List.generate(12, (_) => _selectAll);
//       if (_selectAll) {
//         _selectedRowIndices = List.generate(12, (index) => index);
//       } else {
//         _selectedRowIndices.clear();
//       }
//     });
//   }

//   void _toggleRowSelection(int index) {
//     setState(() {
//       _selectedStudents[index] = !_selectedStudents[index];
//       _selectAll = _selectedStudents.every((element) => element);
//       if (_selectedStudents[index]) {
//         _selectedRowIndices.add(index);
//       } else {
//         _selectedRowIndices.remove(index);
//       }
//     });
//   }


//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Wednesday 20 July, 2024',
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
//         backgroundColor: AppColors.backgroundLight,
//         flexibleSpace: FlexibleSpaceBar(
//           background: Stack(
//             children: [
//               Positioned.fill(
//                 child: Opacity(
//                   opacity: opacity,
//                   child: Image.asset(
//                     'assets/images/background.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//       body: Container(
//         decoration: Constants.customBoxDecoration(context),
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: _toggleSelectAll,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//                 decoration: BoxDecoration(
//                     color: _selectedRowIndices.contains(0) ? const Color.fromRGBO(239, 227, 255, 1) : AppColors.attBgColor1,
//                     border: Border.all(color: AppColors.attBorderColor1)),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Select all students',
//                       style: AppTextStyles.normal500(
//                           fontSize: 16.0, color: AppColors.backgroundDark),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(4.0),
//                       decoration: BoxDecoration(
//                           color: _selectAll ? AppColors.attCheckColor1 : AppColors.attBgColor1,
//                           shape: BoxShape.circle,
//                           border: Border.all(color: AppColors.attCheckColor1)),
//                       child: Icon(
//                         Icons.check,
//                         color: _selectAll ? Colors.white : AppColors.attCheckColor1,
//                         size: 16,
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//             Expanded(
//               child: ListView.separated(
//                 itemCount: 12,
//                 separatorBuilder: (context, index) => Divider(
//                   color: Colors.grey[300],
//                   height: 1,
//                 ),
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     tileColor: _selectedRowIndices.contains(index) ? const Color.fromRGBO(239, 227, 255, 1) : Colors.transparent, // Update background color
//                     leading: CircleAvatar(
//                       backgroundColor: _circleColors[index],
//                       child: Text(
//                         _studentNames[index][0],
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ),
//                     title: Text(_studentNames[index]),
//                     trailing: _selectedStudents[index]
//                         ? const Icon(Icons.check_circle, color: AppColors.attCheckColor2)
//                         : null,
//                     onTap: () {
//                       _toggleRowSelection(index);
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }