import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';

class SubjectSelection extends StatelessWidget {
  const SubjectSelection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> allSubjects = [
      'Mathematics',
      'English',
      'Physics',
      'Chemistry',
      'Biology',
      'History',
      'Geography',
      'Literature',
      'Economics',
      'Government',
      'French',
      'Computer Science',
      'Fine Arts',
      'Music',
      'Physical Education'
    ];
    allSubjects.shuffle();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allSubjects.map((subject) {
        return ChoiceChip(
          label: Text(
            subject,
            style: TextStyle(
              color: AppColors.videoColor4,
              fontSize: 14,
            ),
          ),
          selected: false,
          onSelected: (_) {},
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.videoColor4),
          ),
        );
      }).toList(),
    );
  }
}
