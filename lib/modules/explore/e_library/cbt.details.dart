import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/cbt/cbt_dashboard.dart';
import 'package:linkschool/modules/explore/components/year_picker_dialog.dart';
import 'package:linkschool/modules/explore/e_library/test_screen.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
import 'package:provider/provider.dart';

class CbtDetailScreen extends StatefulWidget {
  final int year;
  final String examId; // Add examId parameter
  final String subject;
  final String subjectIcon;
  final Color cardColor;
  final List<String> subjectList;
  final String? subjectId;
  final bool fromELibrary;

  const CbtDetailScreen({
    super.key,
    required this.year,
    required this.examId, // Required parameter
    required this.subject,
    required this.subjectIcon,
    required this.cardColor,
    required this.subjectList,
    this.subjectId,
    this.fromELibrary = false,
  });

  @override
  State<CbtDetailScreen> createState() => _CbtDetailScreenState();
}

class _CbtDetailScreenState extends State<CbtDetailScreen> {
  late String selectedSubject;
  late int selectedYear;
  late String selectedExamId;

  @override
  void initState() {
    super.initState();
    selectedSubject = widget.subject;
    selectedYear = widget.year;
    selectedExamId = widget.examId; // Initialize examId
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _updateYear(int newYear, String newExamId) {
    setState(() {
      selectedYear = newYear;
      selectedExamId = newExamId;
    });
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
                        // Reset to first available year for new subject
                        final yearModels = provider.getYearModelsForSubject(subject);
                        if (yearModels.isNotEmpty) {
                          selectedYear = int.parse(yearModels.first.year);
                          selectedExamId = yearModels.first.id;
                        }
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

  void _showYearPicker(BuildContext context) {
    final provider = Provider.of<CBTProvider>(context, listen: false);
    final yearModels = provider.getYearModelsForSubject(selectedSubject);

    if (yearModels.isNotEmpty) {
      final subjectModel = provider.currentBoardSubjects.firstWhere(
        (s) => s.name == selectedSubject,
        orElse: () => provider.currentBoardSubjects.first,
      );

      YearPickerDialog.show(
        context,
        title: 'Choose Year',
        yearModels: yearModels,
        subject: selectedSubject,
        subjectIcon: provider.getSubjectIcon(selectedSubject),
        cardColor: provider.getSubjectColor(selectedSubject),
        subjectList: widget.subjectList,
        subjectId: subjectModel.id,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No years available for this subject'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _getDurationForSubject(String subject) {
    final provider = Provider.of<CBTProvider>(context, listen: false);
    final boardCode = provider.selectedBoard?.boardCode ?? '';
    
    switch (boardCode) {
      case 'JAMB':
        return '2hrs 30mins';
      case 'WAEC':
      case 'NECO':
        return '3hrs';
      case 'BECE':
        return '2hrs';
      default:
        return '2hrs 30mins';
    }
  }

  String _getInstructionsForSubject(String subject) {
    final provider = Provider.of<CBTProvider>(context, listen: false);
    final boardCode = provider.selectedBoard?.boardCode ?? '';
    
    switch (boardCode) {
      case 'JAMB':
        return 'Answer all 60 questions';
      case 'WAEC':
      case 'NECO':
        return 'Answer all questions';
      case 'BECE':
        return 'Answer all questions in Section A and B';
      default:
        return 'Answer all questions';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CBTProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            elevation: 0.0,
            title: Text(
              provider.selectedBoard?.boardCode ?? 'CBT',
              style: AppTextStyles.normal600(
                fontSize: 18.0,
                color: AppColors.primaryLight,
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: Image.asset(
                        'assets/images/background.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Image.asset(
                'assets/icons/arrow_back.png',
                color: AppColors.primaryLight,
                width: 34.0,
                height: 34.0,
              ),
            ),
          ),
          body: Container(
            decoration: Constants.customBoxDecoration(context),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Subject || Selection Row
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showSubjectList(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              subjects(
                                subjectName: selectedSubject,
                                subjectIcon: provider.getSubjectIcon(selectedSubject),
                                subjectColor: provider.getSubjectColor(selectedSubject),
                              ),
                              const Icon(Icons.arrow_drop_down_circle_outlined)
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    // Year Selection Row
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showYearPicker(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
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
                                    selectedYear.toString(),
                                    style: AppTextStyles.normal500(
                                      fontSize: 16,
                                      color: AppColors.text3Light,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_drop_down_circle_outlined),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          Text(
                            'Duration :',
                            style: AppTextStyles.normal500(
                                fontSize: 16, color: AppColors.libtitle),
                          ),
                          Text(
                            _getDurationForSubject(selectedSubject),
                            style: AppTextStyles.normal500(
                                fontSize: 16, color: AppColors.text3Light)
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          Text('Instructions :',
                              style: AppTextStyles.normal500(
                                  fontSize: 16, color: AppColors.libtitle)),
                          Expanded(
                            child: Text(
                              _getInstructionsForSubject(selectedSubject),
                              style: AppTextStyles.normal500(
                                  fontSize: 16, color: AppColors.text3Light)
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CustomLongElevatedButton(
                        text: 'Start Exam',
                        onPressed: () {
                          print("🚀 Starting exam with:");
                          print("  - Exam ID: $selectedExamId");
                          print("  - Subject: $selectedSubject");
                          print("  - Year: $selectedYear");
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TestScreen(
                                examTypeId: selectedExamId, // Pass the exam_id
                                subjectId: widget.subjectId ?? '',
                                subject: selectedSubject,
                                year: selectedYear,
                                calledFrom: 'details', // Indicate it's called from details screen
                              )
                            )
                          );
                        },
                        backgroundColor: AppColors.bookText1,
                        textStyle: AppTextStyles.normal500(
                            fontSize: 18.0, color: AppColors.bookText2),
                      ),
                    )
                  ],
                ),
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






// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/explore/cbt/cbt_dashboard.dart';
// import 'package:linkschool/modules/explore/components/year_picker_dialog.dart';
// import 'package:linkschool/modules/explore/e_library/test_screen.dart';
// import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
// import 'package:provider/provider.dart';

// class CbtDetailScreen extends StatefulWidget {
//   final int year;
//   final String subject;
//   final String subjectIcon;
//   final Color cardColor;
//   final List<String> subjectList;
//   //final String examTypeId;
//   final String? subjectId;
//   final bool fromELibrary;
//    //final String examId;
//   //  final String?  examId;
//   const CbtDetailScreen({
//     super.key,
//     required this.year,
//     required this.subject,
//     required this.subjectIcon,
//     required this.cardColor,
//     required this.subjectList,
//    // required this.examTypeId,
//     this.subjectId,
//     this.fromELibrary = false,
//     // this.examId = '',
//   });

//   @override
//   State<CbtDetailScreen> createState() => _CbtDetailScreenState();
// }

// class _CbtDetailScreenState extends State<CbtDetailScreen> {
//   late String selectedSubject;
//   late int selectedYear;

//   @override
//   void initState() {
//     super.initState();
//     selectedSubject = widget.subject;
//      selectedYear = widget.year; 
//   }


//     @override
//   void dispose() {
//     // Clean up any resources
//     super.dispose();
//   }

// void _updateYear(int newYear) {
//     setState(() {
//       selectedYear = newYear;
//     });
//   }



//   void _showSubjectList(BuildContext context) {
//     final provider = Provider.of<CBTProvider>(context, listen: false);
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (BuildContext context) {
//         return DraggableScrollableSheet(
//           initialChildSize: 0.4,
//           minChildSize: 0.2,
//           maxChildSize: 0.75,
//           expand: false,
//           builder: (context, scrollController) {
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ListView(
//                 controller: scrollController,
//                 children: widget.subjectList.map((subject) {
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedSubject = subject;
//                       });
//                       Navigator.pop(context);
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 10),
//                       child: subjects(
//                         subjectName: subject,
//                         subjectIcon: provider.getSubjectIcon(subject),
//                         subjectColor: provider.getSubjectColor(subject),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   void _showYearPicker(BuildContext context) {
//     final provider = Provider.of<CBTProvider>(context, listen: false);
//     final years = provider.getYearsForSubject(selectedSubject);

//     if (years.isNotEmpty) {
//       final yearsList = years
//           .map((y) => int.tryParse(y))
//           .whereType<int>()
//           .toList()
//         ..sort((a, b) => b.compareTo(a));

//       // Find the subject model to get the correct subject ID
//       final subjectModel = provider.currentBoardSubjects.firstWhere(
//         (s) => s.name == selectedSubject,
//         orElse: () => provider.currentBoardSubjects.first,
//       );

//       // YearPickerDialog.show(
//       //   context,
//       //   title: 'Choose Year',
//       //   examTypeId: widget.examId,
//       //   startYear: yearsList.first,
//       //   yearModels: provider.getYearModelsForSubject(selectedSubject),
//       //   numberOfYears: yearsList.length,
//       //   subject: selectedSubject,
//       //   subjectIcon: provider.getSubjectIcon(selectedSubject),
//       //   cardColor: provider.getSubjectColor(selectedSubject),
//       //   subjectList: widget.subjectList,
//       //   subjectId: subjectModel.id,
        
//       // );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No years available for this subject'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   String _getDurationForSubject(String subject) {
//     // Dynamic duration based on subject type
//     final provider = Provider.of<CBTProvider>(context, listen: false);
//     final boardCode = provider.selectedBoard?.boardCode ?? '';
    
//     switch (boardCode) {
//       case 'JAMB':
//         return '2hrs 30mins';
//       case 'WAEC':
//       case 'NECO':
//         return '3hrs';
//       case 'BECE':
//         return '2hrs';
//       default:
//         return '2hrs 30mins';
//     }
//   }

//   String _getInstructionsForSubject(String subject) {
//     // Dynamic instructions based on exam type
//     final provider = Provider.of<CBTProvider>(context, listen: false);
//     final boardCode = provider.selectedBoard?.boardCode ?? '';
    
//     switch (boardCode) {
//       case 'JAMB':
//         return 'Answer all 60 questions';
//       case 'WAEC':
//       case 'NECO':
//         return 'Answer all questions';
//       case 'BECE':
//         return 'Answer all questions in Section A and B';
//       default:
//         return 'Answer all questions';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
    
//     return Consumer<CBTProvider>(
//       builder: (context, provider, child) {
//         return Scaffold(
//           appBar: AppBar(
//             backgroundColor: Colors.white,
//             automaticallyImplyLeading: false,
//             elevation: 0.0,
//             title: Text(
//               provider.selectedBoard?.boardCode ?? 'CBT',
//               style: AppTextStyles.normal600(
//                 fontSize: 18.0,
//                 color: AppColors.primaryLight,
//               ),
//             ),
//             centerTitle: true,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Stack(
//                 children: [
//                   Positioned.fill(
//                     child: Opacity(
//                       opacity: 0.1,
//                       child: Image.asset(
//                         'assets/images/background.png',
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             leading: IconButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               icon: Image.asset(
//                 'assets/icons/arrow_back.png',
//                 color: AppColors.primaryLight,
//                 width: 34.0,
//                 height: 34.0,
//               ),
//             ),
//           ),
//           body: Container(
//             decoration: Constants.customBoxDecoration(context),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   // Subject Selection Row
//                   Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       onTap: () => _showSubjectList(context),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             subjects(
//                               subjectName: selectedSubject,
//                               subjectIcon:
//                                   provider.getSubjectIcon(selectedSubject),
//                               subjectColor:
//                                   provider.getSubjectColor(selectedSubject),
//                             ),
//                             const Icon(Icons.arrow_drop_down_circle_outlined)
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const Divider(),
//                   // Year Selection Row
//                   Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       onTap: () => _showYearPicker(context),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   'Year: ',
//                                   style: AppTextStyles.normal500(
//                                     fontSize: 16,
//                                     color: AppColors.libtitle,
//                                   ),
//                                 ),
//                                 Text(
//                                   widget.year.toString(),
//                                   style: AppTextStyles.normal500(
//                                     fontSize: 16,
//                                     color: AppColors.text3Light,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const Icon(Icons.arrow_drop_down_circle_outlined),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const Divider(),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 16.0),
//                     child: Row(
//                       children: [
//                         Text(
//                           'Duration :',
//                           style: AppTextStyles.normal500(
//                               fontSize: 16, color: AppColors.libtitle),
//                         ),
//                         Text(
//                           _getDurationForSubject(selectedSubject),
//                           style: AppTextStyles.normal500(
//                               fontSize: 16, color: AppColors.text3Light)
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Divider(),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 16.0),
//                     child: Row(
//                       children: [
//                         Text('Instructions :',
//                             style: AppTextStyles.normal500(
//                                 fontSize: 16, color: AppColors.libtitle)),
//                         Expanded(
//                           child: Text(
//                             _getInstructionsForSubject(selectedSubject),
//                             style: AppTextStyles.normal500(
//                                 fontSize: 16, color: AppColors.text3Light)
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Divider(),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: CustomLongElevatedButton(
//                       text: 'Start Exam',
//                       onPressed: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => TestScreen(
//                                    // examTypeId: widget.examTypeId,
//                                    examTypeId: '6',
//                                     subjectId: widget.subjectId ?? '',
//                                     subject: selectedSubject,
//                                     year: widget.year,
//                                   ))),
//                       backgroundColor: AppColors.bookText1,
//                       textStyle: AppTextStyles.normal500(
//                           fontSize: 18.0, color: AppColors.bookText2),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class subjects extends StatelessWidget {
//   final String? subjectName;
//   final String? subjectIcon;
//   final Color? subjectColor;
//   const subjects({
//     super.key,
//     required this.subjectName,
//     required this.subjectIcon,
//     required this.subjectColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 45,
//           height: 45,
//           decoration: BoxDecoration(
//             color: subjectColor,
//             borderRadius: BorderRadius.circular(4.0),
//           ),
//           child: Center(
//             child: Image.asset(
//               'assets/icons/$subjectIcon.png',
//               width: 24.0,
//               height: 24.0,
//             ),
//           ),
//         ),
//         const SizedBox(width: 10.0),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               subjectName!,
//               style: AppTextStyles.normal500(
//                 fontSize: 18.0,
//                 color: AppColors.cbtText,
//               ),
//             ),
//             const SizedBox(height: 8.0),
//           ],
//         ),
//       ],
//     );
//   }
// }
