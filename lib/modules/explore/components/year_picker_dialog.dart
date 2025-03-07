import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/e_library/cbt.details.dart';
// import 'package:linkschool/modules/common/app_colors.dart';

class YearPickerDialog {
  static void show(
    BuildContext context, {
    required String title,
    // required String subtitle,
    required int startYear,
    required int numberOfYears,
    required String subject,
    required String subjectIcon,
    required Color cardColor,
    required List<String> subjectList,
  }) {
    final List<int> years = List.generate(
      numberOfYears,
      (index) => startYear - index,
    );

    BottomPicker(
      items: years
          .map((year) => Center(
                child: Text(
                  year.toString(),
                  style: AppTextStyles.normal700(
                    fontSize: 32,
                    color: Colors.black,
                  ),
                ),
              ))
          .toList(),
      pickerTitle: Padding(
        padding: const EdgeInsets.only(top: 16.0,),
        child: Column(
          children: [
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      titleAlignment: Alignment.center,
      height: 335,
      pickerTextStyle: AppTextStyles.normal700(
        fontSize: 32,
        color: Colors.black,
      ),
      onChange: (index) {
        // Optional: Handle onChange if needed
      },
      onSubmit: (index) {
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 10), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CbtDetailScreen(
                year: years[index],
                subject: subject,
                subjectIcon: subjectIcon,
                cardColor: cardColor,
                subjectList: subjectList,
              ),
            ),
          );
        });
      },
      bottomPickerTheme: BottomPickerTheme.plumPlate,
    ).show(context);
  }
}