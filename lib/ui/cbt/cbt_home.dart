import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:linkschool/common/text_styles.dart';

import '../../common/app_colors.dart';
import '../../common/constants.dart';

class CBTHome extends StatefulWidget {
  const CBTHome({super.key});

  @override
  State<CBTHome> createState() => _CBTHomeState();
}

class _CBTHomeState extends State<CBTHome> {
  @override
  Widget build(BuildContext context) {
    final metrics = [
      Expanded(
        child: _buildPerformanceCard(
          imagePath: 'assets/icons/test.png',
          title: 'Tests',
          completionRate: '123',
          backgroundColor: AppColors.cbtColor1,
          borderColor: AppColors.cbtBorderColor1,
        ),
      ),
      const SizedBox(width: 16.0),
      Expanded(
        child: _buildPerformanceCard(
          imagePath: 'assets/icons/success.png',
          title: 'Success',
          completionRate: '123%',
          backgroundColor: AppColors.cbtColor2,
          borderColor: AppColors.cbtBorderColor2,
        ),
      ),
      const SizedBox(width: 16.0),
      Expanded(
        child: _buildPerformanceCard(
          imagePath: 'assets/icons/average.png',
          title: 'Average',
          completionRate: '123%',
          backgroundColor: AppColors.cbtColor3,
          borderColor: AppColors.cbtBorderColor3,
          marginEnd: 16.0,
        ),
      ),
    ];

    final subjects = [
      _buildChooseSubjectCard(
          subject: 'Mathematics',
          year: '2001-2014',
          cardColor: AppColors.cbtCardColor1,
          subjectIcon: 'maths'),
      _buildChooseSubjectCard(
          subject: 'English Language',
          year: '2001-2014',
          cardColor: AppColors.cbtCardColor2,
          subjectIcon: 'english'),
      _buildChooseSubjectCard(
          subject: 'Chemistry',
          year: '2001-2014',
          cardColor: AppColors.cbtCardColor3,
          subjectIcon: 'chemistry'),
      _buildChooseSubjectCard(
          subject: 'Physics',
          year: '2001-2014',
          cardColor: AppColors.cbtCardColor4,
          subjectIcon: 'physics'),
      _buildChooseSubjectCard(
          subject: 'Further Mathematics',
          year: '2001-2014',
          cardColor: AppColors.cbtCardColor5,
          subjectIcon: 'further_maths'),
    ];

    return Scaffold(
      appBar: Constants.customAppBar(
          context: context, iconPath: 'assets/icons/search.png'),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _dropDownButton(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: metrics,
                ),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 16.0)),
            SliverToBoxAdapter(child: _buildHeading(title: 'Test history')),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 16.0),
                  children: [
                    _buildHistoryCard(
                      courseName: 'Biology',
                      year: '2015',
                      progressValue: 0.5,
                      borderColor: AppColors.cbtColor3,
                    ),
                    _buildHistoryCard(
                      courseName: 'Biology',
                      year: '2015',
                      progressValue: 0.25,
                      borderColor: AppColors.cbtColor4,
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
            SliverToBoxAdapter(child: _buildHeading(title: 'Choose subject')),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return subjects[index];
                },
                childCount: subjects.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeading({required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.normal600(
              fontSize: 18.0,
              color: AppColors.text4Light,
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(),
            child: const Text(
              'See all',
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropDownButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: AppColors.text6Light,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'WAEC',
              style: AppTextStyles.normal600(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(width: 10.0),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard({
    required String title,
    required String completionRate,
    required String imagePath,
    required Color backgroundColor,
    required Color borderColor,
    double? marginEnd,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      height: 130.0,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            spreadRadius: 0,
            offset: const Offset(0, 1),
            blurRadius: 2,
            color: Colors.black.withOpacity(0.25),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            width: 24.0,
            height: 24.0,
          ),
          const SizedBox(height: 4.0),
          Text(
            completionRate,
            style: AppTextStyles.normal600(
              fontSize: 24.0,
              color: AppColors.backgroundLight,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            title,
            style: AppTextStyles.normal600(
              fontSize: 16.0,
              color: AppColors.backgroundLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String courseName,
    required String year,
    required double progressValue,
    required borderColor,
  }) {
    return Container(
      width: 195,
      margin: const EdgeInsets.only(left: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 70.0,
                width: 70.0,
                child: CircularProgressIndicator(
                  color: borderColor,
                  value: progressValue,
                  strokeWidth: 7.5,
                ),
              ),
              Text(
                '${(progressValue * 100).round()}%',
                style: AppTextStyles.normal600(
                  fontSize: 16.0,
                  color: AppColors.text4Light,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biology',
                  style: AppTextStyles.normal600(
                    fontSize: 16.0,
                    color: AppColors.text4Light,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '($year)',
                  style: AppTextStyles.normal600(
                    fontSize: 12.0,
                    color: AppColors.text7Light,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Tap to retake',
                  style: AppTextStyles.normal600(
                    fontSize: 14.0,
                    color: AppColors.text8Light,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChooseSubjectCard({
    required String subject,
    required String year,
    required cardColor,
    required subjectIcon,
  }) {
    return Container(
      width: double.infinity,
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.cbtColor5))),
      child: Row(
        children: [
          Container(
            width: 60,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Center(
              child: Image.asset(
                'assets/icons/$subjectIcon.png',
                width: 24.0,
                height: 24.0,
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: AppTextStyles.normal600(
                    fontSize: 16.0,
                    color: AppColors.backgroundDark,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  year,
                  style: AppTextStyles.normal600(
                    fontSize: 12.0,
                    color: AppColors.text9Light,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
