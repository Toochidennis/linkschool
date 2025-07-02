// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/admin/e_learning/create_syllabus_screen.dart';
import 'package:linkschool/modules/admin/e_learning/empty_subject_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class EmptySyllabusScreen extends StatefulWidget {
  final String selectedSubject;
  final String? courseId; // Course ID for course selection
  final String? classId; // Class ID for class selection
  final String? levelId; // Level ID for course selection

  const EmptySyllabusScreen({super.key, required this.selectedSubject, this.courseId, this.classId, this.levelId});

  @override
  State<EmptySyllabusScreen> createState() => _EmptySyllabusScreenState();
}

class _EmptySyllabusScreenState extends State<EmptySyllabusScreen> {
  final List<Map<String, dynamic>> _syllabusList = [];
  late double opacity;

  @override
  void initState() {
    super.initState();
    _loadSyllabuses();
  }

  // Load existing syllabuses - replace with actual data loading logic
  void _loadSyllabuses() {
    // TODO: Replace with actual data loading from database/API
    // For now, you can add some sample data to test:
    /*
    setState(() {
      _syllabusList.addAll([
        {
          'title': 'Sample Syllabus 1',
          'selectedClass': 'Grade 10',
          'selectedTeacher': 'John Doe',
          'backgroundImagePath': 'assets/images/sample_bg.svg',
        },
      ]);
    });
    */
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
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Syllabus',
          style: AppTextStyles.normal600(
              fontSize: 24.0, color: AppColors.primaryLight),
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
        child:
            _syllabusList.isEmpty ? _buildEmptyState() : _buildSyllabusList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSyllabus,
        backgroundColor: AppColors.videoColor4,
        child: SvgPicture.asset(
          'assets/icons/e_learning/plus.svg',
          color: Colors.white,
        ),
      ),
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

  Widget _buildSyllabusList() {
    return ListView.builder(
      itemCount: _syllabusList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmptySubjectScreen(
                courseTitle: _syllabusList[index]['title']?.toString() ?? '',
              ),
            ),
          ),
          child: _buildOutlineContainers(_syllabusList[index], index),
        );
      },
    );
  }

  void _addNewSyllabus() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) => CreateSyllabusScreen(
          classId:widget.classId,
          courseId: widget.courseId,
          levelId: widget.levelId,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _syllabusList.add(result as Map<String, dynamic>);
      });
    }
  }

  void _editSyllabus(int index) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => CreateSyllabusScreen(
          syllabusData: _syllabusList[index],
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _syllabusList[index] = result as Map<String, dynamic>;
      });
    }
  }

  void _deleteSyllabus(int index) {
    setState(() {
      _syllabusList.removeAt(index);
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

  Widget _buildOutlineContainers(Map<String, dynamic> syllabus, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.transparent,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (syllabus['backgroundImagePath'] != null)
              SvgPicture.asset(
                syllabus['backgroundImagePath'] as String,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          syllabus['title']?.toString() ?? '',
                          style: AppTextStyles.normal700(
                            fontSize: 18,
                            color: AppColors.backgroundLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/result/edit.svg',
                          color: Colors.white,
                          width: 20,
                          height: 20,
                        ),
                        onPressed: () => _editSyllabus(index),
                      ),
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/result/delete.svg',
                          color: Colors.white,
                          width: 20,
                          height: 20,
                        ),
                        onPressed: () => _confirmDeleteSyllabus(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    syllabus['selectedClass']?.toString() ?? '',
                    style: AppTextStyles.normal500(
                      fontSize: 18,
                      color: AppColors.backgroundLight,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    syllabus['selectedTeacher']?.toString() ?? '',
                    style: AppTextStyles.normal600(
                      fontSize: 14,
                      color: AppColors.backgroundLight,
                    ),
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