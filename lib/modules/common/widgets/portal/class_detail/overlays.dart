import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/admin/result/class_detail/student_result/comment_course_result_screen.dart';
import 'package:linkschool/modules/admin/result/class_detail/student_result/course_result_screen.dart';
import 'package:linkschool/modules/admin/result/class_detail/student_result/student_result.dart';
import 'package:linkschool/modules/admin/result/class_detail/student_result/composite_result_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/staff/e_learning/form_classes/edit_staff_skill_behaviour_screen.dart';
import 'package:linkschool/modules/staff/e_learning/form_classes/staff_skill_behaviour_screen.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/providers/admin/student_provider.dart';

void showStudentResultOverlay(BuildContext context, {String? classId, String? className}) {
  final studentProvider = Provider.of<StudentProvider>(context, listen: false);
  
  if (classId != null) {
    studentProvider.fetchStudents(classId);
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.5,
          builder: (_, controller) {
            return GestureDetector(
              onTap: () {},
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          // Filter functionality could be added here
                        },
                      ),
                    ),
                    Expanded(
                      child: Consumer<StudentProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          
                          if (provider.errorMessage.isNotEmpty) {
                            return Center(
                              child: Text(
                                'Error: ${provider.errorMessage}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }
                          
                          if (provider.students.isEmpty) {
                            return const Center(
                              child: Text('No students available in this class'),
                            );
                          }
                          
                          return ListView.separated(
                            controller: controller,
                            itemCount: provider.students.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final student = provider.students[index];
                              final firstLetter = student.fullName.isNotEmpty ? 
                                  student.fullName[0].toUpperCase() : 'S';
                              
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.primaries[index % Colors.primaries.length],
                                  child: Text(
                                    firstLetter,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(student.name),
                                onTap: () {
                                  provider.fetchStudentResultTerms(student.id);
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudentResultScreen(
                                        studentName: student.fullName,
                                        className: className,
                                        studentId: student.id,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

void showTermOverlay(BuildContext context, {required String classId, required String levelId, required String year, required int termId, required String termName, required bool isCurrentTerm}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final icons = [
                      'assets/icons/result/comment.svg',
                      'assets/icons/result/skill.svg',
                      'assets/icons/result/course.svg',
                      'assets/icons/result/composite_result.svg',
                    ];
                    final labels = [
                      'Comment on results',
                      'Skills and Behaviour',
                      'Course result',
                      'Composite result',
                    ];
                    final colors = [
                      AppColors.bgColor2,
                      AppColors.bgColor3,
                      AppColors.bgColor4,
                      AppColors.bgColor5,
                    ];
                    final iconColors = [
                      AppColors.iconColor1,
                      AppColors.iconColor2,
                      AppColors.iconColor3,
                      AppColors.iconColor4,
                    ];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors[index],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            icons[index],
                            color: iconColors[index],
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      title: Text(labels[index]),
                      onTap: () {
                        Navigator.pop(context); // Close the overlay first
                        
                        if (labels[index] == 'Comment on results') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommentCourseResultScreen(
                                classId: classId,
                                year: year,
                                term: termId,
                                termName: termName,
                                isCurrentTerm: isCurrentTerm,
                              ),
                            ),
                          );
                        } else if (labels[index] == 'Course result') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseResultScreen(
                                classId: classId,
                                year: year,
                                term: termId,
                                termName: termName,
                              ),
                            ),
                          );
                        } else if (labels[index] == 'Skills and Behaviour') {
                          _showSkillsBehaviourOverlay(context, classId: classId, levelId: levelId, year: year, termId: termId, termName: termName);
                        } else if (labels[index] == 'Composite result') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CompositeResultScreen(
                                classId: classId,
                                year: year,
                                termId: termId,
                                termName: termName,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showSkillsBehaviourOverlay(BuildContext context, {required String classId, required String levelId, required String year, required int termId, required String termName}) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Skills and Behaviour',
                    style: AppTextStyles.normal600(
                        fontSize: 16, color: AppColors.backgroundDark),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogButton(
                        'Add',
                        'assets/icons/result/edit.svg',
                        () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditSkillsBehaviourScreen(
                                classId: classId,
                                levelId: levelId,
                                term: termId.toString(),
                                year: year,
                                db: 'aalmgzmy_linkskoo_practice',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: _buildDialogButton(
                        'View',
                        'assets/icons/result/eye.svg',
                        () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StaffSkillsBehaviourScreen(
                                classId: classId,
                                levelId: levelId,
                                term: termId.toString(),
                                year: year,
                                db: 'aalmgzmy_linkskoo_practice',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildDialogButton(String text, String iconPath, VoidCallback onPressed) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8),
    ),
    child: TextButton.icon(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        iconPath,
        color: Colors.grey,
      ),
      label: Text(
        text,
        style: AppTextStyles.normal600(
            fontSize: 14, color: AppColors.backgroundDark),
      ),
    ),
  );
}



// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:linkschool/modules/admin/result/class_detail/student_result/comment_course_result_screen.dart';
// import 'package:linkschool/modules/admin/result/class_detail/student_result/course_result_screen.dart';
// import 'package:linkschool/modules/admin/result/class_detail/student_result/student_result.dart';
// import 'package:linkschool/modules/admin/result/class_detail/student_result/composite_result_screen.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/staff/e_learning/form_classes/edit_staff_skill_behaviour_screen.dart';
// import 'package:linkschool/modules/staff/e_learning/form_classes/staff_skill_behaviour_screen.dart';
// // import 'package:linkschool/modules/staff/e_learning/form_classes/edit_skills_behaviour_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:linkschool/modules/providers/admin/student_provider.dart';

// void showStudentResultOverlay(BuildContext context, {String? classId, String? className}) {
//   final studentProvider = Provider.of<StudentProvider>(context, listen: false);
  
//   if (classId != null) {
//     studentProvider.fetchStudents(classId);
//   }

//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     isDismissible: true,
//     backgroundColor: Colors.transparent,
//     builder: (BuildContext context) {
//       return GestureDetector(
//         onTap: () => Navigator.of(context).pop(),
//         child: DraggableScrollableSheet(
//           initialChildSize: 0.4,
//           minChildSize: 0.2,
//           maxChildSize: 0.5,
//           builder: (_, controller) {
//             return GestureDetector(
//               onTap: () {},
//               child: Container(
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                 ),
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: TextField(
//                         decoration: InputDecoration(
//                           hintText: 'Search...',
//                           prefixIcon: const Icon(Icons.search),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         onChanged: (value) {
//                           // Filter functionality could be added here
//                         },
//                       ),
//                     ),
//                     Expanded(
//                       child: Consumer<StudentProvider>(
//                         builder: (context, provider, child) {
//                           if (provider.isLoading) {
//                             return const Center(
//                               child: CircularProgressIndicator(),
//                             );
//                           }
                          
//                           if (provider.errorMessage.isNotEmpty) {
//                             return Center(
//                               child: Text(
//                                 'Error: ${provider.errorMessage}',
//                                 style: const TextStyle(color: Colors.red),
//                               ),
//                             );
//                           }
                          
//                           if (provider.students.isEmpty) {
//                             return const Center(
//                               child: Text('No students available in this class'),
//                             );
//                           }
                          
//                           return ListView.separated(
//                             controller: controller,
//                             itemCount: provider.students.length,
//                             separatorBuilder: (context, index) => const Divider(),
//                             itemBuilder: (context, index) {
//                               final student = provider.students[index];
//                               final firstLetter = student.fullName.isNotEmpty ? 
//                                   student.fullName[0].toUpperCase() : 'S';
                              
//                               return ListTile(
//                                 leading: CircleAvatar(
//                                   backgroundColor: Colors.primaries[index % Colors.primaries.length],
//                                   child: Text(
//                                     firstLetter,
//                                     style: const TextStyle(color: Colors.white),
//                                   ),
//                                 ),
//                                 title: Text(student.name),
//                                 onTap: () {
//                                   provider.fetchStudentResultTerms(student.id);
//                                   Navigator.pop(context);
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => StudentResultScreen(
//                                         studentName: student.fullName,
//                                         className: className,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       );
//     },
//   );
// }

// void showTermOverlay(BuildContext context, {required String classId, required String levelId, required String year, required int termId, required String termName}) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (BuildContext context) {
//       return Container(
//         height: MediaQuery.of(context).size.height * 0.4,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
//           child: Column(
//             children: [
//               Expanded(
//                 child: ListView.separated(
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: 4,
//                   separatorBuilder: (context, index) => const Divider(),
//                   itemBuilder: (context, index) {
//                     final icons = [
//                       'assets/icons/result/comment.svg',
//                       'assets/icons/result/skill.svg',
//                       'assets/icons/result/course.svg',
//                       'assets/icons/result/composite_result.svg',
//                     ];
//                     final labels = [
//                       'Comment on results',
//                       'Skills and Behaviour',
//                       'Course result',
//                       'Composite result',
//                     ];
//                     final colors = [
//                       AppColors.bgColor2,
//                       AppColors.bgColor3,
//                       AppColors.bgColor4,
//                       AppColors.bgColor5,
//                     ];
//                     final iconColors = [
//                       AppColors.iconColor1,
//                       AppColors.iconColor2,
//                       AppColors.iconColor3,
//                       AppColors.iconColor4,
//                     ];
//                     return ListTile(
//                       leading: Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: colors[index],
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Center(
//                           child: SvgPicture.asset(
//                             icons[index],
//                             color: iconColors[index],
//                             width: 20,
//                             height: 20,
//                           ),
//                         ),
//                       ),
//                       title: Text(labels[index]),
//                       onTap: () {
//                         Navigator.pop(context); // Close the overlay first
                        
//                         if (labels[index] == 'Comment on results') {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => CommentCourseResultScreen(
//                                 classId: classId,
//                                 year: year,
//                                 term: termId,
//                                 termName: termName,
//                               ),
//                             ),
//                           );
//                         } else if (labels[index] == 'Course result') {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => CourseResultScreen(
//                                 classId: classId,
//                                 year: year,
//                                 term: termId,
//                                 termName: termName,
//                               ),
//                             ),
//                           );
//                         } else if (labels[index] == 'Skills and Behaviour') {
//                           _showSkillsBehaviourOverlay(context, classId: classId, levelId: levelId, year: year, termId: termId, termName: termName);
//                         } else if (labels[index] == 'Composite result') {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => CompositeResultScreen(
//                                 classId: classId,
//                                 year: year,
//                                 termId: termId,
//                                 termName: termName,
//                               ),
//                             ),
//                           );
//                         }
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }

// void _showSkillsBehaviourOverlay(BuildContext context, {required String classId, required String levelId, required String year, required int termId, required String termName}) {
//   showModalBottomSheet(
//     context: context,
//     builder: (BuildContext context) {
//       return Container(
//         color: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 8.0),
//                   child: Text(
//                     'Skills and Behaviour',
//                     style: AppTextStyles.normal600(
//                         fontSize: 16, color: AppColors.backgroundDark),
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildDialogButton(
//                         'Add',
//                         'assets/icons/result/edit.svg',
//                         () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => EditSkillsBehaviourScreen(
//                                 classId: classId,
//                                 levelId: levelId,
//                                 term: termId.toString(),
//                                 year: year,
//                                 db: 'aalmgzmy_linkskoo_practice',
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 8.0),
//                     Expanded(
//                       child: _buildDialogButton(
//                         'View',
//                         'assets/icons/result/eye.svg',
//                         () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => StaffSkillsBehaviourScreen(
//                                 classId: classId,
//                                 levelId: levelId,
//                                 term: termId.toString(),
//                                 year: year,
//                                 db: 'aalmgzmy_linkskoo_practice',
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

// Widget _buildDialogButton(String text, String iconPath, VoidCallback onPressed) {
//   return Container(
//     decoration: BoxDecoration(
//       border: Border.all(color: Colors.grey),
//       borderRadius: BorderRadius.circular(8),
//     ),
//     child: TextButton.icon(
//       onPressed: onPressed,
//       icon: SvgPicture.asset(
//         iconPath,
//         color: Colors.grey,
//       ),
//       label: Text(
//         text,
//         style: AppTextStyles.normal600(
//             fontSize: 14, color: AppColors.backgroundDark),
//       ),
//     ),
//   );
// }