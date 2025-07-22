import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/providers/admin/student_provider.dart';

class SingleTermResult extends StatefulWidget {
  final int studentId;
  final int termId;
  final String classId;
  final String year;
  final String levelId;
  final String termName;

  const SingleTermResult({
    super.key,
    required this.studentId,
    required this.termId,
    required this.classId,
    required this.year,
    required this.levelId,
    required this.termName,
  });

  @override
  State<SingleTermResult> createState() => _SingleTermResultState();
}

class _SingleTermResultState extends State<SingleTermResult> {
  late double opacity;

  @override
  void initState() {
    super.initState();
    // Fetch term results when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      studentProvider.fetchStudentTermResults(
        studentId: widget.studentId,
        termId: widget.termId,
        classId: widget.classId,
        year: widget.year,
        levelId: widget.levelId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.termName,
          style: AppTextStyles.normal600(
              fontSize: 18.0, color: AppColors.eLearningBtnColor1),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.eLearningBtnColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              // Implement download functionality
            },
            icon: const Icon(Icons.download, color: AppColors.eLearningBtnColor1),
            label: const Text(
              'Download',
              style: TextStyle(color: AppColors.eLearningBtnColor1),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Consumer<StudentProvider>(
          builder: (context, studentProvider, child) {
            if (studentProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (studentProvider.errorMessage.isNotEmpty) {
              return Center(
                child: Text(
                  'Error: ${studentProvider.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final termResult = studentProvider.studentTermResult;

            if (termResult == null) {
              return const Center(child: Text('No term results available'));
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildAverageSection(),
                  _buildTermSection(widget.termName, termResult),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAverageSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Annual average',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryDark,
            ),
          ),
          Text(
            '86.80%', // Keeping dummy data as per requirement
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermSection(String title, Map<String, dynamic> termResult) {
    final average = termResult['average']?.toString() ?? 'N/A';
    final position = termResult['position']?.toString() ?? 'N/A';
    final totalStudents = termResult['total_students']?.toString() ?? 'N/A';
    final subjects = termResult['subjects'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.orange, width: 2),
              bottom: BorderSide(color: Colors.orange, width: 2),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildInfoRow('Student average', '$average%'),
              const Divider(),
              _buildInfoRow('Class position', '$position of $totalStudents'),
              const SizedBox(height: 16),
              _buildSubjectsTable(subjects),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsTable(List<dynamic> subjects) {
    // Extract unique assessment names dynamically
    final assessmentNames = subjects.isNotEmpty
        ? (subjects.first['assessments'] as List<dynamic>)
            .map((assessment) => assessment['assessment_name'] as String)
            .toList()
        : [];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildSubjectColumn(subjects),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Dynamic assessment columns
                  ...assessmentNames.map((assessmentName) =>
                      _buildScrollableColumn(
                          assessmentName, 80, subjects, assessmentName)),
                  _buildScrollableColumn('Total Score', 100, subjects, null),
                  _buildScrollableColumn('Grade', 80, subjects, null),
                  _buildScrollableColumn('Remarks', 100, subjects, null),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectColumn(List<dynamic> subjects) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            alignment: Alignment.center,
            child: const Text(
              'Subject',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...subjects.asMap().entries.map((entry) {
            final index = entry.key;
            final subject = entry.value;
            return Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: index % 2 == 0 ? Colors.white : Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  subject['course_name'] ?? 'Unknown',
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScrollableColumn(
      String title, double width, List<dynamic> subjects, String? assessmentName) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.eLearningBtnColor1,
              border: Border(
                left: const BorderSide(color: Colors.white),
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ...subjects.asMap().entries.map((entry) {
            final index = entry.key;
            final subject = entry.value;
            return Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: index % 2 == 0 ? Colors.white : Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Text(
                _getDataForColumn(title, subject, assessmentName),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryDark,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getDataForColumn(String columnName, Map<String, dynamic> subject, String? assessmentName) {
    if (assessmentName != null) {
      final assessments = subject['assessments'] as List<dynamic>? ?? [];
      final assessment = assessments.firstWhere(
        (a) => a['assessment_name'] == assessmentName,
        orElse: () => {'score': 'N/A'},
      );
      return assessment['score'].toString();
    }
    switch (columnName) {
      case 'Total Score':
        return subject['total']?.toString() ?? 'N/A';
      case 'Grade':
        return subject['grade']?.toString() ?? 'N/A';
      case 'Remarks':
        return subject['remark']?.toString() ?? 'N/A';
      default:
        return 'N/A';
    }
  }
}


// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';

// class SingleTermResult extends StatefulWidget {

//   const SingleTermResult({super.key, });

//   @override
//   State<SingleTermResult> createState() =>
//       _SingleTermResultState();
// }

// class _SingleTermResultState extends State<SingleTermResult> {
//   late double opacity;

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Annual result',
//           style: AppTextStyles.normal600(fontSize: 18.0, color: AppColors.eLearningBtnColor1,)
//         ),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.eLearningBtnColor1,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         backgroundColor: AppColors.backgroundLight,
//         flexibleSpace: FlexibleSpaceBar(
//           background: Stack(
//             children: [
//               Positioned.fill(
//                 child: Opacity(
//                   opacity: opacity,
//                   child: Image.asset(
//                     'assets/images/background.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//         actions: [
//           TextButton.icon(
//             onPressed: () {
//               // Implement download functionality
//             },
//             icon:
//                 const Icon(Icons.download, color: AppColors.eLearningBtnColor1),
//             label: const Text(
//               'Download',
//               style: TextStyle(color: AppColors.eLearningBtnColor1),
//             ),
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: Constants.customBoxDecoration(context),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               _buildAverageSection(),
//               _buildTermSection('First Term Result'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAverageSection() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text(
//             'Annual average',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color:AppColors.primaryDark
//             ),
//           ),
//           Text(
//             '86.80%',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.blue[700],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTermSection(String title) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(16.0),
//           decoration: const BoxDecoration(
//             border: Border(
//               top: BorderSide(color: Colors.orange, width: 2),
//               bottom: BorderSide(color: Colors.orange, width: 2),
//             ),
//           ),
//           child: Text(
//             title,
//             style: const TextStyle(
//               fontSize: 16,
//               color:AppColors.primaryDark,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               _buildInfoRow('Student average', '76.80%'),
//               const Divider(),
//               _buildInfoRow('Class position', '4th of 22'),
//               const SizedBox(height: 16),
//               _buildSubjectsTable(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,

//             style: const TextStyle(
//               color:AppColors.primaryDark,
//               fontSize: 14),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.blue[700],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSubjectsTable() {
//     final List<String> subjects = [
//       'English Language',
//       'Mathematics',
//       'Physics',
//       'Chemistry',
//       'Biology',
//       'Geography',
//       'Economics',
//       'Literature',
//       'History',
//     ];

//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           _buildSubjectColumn(subjects),
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   _buildScrollableColumn('Assessment 1', 80, subjects),
//                   _buildScrollableColumn('Assessment 2', 80, subjects),
//                   _buildScrollableColumn('Assessment 3', 80, subjects),
//                   _buildScrollableColumn('Examination', 100, subjects),
//                   _buildScrollableColumn('Total Score', 100, subjects),
//                   _buildScrollableColumn('Grade', 80, subjects),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSubjectColumn(List<String> subjects) {
//     return Container(
//       width: 120,
//       decoration: BoxDecoration(
//         color: Colors.blue[700],
//         borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             height: 48,
//             alignment: Alignment.center,
//             child: const Text(
//               'Subject',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           ...subjects.asMap().entries.map((entry) {
//             final index = entry.key;
//             final subject = entry.value;
//             return Container(
//               height: 50,
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               decoration: BoxDecoration(
//                 color: index % 2 == 0 ? Colors.white : Colors.grey[100],
//                 border: Border(
//                   top: BorderSide(color: Colors.grey[300]!),
//                   right: BorderSide(color: Colors.grey[300]!),
//                 ),
//               ),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   subject,
//                   style: const TextStyle(
//                     color:AppColors.primaryDark,
//                     fontSize: 14),
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _buildScrollableColumn(
//       String title, double width, List<String> subjects) {
//     return Container(
//       width: width,
//       decoration: BoxDecoration(
//         border: Border(left: BorderSide(color: Colors.grey[300]!)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             height: 48,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: AppColors.eLearningBtnColor1,
//               border: Border(
//                 left: const BorderSide(color: Colors.white),
//                 bottom: BorderSide(color: Colors.grey[300]!),
//               ),
//             ),
//             child: Text(
//               title,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           ...subjects.asMap().entries.map((entry) {
//             final index = entry.key;
//             return Container(
//               height: 50,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: index % 2 == 0 ? Colors.white : Colors.grey[100],
//                 border: Border(
//                   top: BorderSide(color: Colors.grey[300]!),
//                   right: BorderSide(color: Colors.grey[300]!),
//                 ),
//               ),
//               child: Text(
//                 _getDataForColumn(title, index),
//                 style: const TextStyle(fontSize: 14,
//                    color:AppColors.primaryDark,
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   String _getDataForColumn(String columnName, int index) {
//     switch (columnName) {
//       case 'Assessment 1':
//         return '${10 + index}';
//       case 'Assessment 2':
//       case 'Assessment 3':
//         return '${15 + index}';
//       case 'Examination':
//         return '${60 + index}';
//       case 'Total Score':
//         return '${85 + index}';
//       case 'Grade':
//         return ['A', 'B', 'A', 'C', 'B', 'A', 'B', 'A', 'B'][index];
//       default:
//         return '';
//     }
//   }
// }
