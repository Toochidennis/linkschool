import 'package:flutter/material.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:provider/provider.dart';
// import 'package:linkschool/modules/auth/auth_provider.dart';
// import 'package:linkschool/modules/env_config.dart';

class ViewCourseResultScreen extends StatefulWidget {
  final String classId;
  final String year;
  final int term;
  final String termName;
  final String subject;
  final Map<String, dynamic> courseData;

  const ViewCourseResultScreen({
    super.key,
    required this.classId,
    required this.year,
    required this.term,
    required this.termName,
    required this.subject,
    required this.courseData,
  });

  @override
  State<ViewCourseResultScreen> createState() => _ViewCourseResultScreenState();
}

class _ViewCourseResultScreenState extends State<ViewCourseResultScreen> {
  late double opacity;
  List<Map<String, dynamic>> courseResults = [];
  List<Map<String, dynamic>> grades = [];
  List<String> assessmentNames = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchCourseResults();
  }

  Future<void> fetchCourseResults() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = locator<ApiService>();

      // Set auth token
      if (authProvider.token != null) {
        apiService.setAuthToken(authProvider.token!);
      }

      // Get DB name from EnvConfig
      final dbName = EnvConfig.dbName;

      // Extract course_id from courseData
      final courseId = widget.courseData['course_id'].toString();

      // Get level_id from courseData or AuthProvider
      final levelId = widget.courseData['level_id']?.toString() ??
          authProvider.getLevels().firstWhere(
                (level) => level['level_name'] == 'JSS1',
                orElse: () => {'id': '66'},
              )['id'].toString();

      // Construct the endpoint
      final endpoint = 'portal/classes/${widget.classId}/courses/$courseId/results';
      final queryParams = {
        'term': widget.term.toString(),
        'year': widget.year,
        '_db': dbName,
        'level_id': levelId,
      };

      final response = await apiService.get(
        endpoint: endpoint,
        queryParams: queryParams,
      );

      if (response.success && response.rawData != null) {
        final results = response.rawData!['response']['course_results'] as List;
        final gradesData = response.rawData!['response']['grades'] as List;

        // Extract unique assessment names
        final uniqueAssessments = <String>{};
        for (var result in results) {
          final assessments = result['assessments'] as List;
          for (var assessment in assessments) {
            uniqueAssessments.add(assessment['assessment_name'] as String);
          }
        }

        setState(() {
          courseResults = List<Map<String, dynamic>>.from(results);
          grades = List<Map<String, dynamic>>.from(gradesData);
          assessmentNames = uniqueAssessments.toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = response.message;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load results: $e';
        isLoading = false;
      });
    }
  }

  String getGradeForScore(String totalScore) {
    if (totalScore.isEmpty || totalScore == '') return 'N/A';
    
    try {
      final score = double.parse(totalScore);
      // Sort grades in descending order of start value
      final sortedGrades = List<Map<String, dynamic>>.from(grades)
        ..sort((a, b) => (b['start'] as num).compareTo(a['start'] as num));
      
      for (var grade in sortedGrades) {
        if (score >= (grade['start'] as num)) {
          return grade['grade_symbol'] as String;
        }
      }
      return 'F'; // Default to F if no grade matches
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.subject} Result',
          style: AppTextStyles.normal600(
            fontSize: 18.0,
            color: AppColors.eLearningBtnColor1,
          ),
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
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: Constants.customBoxDecoration(context),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildTermSection('${widget.year}/${int.parse(widget.year) + 1} ${widget.termName}'),
                          _buildSubjectsTable(),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildTermSection(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
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
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsTable() {
    if (courseResults.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No results available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _buildSubjectColumn(),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildScrollableColumn('Reg Number', 100, courseResults.map((result) => result['reg_no']?.toString() ?? 'N/A').toList()),
                    ...assessmentNames.map((assessmentName) => _buildScrollableColumn(
                          assessmentName,
                          100,
                          courseResults.map((result) {
                            final assessment = (result['assessments'] as List).firstWhere(
                              (a) => a['assessment_name'] == assessmentName,
                              orElse: () => {'score': 'N/A'},
                            );
                            return assessment['score']?.toString() ?? 'N/A';
                          }).toList(),
                        )),
                    _buildScrollableColumn('Total', 100, courseResults.map((result) => result['total_score']?.toString() ?? 'N/A').toList()),
                    _buildGradeColumn('Grade', 80, courseResults.map((result) => getGradeForScore(result['total_score']?.toString() ?? '')).toList()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectColumn() {
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
              'Student Name',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...courseResults.map((result) {
            return Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  result['student_name']?.toString() ?? 'N/A',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScrollableColumn(String title, double width, List<String> data) {
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
          ...data.map((item) {
            return Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Text(
                item,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGradeColumn(String title, double width, List<String> grades) {
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
          ...grades.map((grade) {
            return Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Text(
                grade.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}