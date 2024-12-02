import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/staff_portal/e_learning/staff_create_syllabus_screen.dart';

class StaffCourseDetailScreen extends StatefulWidget {
  final String courseTitle;

  const StaffCourseDetailScreen({
    super.key, 
    required this.courseTitle
  });

  @override
  State<StaffCourseDetailScreen> createState() => _StaffCourseDetailScreenState();
}

class _StaffCourseDetailScreenState extends State<StaffCourseDetailScreen> {
  List<Map<String, dynamic>> _syllabusList = [];
  late double opacity;
  int _currentIndex = 0; // For bottom navigation
  Map<String, dynamic>? _currentSyllabus; // To store the latest syllabus

  void _addNewSyllabus() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) => const StaffCreateSyllabusScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _syllabusList.add(result);
        _currentSyllabus = result; // Update current syllabus
      });
    }
  }

  void _editSyllabus(int index) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => StaffCreateSyllabusScreen(
          syllabusData: _syllabusList[index],
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _syllabusList[index] = result;
        _currentSyllabus = result; // Update current syllabus
      });
    }
  }

  void _deleteSyllabus(int index) {
    setState(() {
      _syllabusList.removeAt(index);
      if (_syllabusList.isEmpty) {
        _currentSyllabus = null; // Reset current syllabus if list is empty
      }
    });
  }

  void _confirmDeleteSyllabus(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Syllabus',
            style: AppTextStyles.normal600(
              fontSize: 20,
              color: AppColors.backgroundDark,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this syllabus?',
            style: AppTextStyles.normal500(
              fontSize: 16,
              color: AppColors.backgroundDark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'No',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteSyllabus(index);
                Navigator.of(context).pop();
              },
              child: Text(
                'Yes',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.paymentTxtColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          widget.courseTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.paymentTxtColor1,
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
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildCourseworkScreen(),
          _buildForumScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Coursework',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Forum',
          ),
        ],
      ),
    );
  }

  Widget _buildCourseworkScreen() {
    return Container(
      decoration: Constants.customBoxDecoration(context),
      child: _currentSyllabus == null 
        ? _buildEmptyState() 
        : _buildSyllabusDetails(),
    );
  }

  Widget _buildForumScreen() {
    return Container(
      decoration: Constants.customBoxDecoration(context),
      child: _currentSyllabus == null 
        ? _buildEmptyState() 
        : _buildSyllabusDetails(),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('No syllabus have been created'),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomMediumElevatedButton(
              text: 'Create new syllabus',
              onPressed: _addNewSyllabus,
              backgroundColor: AppColors.eLearningBtnColor1,
              textStyle: AppTextStyles.normal600(
                fontSize: 16,
                color: AppColors.backgroundLight,
              ),
              padding: const EdgeInsets.all(12),
            )
          ],
        )
      ],
    );
  }

  Widget _buildSyllabusDetails() {
    if (_currentSyllabus == null) return _buildEmptyState();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 95, // Fixed height as requested
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.transparent,
        ),
        // clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            SvgPicture.asset(
              _currentSyllabus!['backgroundImagePath'],
              width: double.infinity,
              height: 95, // Match container height
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentSyllabus!['title'],
                    style: AppTextStyles.normal700(
                      fontSize: 18,
                      color: AppColors.backgroundLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Class: ${_currentSyllabus!['selectedClass']}',
                    style: AppTextStyles.normal500(
                      fontSize: 14,
                      color: AppColors.backgroundLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Teacher: ${_currentSyllabus!['selectedTeacher']}',
                    style: AppTextStyles.normal600(
                      fontSize: 12,
                      color: AppColors.backgroundLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/staff_portal/e_learning/staff_create_syllabus_screen.dart';

// class StaffCourseDetailScreen extends StatefulWidget {
//   final String courseTitle;

//   const StaffCourseDetailScreen({
//     super.key, 
//     required this.courseTitle
//   });

//   @override
//   State<StaffCourseDetailScreen> createState() => _StaffCourseDetailScreenState();
// }

// class _StaffCourseDetailScreenState extends State<StaffCourseDetailScreen> {
//   List<Map<String, dynamic>> _syllabusList = [];
//   late double opacity;

//   void _addNewSyllabus() async {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         fullscreenDialog: true,
//         builder: (BuildContext context) => const StaffCreateSyllabusScreen(),
//       ),
//     );
//   }

//   void _editSyllabus(int index) async {
//     final result = await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (BuildContext context) => StaffCreateSyllabusScreen(
//           syllabusData: _syllabusList[index],
//         ),
//       ),
//     );
//     if (result != null) {
//       setState(() {
//         _syllabusList[index] = result;
//       });
//     }
//   }

//   void _deleteSyllabus(int index) {
//     setState(() {
//       _syllabusList.removeAt(index);
//     });
//   }

//   void _confirmDeleteSyllabus(int index) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(
//             'Delete Syllabus',
//             style: AppTextStyles.normal600(
//               fontSize: 20,
//               color: AppColors.backgroundDark,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to delete this syllabus?',
//             style: AppTextStyles.normal500(
//               fontSize: 16,
//               color: AppColors.backgroundDark,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text(
//                 'No',
//                 style: AppTextStyles.normal600(
//                   fontSize: 16,
//                   color: AppColors.primaryLight,
//                 ),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 _deleteSyllabus(index);
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 'Yes',
//                 style: AppTextStyles.normal600(
//                   fontSize: 16,
//                   color: Colors.red,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.paymentTxtColor1,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: Text(
//           widget.courseTitle,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: AppColors.paymentTxtColor1,
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
//         child:  _syllabusList.isEmpty ? _buildEmptyState() : _buildSyllabusList(),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         const Text('No syllabus have been created'),
//         const SizedBox(height: 15),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             CustomMediumElevatedButton(
//               text: 'Create new syllabus',
//               onPressed: _addNewSyllabus,
//               backgroundColor: AppColors.eLearningBtnColor1,
//               textStyle: AppTextStyles.normal600(
//                 fontSize: 16,
//                 color: AppColors.backgroundLight,
//               ),
//               padding: const EdgeInsets.all(12),
//             )
//           ],
//         )
//       ],
//     );
//   }

//   Widget _buildSyllabusList() {
//     return ListView.builder(
//       itemCount: _syllabusList.length,
//       itemBuilder: (context, index) {
//         return GestureDetector(
//           onTap: () {},
//           child: _buildOutlineContainers(_syllabusList[index], index),
//         );
//       },
//     );
//   }



//   Widget _buildOutlineContainers(Map<String, dynamic> syllabus, int index) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Container(
//         height: 150,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: Colors.transparent,
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Stack(
//           children: [
//             SvgPicture.asset(
//               syllabus['backgroundImagePath'],
//               width: double.infinity,
//               height: double.infinity,
//               fit: BoxFit.cover,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           syllabus['title'],
//                           style: AppTextStyles.normal700(
//                             fontSize: 18,
//                             color: AppColors.backgroundLight,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       IconButton(
//                         icon: SvgPicture.asset(
//                           'assets/icons/result/edit.svg',
//                           color: Colors.white,
//                           width: 20,
//                           height: 20,
//                         ),
//                         onPressed: () => _editSyllabus(index),
//                       ),
//                       IconButton(
//                         icon: SvgPicture.asset(
//                           'assets/icons/result/delete.svg',
//                           color: Colors.white,
//                           width: 20,
//                           height: 20,
//                         ),
//                         onPressed: () => _confirmDeleteSyllabus(index),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     syllabus['selectedClass'],
//                     style: AppTextStyles.normal500(
//                       fontSize: 18,
//                       color: AppColors.backgroundLight,
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   Text(
//                     syllabus['selectedTeacher'],
//                     style: AppTextStyles.normal600(
//                       fontSize: 14,
//                       color: AppColors.backgroundLight,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }