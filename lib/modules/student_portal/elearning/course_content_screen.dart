import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CourseContentScreen extends StatefulWidget {
  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen> {
  late double opacity;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // padding: const EdgeInsets.all(16.0),
      child: Container(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                alignment: Alignment.center,
                color: AppColors.paymentTxtColor1,
                child: const Text(
                  'Agricultural Science',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              const ContentRow(
                iconPath: 'assets/icons/student/quiz_icon.svg',
                title: 'Quiz: Human Rights',
                subtitle: 'Created on 25 June, 2015 08:52am',
                titleColor: AppColors.paymentTxtColor1,
              ),
              const ContentRow(
                iconPath: 'assets/icons/student/assignment_icon.svg',
                title: 'Assignment: Honesty',
                subtitle: 'Created on 25 June, 2015 08:52am',
                titleColor: AppColors.paymentTxtColor1,
              ),
              const SizedBox(height: 24),
              
              // Section 2: Punctuality
              const Text(
                'Punctuality',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color:  AppColors.paymentTxtColor1,),
              ),
              Divider(color: Colors.grey.shade400),
              const ContentRow(
                iconPath: 'assets/icons/student/note_icon.svg',
                title: 'What is Punctuality?',
                subtitle: 'Created on 25 June, 2015 08:52am',
              ),
              const ContentRow(
                iconPath: 'assets/icons/student/quiz_icon.svg',
                title: 'First C.A',
                subtitle: 'Created on 25 June, 2015 08:52am',
              ),
              const ContentRow(
                iconPath: 'assets/icons/student/assignment_icon.svg',
                title: 'Assignment',
                subtitle: 'Created on 25 June, 2015 08:52am',
              ),
              const ContentRow(
                iconPath: 'assets/icons/student/quiz_icon.svg',
                title: 'Second C.A',
                subtitle: 'Created on 25 June, 2015 08:52am',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContentRow extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final Color titleColor;

  const ContentRow({
    Key? key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    this.titleColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SvgPicture.asset(iconPath, height: 32, width: 32), // Replace with actual SVG path
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: title.split(':')[0] + ': ',
                        style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: title.split(':').length > 1 ? title.split(':')[1].trim() : '',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}