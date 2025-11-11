import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/e_library/cbt.details.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';

class YearPickerDialog {
  static void show(
    BuildContext context, {
    required String title,
    required int startYear,
    required int numberOfYears,
    required String subject,
    required List<YearModel> yearModels, // Changed from List<dynamic>?
    required String subjectIcon,
    required Color cardColor,
    required List<String> subjectList,
    required String examTypeId,
    String? subjectId,
    Function(int)? onYearSelected,
  }) {
    // Sort yearModels in descending order by year
    final sortedYearModels = (yearModels ?? [])
      ..sort((a, b) => b.year.compareTo(a.year));

    BottomPicker(
      items: sortedYearModels
          .map((yearModel) => Center(
                child: Text(
                  yearModel.year,
                  style: AppTextStyles.normal700(
                    fontSize: 32,
                    color: Colors.black,
                  ),
                ),
              ))
          .toList(),
      pickerTitle: Padding(
        padding: const EdgeInsets.only(
          top: 16.0,
        ),
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
        final selectedYearModel = sortedYearModels[index];
        
        print("Selected year: ${selectedYearModel.year}");
        print("Exam ID: ${selectedYearModel.id}");
        print("Subject: $subject");
        print("ExamTypeId: $examTypeId");
        print("SubjectId: $subjectId");
        
        // Use a post frame callback to ensure the picker is fully dismissed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Navigator.of(context, rootNavigator: false).push(
              MaterialPageRoute(
                builder: (newContext) => CbtDetailScreen(
                  year: int.parse(selectedYearModel.year), // Convert year string to int
                  subject: subject,
                  subjectIcon: subjectIcon,
                  cardColor: cardColor,
                  subjectList: subjectList,
                  examTypeId: examTypeId,
                  subjectId: subjectId ?? '',
                  examId: selectedYearModel.id, // Pass the exam_id
                ),
              ),
            );
            
            FocusScope.of(context).unfocus();
          }
        });
      },
      bottomPickerTheme: BottomPickerTheme.plumPlate,
      
    ).show(context);
  }
}