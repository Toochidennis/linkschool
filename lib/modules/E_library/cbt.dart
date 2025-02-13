import 'package:flutter/material.dart';
import 'package:linkschool/modules/E_library/cbt.details.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button_2.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/e_library/newcbt.dart';

import 'package:linkschool/modules/explore/ebooks/subject_item.dart';

class E_CBTDashboard extends StatefulWidget {
  const E_CBTDashboard({super.key});

  @override
  State<E_CBTDashboard> createState() => _E_CBTDashboardState();
}

class _E_CBTDashboardState extends State<E_CBTDashboard> {
  int selectedCategoryIndex = 0;

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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                    color: AppColors.textFieldLight,
                    height: 50,
                    width: double.infinity,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      scrollDirection: Axis.horizontal,
                      itemCount: examCategories.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                          child: GestureDetector(
                            onTap: () {
                              _yearDialog(context);
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
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: .0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: metrics,
                ),
              ),
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const newCbtScreen()));
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text(
                      'old user',
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

void _yearDialog(BuildContext context) {
  final List<int> years = List.generate(10, (index) => 2024 - index);
  int? selectedYear;

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) => StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => Container(
        height: 335,
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Choose a year',
              style: AppTextStyles.normal600(
                fontSize: 26.0,
                color: AppColors.cbtDialogTitle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Select a year to practice questions',
                style: AppTextStyles.normal600(
                  fontSize: 14.0,
                  color: AppColors.cbtDialogText,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: years.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      years[index].toString(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.normal600(
                        fontSize: selectedYear == years[index] ? 24.0 : 16.0,
                        color: selectedYear == years[index]
                            ? AppColors.cbtDialogTitle
                            : AppColors.booksButtonTextColor,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedYear = years[index];
                      });
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    height: 40,
                    minWidth: 156,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.normal600(
                          fontSize: 16.0, color: AppColors.cbtDialogBorder),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      
                      side: BorderSide(color: AppColors.cbtDialogBorder,width: 1.0),
                    ),
                  ),
                  MaterialButton(
                    height: 40,
                    minWidth: 156,
                    color: AppColors.cbtDialogButton,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CbtDetailScreen()));
                    },
                    child: Text(
                      'Confirm',
                      style: AppTextStyles.normal600(
                          fontSize: 16.0, color: AppColors.textFieldLight),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
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
