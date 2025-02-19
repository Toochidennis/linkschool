import 'package:flutter/material.dart';

import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/e_library/test_screen.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
import 'package:provider/provider.dart';

class CbtDetailScreen extends StatefulWidget {
  final int year;
  final String subject;
  final String subjectIcon;
  final Color cardColor;
  final List<String> subjectList;

  const CbtDetailScreen({
    super.key,
    required this.year,
    required this.subject,
    required this.subjectIcon,
    required this.cardColor,
    required this.subjectList,
  });

  @override
  State<CbtDetailScreen> createState() => _CbtDetailScreenState();
}

class _CbtDetailScreenState extends State<CbtDetailScreen> {
  // String? selectedYear;
  // Widget? selectedSubject;
  late String selectedSubject;

  @override
  void initState() {
    super.initState();
    selectedSubject = widget.subject;
  }

  void _showSubjectList(BuildContext context) {
    final provider = Provider.of<CBTProvider>(context, listen: false);
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
                children: widget.subjectList.map((subject) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSubject = subject;
                      });
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: subjects(
                        subjectName: subject,
                        subjectIcon: provider.getSubjectIcon(subject),
                        subjectColor: provider.getSubjectColor(subject),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CBTProvider>(
      builder: (context, provider, child) {
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
                      subjects(
                        subjectName: selectedSubject,
                        subjectIcon: provider.getSubjectIcon(selectedSubject),
                        subjectColor: provider.getSubjectColor(selectedSubject),
                      ),
                      GestureDetector(
                        onTap: () => _showSubjectList(context),
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
                            'Year: ',
                            style: AppTextStyles.normal500(
                              fontSize: 16,
                              color: AppColors.libtitle,
                            ),
                          ),
                          Text(
                            widget.year.toString(),
                            style: AppTextStyles.normal500(
                              fontSize: 16,
                              color: AppColors.text3Light,
                            ),
                          ),
                        ],
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
      },
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
