import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/providers/admin/student_provider.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/admin/student_model.dart';

class StudentAnnualResultScreen extends StatefulWidget {
  final int studentId;
  final String classId;
  final String levelId;

  const StudentAnnualResultScreen({
    super.key,
    required this.studentId,
    required this.classId,
    required this.levelId,
  });

  @override
  State<StudentAnnualResultScreen> createState() =>
      _StudentAnnualResultScreenState();
}

class _StudentAnnualResultScreenState extends State<StudentAnnualResultScreen> {
  @override
  void initState() {
    super.initState();
    // Defer the API call to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAnnualResults();
    });
  }

  Future<void> _fetchAnnualResults() async {
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final year =
        loginData?['response']?['data']?['settings']?['year']?.toString() ??
            '2024';

    try {
      await studentProvider.fetchAnnualResults(
        studentId: widget.studentId,
        classId: widget.classId,
        levelId: widget.levelId,
        year: year,
      );
    } catch (e) {
      debugPrint('Failed to fetch annual results: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Compute opacity in build method to ensure Theme.of(context) is available
    final double opacity =
        Theme.of(context).brightness == Brightness.light ? 0.1 : 0.15;
    final studentProvider = Provider.of<StudentProvider>(context);
    final student = studentProvider.student;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Annual result',
          style: AppTextStyles.normal600(fontSize: 18.0, color: Colors.black),
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
              _downloadTermResults();
            },
            icon:
                const Icon(Icons.download, color: AppColors.eLearningBtnColor1),
            label: const Text(
              'Download',
              style: TextStyle(color: AppColors.eLearningBtnColor1),
            ),
          ),
        ],
      ),
      body: Consumer<StudentProvider>(
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

          final annualResults = studentProvider.annualResults;
          // Check if results are empty or contain no meaningful data
          if (annualResults == null ||
              annualResults.isEmpty ||
              _isEmptyResult(annualResults)) {
            return _buildNoResultsWidget(context);
          }

          // Calculate annual average, safely converting to double
          double annualAverage = annualResults
                  .map((term) => (term['average'] is int
                      ? (term['average'] as int).toDouble()
                      : term['average'] as double))
                  .reduce((a, b) => a + b) /
              annualResults.length;

          return Container(
            decoration: Constants.customBoxDecoration(context),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: Column(
                      children: [
                        _buildProfileImage(student),
                        const SizedBox(height: 10),
                        Text(
                          student?.name ?? 'Unknown Student',
                          style: AppTextStyles.normal700(
                            fontSize: 20,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildAverageSection(annualAverage),
                  ...annualResults.map((term) => _buildTermSection(term)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _downloadTermResults() async {
    final url =
        'https://linkskool.net/api/v1/students/${widget.studentId}/terms/${widget.classId}/results/download';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication, // Opens in browser
        );
      } else {
        // Show error if URL can't be launched
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching URL: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isEmptyResult(List<Map<String, dynamic>> results) {
    return results.every((term) =>
        (term['subjects'] as List).isEmpty &&
        term['average'] == 0 &&
        term['position'] == 0 &&
        term['total_students'] == 0);
  }

  Widget _buildNoResultsWidget(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[100]
              : Colors.grey[800],
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline,
              size: 48.0,
              color: AppColors.eLearningBtnColor1,
            ),
            const SizedBox(height: 16.0),
            Text(
              'No Results Available',
              style: AppTextStyles.normal700(
                fontSize: 20.0,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'No annual results found for this student. Please check back later or contact the administrator.',
              style: AppTextStyles.normal400(
                fontSize: 16.0,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            OutlinedButton(
              onPressed: _fetchAnnualResults,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.eLearningBtnColor1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(color: AppColors.eLearningBtnColor1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(Student? student) {
    if (student?.pictureUrl != null && student!.pictureUrl!.isNotEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(
              'https://linkskool.net/${student.pictureUrl}',
            ),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person,
          color: AppColors.backgroundLight,
          size: 40,
        ),
      );
    }
  }

  Widget _buildAverageSection(double average) {
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
              color: Colors.black,
            ),
          ),
          Text(
            '${average.toStringAsFixed(2)}%',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermSection(Map<String, dynamic> term) {
    final termName = term['term_name'] as String;
    final average = (term['average'] is int
        ? (term['average'] as int).toDouble()
        : term['average'] as double);
    final position = term['position'] as int;
    final totalStudents = term['total_students'] as int;
    final subjects = List<Map<String, dynamic>>.from(term['subjects'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.black, width: 2),
              bottom: BorderSide(color: Colors.black, width: 2),
            ),
          ),
          child: Text(
            termName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildInfoRow(
                  'Student average', '${average.toStringAsFixed(2)}%'),
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
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsTable(List<Map<String, dynamic>> subjects) {
    // Extract unique assessment names
    final assessmentNames = subjects
        .expand((subject) => subject['assessments'] as List)
        .map((assessment) => assessment['assessment_name'] as String)
        .toSet()
        .toList();

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
                  ...assessmentNames.map((assessment) => _buildScrollableColumn(
                      assessment, 80, subjects, assessment)),
                  _buildScrollableColumn('Total Score', 100, subjects, null),
                  _buildScrollableColumn('Grade', 80, subjects, null),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectColumn(List<Map<String, dynamic>> subjects) {
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
            final subject = entry.value['course_name'] as String;
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
                  subject,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScrollableColumn(String title, double width,
      List<Map<String, dynamic>> subjects, String? assessmentName) {
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
            final assessments =
                List<Map<String, dynamic>>.from(subject['assessments'] ?? []);
            String value = '';

            if (assessmentName != null) {
              final assessment = assessments.firstWhere(
                (a) => a['assessment_name'] == assessmentName,
                orElse: () => {'score': 0},
              );
              value = (assessment['score'] is int
                  ? (assessment['score'] as int).toDouble().toString()
                  : assessment['score'].toString());
            } else if (title == 'Total Score') {
              value = (subject['total'] is int
                  ? (subject['total'] as int).toDouble().toString()
                  : subject['total'].toString());
            } else if (title == 'Grade') {
              value = subject['grade'].toString();
            }

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
                value,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:provider/provider.dart';
// import 'package:linkschool/modules/providers/admin/student_provider.dart';
// import 'package:hive/hive.dart';
// import '../../model/admin/student_model.dart';

// class StudentAnnualResultScreen extends StatefulWidget {
//   final int studentId;
//   final String classId;
//   final String levelId;

//   const StudentAnnualResultScreen({
//     super.key,
//     required this.studentId,
//     required this.classId,
//     required this.levelId,
//   });

//   @override
//   State<StudentAnnualResultScreen> createState() =>
//       _StudentAnnualResultScreenState();
// }

// class _StudentAnnualResultScreenState extends State<StudentAnnualResultScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Defer the API call to avoid setState during build
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _fetchAnnualResults();
//     });
//   }

//   Future<void> _fetchAnnualResults() async {
//     final studentProvider = Provider.of<StudentProvider>(context, listen: false);
//     final userBox = Hive.box('userData');
//     final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
//     final year = loginData?['response']?['data']?['settings']?['year']?.toString() ?? '2024';

//     try {
//       await studentProvider.fetchAnnualResults(
//         studentId: widget.studentId,
//         classId: widget.classId,
//         levelId: widget.levelId,
//         year: year,
//       );
//     } catch (e) {
//       debugPrint('Failed to fetch annual results: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Compute opacity in build method to ensure Theme.of(context) is available
//     final double opacity = Theme.of(context).brightness == Brightness.light ? 0.1 : 0.15;
//     final studentProvider = Provider.of<StudentProvider>(context);
//     final student = studentProvider.student;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Annual result',
//           style: AppTextStyles.normal600(fontSize: 18.0, color: Colors.black),
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
//             icon: const Icon(Icons.download, color: AppColors.eLearningBtnColor1),
//             label: const Text(
//               'Download',
//               style: TextStyle(color: AppColors.eLearningBtnColor1),
//             ),
//           ),
//         ],
//       ),
//       body: Consumer<StudentProvider>(
//         builder: (context, studentProvider, child) {
//           if (studentProvider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (studentProvider.errorMessage.isNotEmpty) {
//             return Center(
//               child: Text(
//                 'Error: ${studentProvider.errorMessage}',
//                 style: const TextStyle(color: Colors.red),
//               ),
//             );
//           }

//           final annualResults = studentProvider.annualResults;
//           if (annualResults == null || annualResults.isEmpty) {
//             return const Center(child: Text('No annual results available'));
//           }

//           // Calculate annual average, safely converting to double
//           double annualAverage = annualResults
//               .map((term) => (term['average'] is int
//                   ? (term['average'] as int).toDouble()
//                   : term['average'] as double))
//               .reduce((a, b) => a + b) /
//               annualResults.length;

//           return Container(
//             decoration: Constants.customBoxDecoration(context),
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   const SizedBox(height: 30),
//                   Center(
//                     child: Column(
//                       children: [
//                         _buildProfileImage(student),
//                         const SizedBox(height: 10),
//                         Text(
//                           student?.name ?? 'Unknown Student',
//                           style: AppTextStyles.normal700(
//                             fontSize: 20,
//                             color: AppColors.primaryLight,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   _buildAverageSection(annualAverage),
//                   ...annualResults.map((term) => _buildTermSection(term)).toList(),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildProfileImage(Student? student) {
//     if (student?.pictureUrl != null && student!.pictureUrl!.isNotEmpty) {
//       return Container(
//         width: 60,
//         height: 60,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           image: DecorationImage(
//             image: NetworkImage(
//               'https://linkskool.net/${student.pictureUrl}',
//             ),
//             fit: BoxFit.cover,
//           ),
//         ),
//       );
//     } else {
//       return Container(
//         width: 60,
//         height: 60,
//         decoration: const BoxDecoration(
//           color: AppColors.primaryLight,
//           shape: BoxShape.circle,
//         ),
//         child: const Icon(
//           Icons.person,
//           color: AppColors.backgroundLight,
//           size: 40,
//         ),
//       );
//     }
//   }

//   Widget _buildAverageSection(double average) {
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
//               color: Colors.black,
//             ),
//           ),
//           Text(
//             '${average.toStringAsFixed(2)}%',
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTermSection(Map<String, dynamic> term) {
//     final termName = term['term_name'] as String;
//     final average = (term['average'] is int
//         ? (term['average'] as int).toDouble()
//         : term['average'] as double);
//     final position = term['position'] as int;
//     final totalStudents = term['total_students'] as int;
//     final subjects = List<Map<String, dynamic>>.from(term['subjects'] ?? []);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(16.0),
//           decoration: const BoxDecoration(
//             border: Border(
//               top: BorderSide(color: Colors.black, width: 2),
//               bottom: BorderSide(color: Colors.black, width: 2),
//             ),
//           ),
//           child: Text(
//             termName,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color: Colors.black,
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               _buildInfoRow('Student average', '${average.toStringAsFixed(2)}%'),
//               const Divider(),
//               _buildInfoRow('Class position', '$position of $totalStudents'),
//               const SizedBox(height: 16),
//               _buildSubjectsTable(subjects),
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
//             style: const TextStyle(fontSize: 14, color: Colors.black),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSubjectsTable(List<Map<String, dynamic>> subjects) {
//     // Extract unique assessment names
//     final assessmentNames = subjects
//         .expand((subject) => subject['assessments'] as List)
//         .map((assessment) => assessment['assessment_name'] as String)
//         .toSet()
//         .toList();

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
//                   ...assessmentNames
//                       .map((assessment) =>
//                           _buildScrollableColumn(assessment, 80, subjects, assessment))
//                       .toList(),
//                   _buildScrollableColumn('Total Score', 100, subjects, null),
//                   _buildScrollableColumn('Grade', 80, subjects, null),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSubjectColumn(List<Map<String, dynamic>> subjects) {
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
//             final subject = entry.value['course_name'] as String;
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
//                   style: const TextStyle(fontSize: 14, color: Colors.black),
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _buildScrollableColumn(
//       String title, double width, List<Map<String, dynamic>> subjects, String? assessmentName) {
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
//             final subject = entry.value;
//             final assessments = List<Map<String, dynamic>>.from(subject['assessments'] ?? []);
//             String value = '';

//             if (assessmentName != null) {
//               final assessment = assessments.firstWhere(
//                 (a) => a['assessment_name'] == assessmentName,
//                 orElse: () => {'score': 0},
//               );
//               value = (assessment['score'] is int
//                   ? (assessment['score'] as int).toDouble().toString()
//                   : assessment['score'].toString());
//             } else if (title == 'Total Score') {
//               value = (subject['total'] is int
//                   ? (subject['total'] as int).toDouble().toString()
//                   : subject['total'].toString());
//             } else if (title == 'Grade') {
//               value = subject['grade'].toString();
//             }

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
//                 value,
//                 style: const TextStyle(fontSize: 14, color: Colors.black),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }
