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
  final List<dynamic>? courseNames;
  final List<String>? subjects; 
  final String? courseId; // Course ID for course selection
  final String? classId; // Class ID for class selection
  final String? levelId; // Level ID for course selection
  // Add subjects for course selection
  final bool isSecondScreen; // Flag to determine if it's for courses or classes

  const LevelSelection({
    super.key,
    required this.levelNames,
    this.courseNames,
    this.classNames,
    this.subjects = const [], // Default empty list for subjects
    this.isSecondScreen = false, 
    this.courseId, 
    this.classId, 
    this.levelId, // Default to class selection
  });

  @override
  State<LevelSelection> createState() => _LevelSelectionState();
}

class _LevelSelectionState extends State<LevelSelection> {
  String _selectedLevel = '';
  String _selectedLevelId = '';

  final List<String> _imagePaths = [
    'assets/images/result/bg_box1.svg',
    'assets/images/result/bg_box2.svg',
    'assets/images/result/bg_box3.svg',
    'assets/images/result/bg_box4.svg',
    'assets/images/result/bg_box5.svg',
    'assets/images/result/bg_box6.svg',
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.levelNames.isEmpty && widget.isSecondScreen) {
      return _buildEmptyState('No levels with courses available');
    }
    return Column(
      children: [
        // Dynamically generate level boxes based on levelNames
        ...widget.levelNames.asMap().entries.map((entry) {
          final int index = entry.key;
          final level = entry.value;
          final levelId = level[0]; // level_id is at index 0
          final levelName = level[1]; // level_name is at index 1
          if (widget.isSecondScreen) {
            final hasCourse = widget.courseNames?.any((course) => course[1].toString().isNotEmpty) ?? false;
            if (!hasCourse) {
              return const SizedBox.shrink(); // Skip if no course is available
            }
          } else {
            final hasClasses = widget.classNames?.any((cls) => cls[2] == levelId) ?? false;
            if (!hasClasses) {
              return const SizedBox.shrink(); // Skip if no classes are available
            }
          }
       
          final imagePath = _imagePaths[index % _imagePaths.length];
          return _buildLevelBox(levelId, levelName, imagePath);
        }),
        const SizedBox(height: 100),
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
                  child: filteredClasses.isEmpty
                      ? _buildEmptyState('No classes available for this level')
                      : ListView.builder(
                          itemCount: filteredClasses.length,
                          itemBuilder: (context, index) {
                            final cls = filteredClasses[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: _buildSelectionButton(
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

  // In LevelSelection widget, update the _showCourseSelectionDialog method:

void _showCourseSelectionDialog() {
  final allCourses = (widget.courseNames ?? [])
      .where((course) => course[1].toString().isNotEmpty)
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
                'Select Course for $_selectedLevel', 
                style: AppTextStyles.normal600(
                    fontSize: 20, color: Colors.black),
              ),
              const SizedBox(height: 24),
              Flexible(
                child: allCourses.isEmpty
                    ? _buildEmptyState('No courses available')
                    : ListView.builder(
                        itemCount: allCourses.length,
                        itemBuilder: (context, index) {
                          final course = allCourses[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: _buildSelectionButton(
                              course[1], // course name
                              () async {
                                final userBox = Hive.box('userData');
                                await userBox.put('selectedCourseId', course[0]); // Save course ID
                                await userBox.put('selectedLevelId', _selectedLevelId); // Save level ID
                                
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EmptySyllabusScreen(
                                      courseId: course[0], // Pass actual course ID
                                      classId: widget.classId, // This might be null, handle it
                                      levelId: _selectedLevelId, // Pass actual selected level ID
                                      selectedSubject: course[1],
                                      course_name: widget.courseNames?[index][1] ?? '', // Pass course name
                                    ),
                                  ),
                                  
                                );
                               
                                print("selected Level ID: $_selectedLevelId");
                               
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

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          message,
          style: AppTextStyles.normal600(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionButton(String text, VoidCallback onPressed) {
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
              child: Text(
                text,
                style: AppTextStyles.normal600(
                    fontSize: 16, color: AppColors.backgroundDark),
              ),
            ),
          ),
        ),
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
           levelId: _selectedLevelId, 
        ),
      ),
    );
  }
}