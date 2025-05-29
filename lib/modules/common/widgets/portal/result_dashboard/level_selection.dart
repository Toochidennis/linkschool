import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:linkschool/modules/admin/e_learning/empty_syllabus_screen.dart';
import 'package:linkschool/modules/admin/result/class_detail/class_detail_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class LevelSelection extends StatefulWidget {
  final List<dynamic> levelNames; // List of level names
  final List<dynamic>? classNames;
  final List<String>? subjects; // Add subjects for course selection
  final bool isSecondScreen; // Flag to determine if it's for courses or classes

  const LevelSelection({
    super.key,
    required this.levelNames,
    this.classNames,
    this.subjects = const [], // Default empty list for subjects
    this.isSecondScreen = false, // Default to class selection
  });

  @override
  State<LevelSelection> createState() => _LevelSelectionState();
}

class _LevelSelectionState extends State<LevelSelection> {
  String _selectedLevel = '';
  String _selectedLevelId = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dynamically generate level boxes based on levelNames
        ...widget.levelNames.map((level) {
          final levelId = level[0]; // level_id is at index 0
          final levelName = level[1]; // level_name is at index 1
          return _buildLevelBox(levelId, levelName, 'assets/images/result/bg_box1.svg');
        }),
        const SizedBox(
          height: 100,
        )
      ],
    );
  }

  Widget _buildLevelBox(String levelId, String levelText, String backgroundImagePath) {
    return GestureDetector(
      onTap: () => _toggleOverlay(levelId, levelText),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.transparent,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              SvgPicture.asset(
                backgroundImagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      levelText,
                      style: AppTextStyles.normal700P(
                          fontSize: 20.0,
                          color: AppColors.backgroundLight,
                          height: 1.04),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      width: 170,
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.backgroundLight, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextButton(
                        onPressed: () => _toggleOverlay(levelId, levelText),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'View level performance',
                          style: AppTextStyles.normal700P(
                              fontSize: 12,
                              color: AppColors.backgroundLight,
                              height: 1.2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleOverlay(String levelId, String levelText) {
    setState(() {
      _selectedLevel = levelText;
      _selectedLevelId = levelId;
      if (widget.isSecondScreen) {
        _showCourseSelectionDialog(); // Show course selection dialog
      } else {
        _showClassSelectionDialog(); // Show class selection dialog
      }
    });
  }

  void _showClassSelectionDialog() {
    // Filter classes that match the selected level
    final filteredClasses = (widget.classNames ?? [])
        .where((cls) => cls[2] == _selectedLevelId)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Select Class',
                  style: AppTextStyles.normal600(
                      fontSize: 24, color: Colors.black),
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: ListView.builder(
                    itemCount: filteredClasses.length,
                    itemBuilder: (context, index) {
                      final cls = filteredClasses[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: _buildClassButton(
                          cls[1], // class name
                          () {
                            Navigator.of(context).pop();
                            _navigateToClassDetail(cls[0], cls[1]); // class ID, class name
                          },
                        ),
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

  void _showCourseSelectionDialog() {
    final subjects =
        widget.subjects ?? ['Math', 'Science', 'English']; // Default subjects

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Select Course',
                  style: AppTextStyles.normal600(
                      fontSize: 24, color: Colors.black),
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: ListView.builder(
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: _buildSubjectButton(subjects[index]),
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

  Widget _buildClassButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2))
        ],
      ),
      child: Material(
        color: AppColors.dialogBtnColor,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Ink(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              child: Text(text,
                  style: AppTextStyles.normal600(
                      fontSize: 16, color: AppColors.backgroundDark)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectButton(String subject) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EmptySyllabusScreen(selectedSubject: subject),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        subject,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

void _navigateToClassDetail(String classId, String className) async {
  final userBox = Hive.box('userData');
  await userBox.put('selectedClassId', classId); // Persist selected class ID
  await userBox.put('selectedLevelId', _selectedLevelId); // Persist selected level ID

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ClassDetailScreen(
        classId: classId,
        className: className,
        levelId: _selectedLevelId, // Pass the level ID
      ),
    ),
  );
}

  // void _navigateToClassDetail(String classId, String className) async {
  //   final userBox = Hive.box('userData');
  //   await userBox.put('selectedClassId', classId); // Persist selected class ID

  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => ClassDetailScreen(
  //         classId: classId,
  //         className: className,
  //       ),
  //     ),
  //   );
  // }
}



// class LevelSelection extends StatefulWidget {
//   // const LevelSelection({Key? key}) : super(key: key);
//   final bool isSecondScreen;
//   final List<String> subjects;

//   const LevelSelection({
//     super.key,
//     this.isSecondScreen = false,
//     this.subjects = const [],
//   });

//   @override
//   State<LevelSelection> createState() => _LevelSelectionState();
// }

// class _LevelSelectionState extends State<LevelSelection> {
//   String _selectedLevel = '';

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _buildLevelBox('BASIC ONE', 'assets/images/result/bg_box1.svg'),
//         _buildLevelBox('BASIC TWO', 'assets/images/result/bg_box2.svg'),
//         _buildLevelBox('JSS ONE', 'assets/images/result/bg_box3.svg'),
//         _buildLevelBox('JSS TWO', 'assets/images/result/bg_box4.svg'),
//         _buildLevelBox('JSS THREE', 'assets/images/result/bg_box5.svg'),
//         const SizedBox(
//           height: 100,
//         )
//       ],
//     );
//   }

//   Widget _buildLevelBox(String levelText, String backgroundImagePath) {
//     return GestureDetector(
//       onTap: () => _toggleOverlay(levelText),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//         child: Container(
//           height: 140,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             color: Colors.transparent,
//           ),
//           clipBehavior: Clip.antiAlias,
//           child: Stack(
//             children: [
//               SvgPicture.asset(
//                 backgroundImagePath,
//                 width: double.infinity,
//                 height: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       levelText,
//                       style: AppTextStyles.normal700P(
//                           fontSize: 20.0,
//                           color: AppColors.backgroundLight,
//                           height: 1.04),
//                     ),
//                     const SizedBox(height: 40),
//                     Container(
//                       width: 170,
//                       height: 32,
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                             color: AppColors.backgroundLight, width: 1),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: TextButton(
//                         onPressed: () => _toggleOverlay(levelText),
//                         style: TextButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 8),
//                           minimumSize: Size.zero,
//                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         ),
//                         child: Text(
//                           'View level performance',
//                           style: AppTextStyles.normal700P(
//                               fontSize: 12,
//                               color: AppColors.backgroundLight,
//                               height: 1.2),
//                           // overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
// // lib/widgets/level_selection.dart (continued)
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _toggleOverlay(String level) {
//     setState(() {
//       _selectedLevel = level;
//       if (widget.isSecondScreen) {
//         _showCourseSelectionDialog();
//       } else {
//         _showClassSelectionDialog();
//       }
//     });
//   }

// void _showClassSelectionDialog() {
//   final classes = [
//     'A',
//     'B',
//     'C',
//     'D',
//     'E',
//   ];
//   final levelPrefix = _selectedLevel.split(' ')[0];

//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     builder: (BuildContext context) {
//       return Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxHeight: MediaQuery.of(context).size.height * 0.6,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(height: 24),
//               Text(
//                 'Select Class',
//                 style: AppTextStyles.normal600(
//                     fontSize: 24, color: Colors.black),
//               ),
//               const SizedBox(height: 24),
//               Flexible(
//                 child: ListView.builder(
//                   itemCount: classes.length,
//                   itemBuilder: (context, index) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 8),
//                       child: _buildClassButton(
//                         '$levelPrefix ${classes[index]}',
//                         () {
//                           Navigator.of(context).pop();
//                           _navigateToClassDetail(
//                               '$levelPrefix ${classes[index]}');
//                         },
//                       ),
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

// Widget _buildClassButton(String text, VoidCallback onPressed) {
//   return Container(
//     decoration: BoxDecoration(
//       boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 2))],
//     ),
//     child: Material(
//       color: AppColors.dialogBtnColor,
//       child: InkWell(
//         onTap: onPressed,
//         borderRadius: BorderRadius.circular(4),
//         child: Ink(
//           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
//           child: Container(
//             width: double.infinity,
//             height: 50,
//             alignment: Alignment.center,
//             child: Text(text, style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundDark)),
//           ),
//         ),
//       ),
//     ),
//   );
// }


//   void _showCourseSelectionDialog() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (BuildContext context) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//           ),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.6,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const SizedBox(height: 24),
//                 Text(
//                   'Select Course',
//                   style: AppTextStyles.normal600(
//                       fontSize: 24, color: Colors.black),
//                 ),
//                 const SizedBox(height: 24),
//                 Flexible(
//                   child: ListView.builder(
//                     itemCount: widget.subjects.length,
//                     itemBuilder: (context, index) {
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 24, vertical: 8),
//                         child: _buildSubjectButton(widget.subjects[index]),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSubjectButton(String subject) {
//     return ElevatedButton(
//       onPressed: () {
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => EmptySyllabusScreen(selectedSubject: subject),
//           ),
//         );
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.white,
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 16),
//       ),
//       child: Text(
//         subject,
//         style: const TextStyle(fontSize: 16),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   void _navigateToClassDetail(String className) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => ClassDetailScreen(className: className),
//       ),
//     );
//   }
// }