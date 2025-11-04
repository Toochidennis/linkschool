import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/providers/admin/student_provider.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class StudentSingleTermResultScreen extends StatefulWidget {
  final int studentId;
  final int termId;
  final String classId;
  final String year;
  final String levelId;
  final String termName;

  const StudentSingleTermResultScreen({
    super.key,
    required this.studentId,
    required this.termId,
    required this.classId,
    required this.year,
    required this.levelId,
    required this.termName,
  });

  @override
  State<StudentSingleTermResultScreen> createState() =>
      _StudentSingleTermResultScreenState();
}

class _StudentSingleTermResultScreenState
    extends State<StudentSingleTermResultScreen> {
  String? studentName;

  @override
  void initState() {
    super.initState();
    _loadStudentName();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);
      debugPrint(
          'StudentSingleTermResult: Fetching term results for studentId=${widget.studentId}, '
          'termId=${widget.termId}, classId=${widget.classId}, '
          'year=${widget.year}, levelId=${widget.levelId}');
      studentProvider.fetchStudentTermResults(
        studentId: widget.studentId,
        termId: widget.termId,
        classId: widget.classId,
        year: widget.year,
        levelId: widget.levelId,
      );
    });
  }

  void _loadStudentName() {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');

    if (loginData != null) {
      Map<String, dynamic> processedData =
          loginData is String ? json.decode(loginData) : loginData;

      final response = processedData['response'] ?? processedData;
      final data = response['data'] ?? response;
      final profile = data['profile'] ?? {};

      setState(() {
        studentName = profile['name'] ?? 'Unknown Student';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final double opacity = brightness == Brightness.light ? 0.1 : 0.15;

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
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Consumer<StudentProvider>(
          builder: (context, studentProvider, child) {
            debugPrint(
                'StudentSingleTermResult Consumer: isLoading=${studentProvider.isLoading}, '
                'errorMessage=${studentProvider.errorMessage}, '
                'termResult=${studentProvider.studentTermResult}');

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
            if (termResult == null || termResult.isEmpty) {
              return const Center(child: Text('No term results available'));
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: Column(
                      children: [
                        _buildProfileImage(),
                        const SizedBox(height: 10),
                        Text(
                          studentName ?? 'Unknown Student',
                          style: AppTextStyles.normal700(
                            fontSize: 20,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildAverageSection(termResult),
                  _buildTermSection(widget.termName, termResult),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _downloadTermResults() async {
    final url =
        'https://linkskool.net/api/v1/students/${widget.studentId}/terms/${widget.termId}/results/download';

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

  Widget _buildProfileImage() {
    // For student, we'll use a default profile image since picture_url might not be available
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

  Widget _buildAverageSection(Map<String, dynamic> termResult) {
    final average = (termResult['average'] is int
        ? (termResult['average'] as int).toDouble()
        : termResult['average'] is String
            ? double.tryParse(termResult['average'].toString()) ?? 0.0
            : termResult['average'] as double? ?? 0.0);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Term average',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryDark,
            ),
          ),
          Text(
            '${average.toStringAsFixed(2)}%',
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

  Widget _buildScrollableColumn(String title, double width,
      List<dynamic> subjects, String? assessmentName) {
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

  String _getDataForColumn(
      String columnName, Map<String, dynamic> subject, String? assessmentName) {
    if (assessmentName != null) {
      final assessments = subject['assessments'] as List<dynamic>? ?? [];
      final assessment = assessments.firstWhere(
        (a) => a['assessment_name'] == assessmentName,
        orElse: () => {'score': 'N/A'},
      );
      return (assessment['score'] is int
          ? (assessment['score'] as int).toDouble().toString()
          : assessment['score'].toString());
    }
    switch (columnName) {
      case 'Total Score':
        return (subject['total'] is int
            ? (subject['total'] as int).toDouble().toString()
            : subject['total']?.toString() ?? 'N/A');
      case 'Grade':
        return subject['grade']?.toString() ?? 'N/A';
      case 'Remarks':
        return subject['remark']?.toString() ?? 'N/A';
      default:
        return 'N/A';
    }
  }
}
