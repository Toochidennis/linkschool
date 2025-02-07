import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

import 'package:linkschool/modules/explore/ebooks/subject_item.dart';

class newCbtScreen extends StatefulWidget {
  const newCbtScreen({super.key});


  @override
  State<newCbtScreen> createState() => _newCbtScreenState();

}

class _newCbtScreenState extends State<newCbtScreen> {
  int selectedCategoryIndex = 0;


    
  
  List<SubjectItem> subjectItems = [
    SubjectItem.name(
      'Mathematics',
      'maths',
      '2001-2014',
      AppColors.cbtCardColor1,
    ),
    SubjectItem.name(
      'English Language',
      'english',
      '2001-2014',
      AppColors.cbtCardColor2,
    ),
    SubjectItem.name(
      'Chemistry',
      'chemistry',
      '2001-2014',
      AppColors.cbtCardColor3,
    ),
    SubjectItem.name(
      'Physics',
      'physics',
      '2001-2014',
      AppColors.cbtCardColor4,
    ),
    SubjectItem.name(
      'Further Mathematics',
      'further_maths',
      '2001-2014',
      AppColors.cbtCardColor5,
    )
  ];

  @override
  Widget build(BuildContext context) {
    final metrics = [
      Expanded(
        child: _buildPerformanceCard(
          imagePath: 'assets/icons/test.png',
          title: 'Tests',
          completionRate: '0',
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

    return Scaffold(
  body: Container(
    decoration: Constants.customBoxDecoration(context),
    child: CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: metrics,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 11.0)),

        SliverToBoxAdapter(child:Constants.headingWithSeeAll600(
                      title: 'Test history',
                      titleSize: 18.0,
                      titleColor: AppColors.text4Light,
                    ),),

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
        SliverToBoxAdapter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Constants.headingWithSeeAll600(
                title: 'Choose subject',
                titleSize: 18.0,
                titleColor: AppColors.text4Light,

              ),


              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text(
              'new user',
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),

          ),
            ],
          ),

        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = subjectItems[index];
              return _buildChooseSubjectCard(
                subject: item.subject,
                year: item.year,
                cardColor: item.cardColor,
                subjectIcon: item.subjectIcon,
              );
            },
            childCount: subjectItems.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100.0)),
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


Widget _buildHistoryCard({
    required String courseName,
    required String year,
    required double progressValue,
    required borderColor,
  }) {
    return Container(
      width: 169,
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
                height: 60.0,
                width: 60.0,
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