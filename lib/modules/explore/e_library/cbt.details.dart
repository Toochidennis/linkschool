import 'package:flutter/material.dart';

import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/e_library/test_screen.dart';

class CbtDetailScreen extends StatefulWidget {
  final int year;
  final String subject;
  final String subjectIcon;
  final Color cardColor;

  const CbtDetailScreen({
    super.key,
    required this.year,
    required this.subject,
    required this.subjectIcon,
    required this.cardColor,
  });

  @override
  State<CbtDetailScreen> createState() => _CbtDetailScreenState();
}

class _CbtDetailScreenState extends State<CbtDetailScreen> {
  String? selectedYear;
  Widget? selectedSubject;

  final List<Widget> subjectList = [
    subjects(
        subjectName: 'Mathematics',
        subjectIcon: 'maths',
        subjectColor: AppColors.cbtCardColor1),
    subjects(
        subjectName: 'English Language',
        subjectIcon: 'english',
        subjectColor: AppColors.cbtCardColor2),
    subjects(
        subjectName: 'Chemistry',
        subjectIcon: 'chemistry',
        subjectColor: AppColors.cbtCardColor3),
    subjects(
        subjectName: 'Physics',
        subjectIcon: 'physics',
        subjectColor: AppColors.cbtCardColor4),
    subjects(
        subjectName: 'Biology',
        subjectIcon: 'biology',
        subjectColor: AppColors.cbtCardColor5),
  ];

  final List<int> years = [
    2023,
    2022,
    2021,
    2020,
    2019,
    2018,
    2017,
    2016,
    2015,
    2014,
  ];

  void _examList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.75,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                controller: scrollController,
                children: List.generate(
                    5,
                    (index) => GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              selectedSubject = subjectList[index];
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: subjectList[index],
                          ),
                        )),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Constants.customAppBar(
          context: context, title: 'WAEC/SSCE', centerTitle: true),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  selectedSubject ?? subjectList[0], // Handle null case
                  GestureDetector(
                    onTap: () => _examList(context),
                    child: Icon(Icons.arrow_drop_down_circle_outlined),
                  )
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Year :',
                        style: AppTextStyles.normal500(
                            fontSize: 16, color: AppColors.libtitle),
                      ),
                      Text(widget.year.toString(),
                          style: AppTextStyles.normal500(
                              fontSize: 16, color: AppColors.text3Light)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: DropdownButton<String>(
                      items: years.map((int year) {
                        return DropdownMenuItem<String>(
                          value: year.toString(),
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedYear = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    Text(
                      'Duration :',
                      style: AppTextStyles.normal500(
                          fontSize: 16, color: AppColors.libtitle),
                    ),
                    Text('2hrs 30 minutes',
                        style: AppTextStyles.normal500(
                            fontSize: 16, color: AppColors.text3Light)),
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    Text('Instructions :',
                        style: AppTextStyles.normal500(
                            fontSize: 16, color: AppColors.libtitle)),
                    Text('Answer all questions',
                        style: AppTextStyles.normal500(
                            fontSize: 16, color: AppColors.text3Light)),
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CustomLongElevatedButton(
                  text: 'Start Exam',
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TestScreen())),
                  backgroundColor: AppColors.bookText1,
                  textStyle: AppTextStyles.normal500(
                      fontSize: 18.0, color: AppColors.bookText2),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class subjects extends StatelessWidget {
  final String? subjectName;
  final String? subjectIcon;
  final Color? subjectColor;
  const subjects({
    super.key,
    required this.subjectName,
    required this.subjectIcon,
    required this.subjectColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: subjectColor,
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subjectName!,
              style: AppTextStyles.normal500(
                fontSize: 18.0,
                color: AppColors.cbtText,
              ),
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ],
    );
  }
}
