// lib/modules/admin/result/class_detail/attendance/take_course_attendance.dart
import 'package:flutter/material.dart';
import 'package:linkschool/modules/providers/admin/student_attendance_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_floating_save_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';


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
      context.read<StudentAttendanceProvider>().fetchStudents(widget.classId);
    });
  }

  @override
  void dispose() {
    // Reset provider state when navigating away
    context.read<StudentAttendanceProvider>().reset();
    super.dispose();
  }

  void _setCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE dd MMMM, yyyy');
    _currentDate = formatter.format(now);
  }

  void _onSavePressed() {
    final provider = context.read<StudentAttendanceProvider>();
    provider.saveAttendance(
      classId: widget.classId,
      courseId: widget.courseId,
      date: _currentDate
    ).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance saved successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage.isNotEmpty 
              ? provider.errorMessage 
              : 'Failed to save attendance'),
            backgroundColor: Colors.red,
          ),
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
      body: Consumer<StudentAttendanceProvider>(
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
      floatingActionButton: CustomFloatingSaveButton(
        onPressed: _onSavePressed,
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/buttons/custom_floating_save_button.dart';
// import 'package:linkschool/modules/common/text_styles.dart';


// class TakeCourseAttendance extends StatefulWidget {
//   final String? courseId;
//   final String? classId;
//   const TakeCourseAttendance({super.key, this.courseId, this.classId});

//   @override
//   State<TakeCourseAttendance> createState() => _TakeCourseAttendanceState();
// }

// class _TakeCourseAttendanceState extends State<TakeCourseAttendance> {
//   List<bool> _selectedStudents = List.generate(12, (_) => false);
//   bool _selectAll = false;
//   List<int> _selectedRowIndices = [];

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

//   void _onSavePressed() {
//     // Add your save logic here
//     debugPrint('Save button pressed');
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Attendance saved successfully'),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundLight,
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
//       ),
//       body: Column(
//         children: [
//           GestureDetector(
//             onTap: _toggleSelectAll,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//               decoration: BoxDecoration(
//                   color: _selectedRowIndices.contains(0) ? const Color.fromRGBO(239, 227, 255, 1) : AppColors.attBgColor1,
//                   border: Border.all(color: AppColors.attBorderColor1)),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Select all students',
//                     style: AppTextStyles.normal500(
//                         fontSize: 16.0, color: AppColors.backgroundDark),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.all(4.0),
//                     decoration: BoxDecoration(
//                         color: _selectAll ? AppColors.attCheckColor1 : AppColors.attBgColor1,
//                         shape: BoxShape.circle,
//                         border: Border.all(color: AppColors.attCheckColor1)),
//                     child: Icon(
//                       Icons.check,
//                       color: _selectAll ? Colors.white : AppColors.attCheckColor1,
//                       size: 16,
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.separated(
//               itemCount: 12,
//               separatorBuilder: (context, index) => Divider(
//                 color: Colors.grey[300],
//                 height: 1,
//               ),
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   tileColor: _selectedRowIndices.contains(index) ? const Color.fromRGBO(239, 227, 255, 1) : Colors.transparent, // Update background color
//                   leading: CircleAvatar(
//                     backgroundColor: _circleColors[index],
//                     child: Text(
//                       _studentNames[index][0],
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//                   title: Text(_studentNames[index]),
//                   trailing: _selectedStudents[index]
//                       ? const Icon(Icons.check_circle, color: AppColors.attCheckColor2)
//                       : null,
//                   onTap: () {
//                     _toggleRowSelection(index);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       // Add the CustomFloatingSaveButton here
//       floatingActionButton: CustomFloatingSaveButton(
//         onPressed: _onSavePressed,
//       ),
//     );
//   }
// }