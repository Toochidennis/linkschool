// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/portal/e-learning/create_syllabus_screen.dart';
import 'package:linkschool/modules/portal/e-learning/empty_subject_screen.dart';

class EmptySyllabusScreen extends StatefulWidget {
  const EmptySyllabusScreen({super.key});

  @override
  State<EmptySyllabusScreen> createState() => _EmptySyllabusScreenState();
}

class _EmptySyllabusScreenState extends State<EmptySyllabusScreen> {
  List<Map<String, dynamic>> _syllabusList = [];

  @override
  Widget build(BuildContext context) {
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
        Text('No syllabus have been created'),
        SizedBox(height: 15),
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
              padding: EdgeInsets.all(12),
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
              builder: (context) =>
                  EmptySubjectScreen(title: _syllabusList[index]['title']),
            ),
          ),
          child: _buildOutlineContainers(
            _syllabusList[index]['title'],
            _syllabusList[index]['backgroundImagePath'],
            _syllabusList[index]['selectedClass'],
            _syllabusList[index]['selectedTeacher'],
          ),
        );
      },
    );
  }

  void _addNewSyllabus() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) => CreateSyllabusScreen(),
      ),
    );
    if (result != null) {
      setState(() {
        _syllabusList.add(result);
      });
    }
  }

  Widget _buildOutlineContainers(String title, String backgroundImagePath,
      String selectedClass, String selectedTeacher) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.transparent),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.normal700(
                      fontSize: 18,
                      color: AppColors.backgroundLight,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'BASIC ONE,: $selectedClass',
                    style: AppTextStyles.normal500(
                      fontSize: 18,
                      color: AppColors.backgroundLight,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    selectedTeacher,
                    style: AppTextStyles.normal600(
                      fontSize: 14,
                      color: AppColors.backgroundLight,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
