import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/e_library/cbt.details.dart';

class YearPickerDialog {
  static void show(
    BuildContext context, {
    required String title,
    required String subtitle,
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
      pickerTitle: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              subtitle,
              style: AppTextStyles.normal600(
                fontSize: 14.0,
                color: AppColors.cbtDialogText,
              ),
            ),
          ),
        ],
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


// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';

// class YearPickerDialog extends StatefulWidget {
//   final String title;
//   final String subtitle;
//   final int startYear;
//   final int numberOfYears;
//   final Function(int) onYearSelected;
//   final String confirmButtonText;
//   final String cancelButtonText;

//   const YearPickerDialog({
//     Key? key,
//     this.title = 'Choose a year',
//     this.subtitle = 'Select a year to practice questions',
//     this.startYear = 2024,
//     this.numberOfYears = 10,
//     required this.onYearSelected,
//     this.confirmButtonText = 'Confirm',
//     this.cancelButtonText = 'Cancel',
//   }) : super(key: key);

//   static Future<void> show(
//     BuildContext context, {
//     required Function(int) onYearSelected,
//     String title = 'Choose a year',
//     String subtitle = 'Select a year to practice questions',
//     int startYear = 2024,
//     int numberOfYears = 10,
//     String confirmButtonText = 'Confirm',
//     String cancelButtonText = 'Cancel',
//   }) {
//     return showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) => YearPickerDialog(
//         title: title,
//         subtitle: subtitle,
//         startYear: startYear,
//         numberOfYears: numberOfYears,
//         onYearSelected: onYearSelected,
//         confirmButtonText: confirmButtonText,
//         cancelButtonText: cancelButtonText,
//       ),
//     );
//   }

//   @override
//   _YearPickerDialogState createState() => _YearPickerDialogState();
// }

// class _YearPickerDialogState extends State<YearPickerDialog> {
//   late final List<int> years;
//   int? selectedYear;

//   @override
//   void initState() {
//     super.initState();
//     years = List.generate(
//       widget.numberOfYears,
//       (index) => widget.startYear - index,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 335,
//       width: 360,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             widget.title,
//             style: AppTextStyles.normal600(
//               fontSize: 26.0,
//               color: AppColors.cbtDialogTitle,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               widget.subtitle,
//               style: AppTextStyles.normal600(
//                 fontSize: 14.0,
//                 color: AppColors.cbtDialogText,
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: years.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(
//                     years[index].toString(),
//                     textAlign: TextAlign.center,
//                     style: AppTextStyles.normal600(
//                       fontSize: selectedYear == years[index] ? 24.0 : 16.0,
//                       color: selectedYear == years[index]
//                           ? AppColors.cbtDialogTitle
//                           : AppColors.booksButtonTextColor,
//                     ),
//                   ),
//                   onTap: () {
//                     setState(() {
//                       selectedYear = years[index];
//                     });
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 MaterialButton(
//                   height: 40,
//                   minWidth: 156,
//                   onPressed: () => Navigator.pop(context),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                     side: BorderSide(
//                       color: AppColors.cbtDialogBorder,
//                       width: 1.0,
//                     ),
//                   ),
//                   child: Text(
//                     widget.cancelButtonText,
//                     style: AppTextStyles.normal600(
//                       fontSize: 16.0,
//                       color: AppColors.cbtDialogBorder,
//                     ),
//                   ),
//                 ),
//                 MaterialButton(
//                   height: 40,
//                   minWidth: 156,
//                   color: AppColors.cbtDialogButton,
//                   onPressed: () {
//                     if (selectedYear != null) {
//                       Navigator.pop(context);
//                       widget.onYearSelected(selectedYear!);
//                     }
//                   },
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   child: Text(
//                     widget.confirmButtonText,
//                     style: AppTextStyles.normal600(
//                       fontSize: 16.0,
//                       color: AppColors.textFieldLight,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }