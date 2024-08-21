import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';


class SyllabusOutlineScreen extends StatelessWidget {
  final String title;
  final String backgroundImagePath;
  final String description;
  final String selectedClass;
  final String selectedTeacher;

  const SyllabusOutlineScreen({
    Key? key,
    required this.title,
    required this.backgroundImagePath,
    required this.description,
    required this.selectedClass,
    required this.selectedTeacher,
  }) : super(key: key);

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
          'Syllabus Outline',
          style: AppTextStyles.normal600(
              fontSize: 24.0, color: Colors.black), 
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildOutlineContainers(
                  title, backgroundImagePath, selectedTeacher, selectedTeacher),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle save action
        },
        backgroundColor: AppColors.videoColor4,
        child: SvgPicture.asset(
          'assets/icons/e_learning/plus.svg',
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildOutlineContainers(String title, String backgroundImagePath,
      String selectedClass, String selectedTeacher) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.transparent),
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
                      style: AppTextStyles.normal700(fontSize: 18, color: AppColors.backgroundLight,),
                    ),
                    const SizedBox(height: 20,),
                    Text(
                      'BASIC ONE,: $selectedClass',
                      style: AppTextStyles.normal500(fontSize: 18, color: AppColors.backgroundLight,),
                    ), 
                    const SizedBox(height: 40,),
                    Text(
                      selectedTeacher,
                      style: AppTextStyles.normal600(fontSize: 14, color: AppColors.backgroundLight,),
                    ), 
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
