import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

import 'package:linkschool/modules/explore/ebooks/subject_item.dart';

class E_CBTDashboard extends StatefulWidget {
  const E_CBTDashboard({super.key});

  @override
  State<E_CBTDashboard> createState() => _E_CBTDashboardState();
}

class _E_CBTDashboardState extends State<E_CBTDashboard> {
  int? selectedexamCategoriesIndex = 0;
  List<String> examCategories = <String>[
    'WAEC',
    'NECO',
    'WAEC',
    'JAMB',
    'UTME',
    'GCE',
    'SATs',
    'SATs',
    'SATs'
  ];

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
          completionRate: '0%',
          backgroundColor: AppColors.cbtColor2,
          borderColor: AppColors.cbtBorderColor2,
        ),
      ),
      const SizedBox(width: 16.0),
      Expanded(
        child: _buildPerformanceCard(
          imagePath: 'assets/icons/average.png',
          title: 'Average',
          completionRate: '0%',
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
              child: SizedBox(
                  height: 50,
                  width: 509.74,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    scrollDirection: Axis.horizontal,
                    itemCount: examCategories.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedexamCategoriesIndex = index;
                            });
                          },
                          child: Container(
                            width: 53,
                            height: 34,
                            padding: EdgeInsets.fromLTRB(4, 4, 4, 8),
                            // margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: selectedexamCategoriesIndex == index
                                  ? Colors.blueAccent
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.attBorderColor1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              examCategories[index],
                              style: AppTextStyles.normal500(
                                color: selectedexamCategoriesIndex == index
                                    ? AppColors.assessmentColor1
                                    : AppColors.attCheckColor1,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 11.0)),
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
                      // Navigator.push(context, MaterialPageRoute(builder: (context) =>()));
                    },
                    style: TextButton.styleFrom(),
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
