import 'package:flutter/material.dart';
import 'package:linkschool/config/env_config.dart';
// import 'package:linkschool/config/env.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:provider/provider.dart';

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
  Map<String, int> maxScores = {};

  @override
  void initState() {
    super.initState();
    print('Initializing ViewCourseResultScreen');
    fetchCourseResults();
    fetchAssessments();
  }

  Future<void> fetchCourseResults() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = locator<ApiService>();

      if (authProvider.token != null) {
        apiService.setAuthToken(authProvider.token!);
      }

      final dbName = EnvConfig.dbName;
      final courseId = widget.courseData['course_id'].toString();
      final levelId = widget.courseData['level_id']?.toString() ??
          authProvider.getLevels().firstWhere(
                (level) => level['level_name'] == 'JSS1',
                orElse: () => {'id': '66'},
              )['id'].toString();

      final endpoint = 'portal/classes/${widget.classId}/courses/$courseId/results';
      final queryParams = {
        'term': widget.term.toString(),
        'year': widget.year,
        '_db': dbName,
        'level_id': levelId,
      };

      print('Fetching course results from: $endpoint with params: $queryParams');

      final response = await apiService.get(
        endpoint: endpoint,
        queryParams: queryParams,
      );

      if (response.success && response.rawData != null) {
        final results = response.rawData!['response']['course_results'] as List;
        final gradesData = response.rawData!['response']['grades'] as List;

        final uniqueAssessments = <String>{};
        for (var result in results) {
          final assessments = result['assessments'] as List;
          print('Result assessments for result_id ${result['result_id']}: $assessments');
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
        print('Fetched ${courseResults.length} results, ${grades.length} grades, ${assessmentNames.length} assessments');
      } else {
        setState(() {
          error = response.message;
          isLoading = false;
        });
        print('Failed to fetch results: ${response.message}');
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load results: $e';
        isLoading = false;
      });
      print('Error fetching results: $e');
    }
  }

  Future<void> fetchAssessments() async {
    try {
      final apiService = locator<ApiService>();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        apiService.setAuthToken(authProvider.token!);
      }

      final dbName = EnvConfig.dbName;
      final response = await apiService.get(
        endpoint: 'portal/assessments',
        queryParams: {'_db': dbName},
      );

      print('Fetching assessments with db: $dbName');

      if (response.success && response.rawData != null) {
        final assessmentsData = response.rawData!['assessments'] as List;
        final tempMaxScores = <String, int>{};
        for (var assessmentData in assessmentsData) {
          final assessments = assessmentData['assessments'] as List;
          for (var assessment in assessments) {
            tempMaxScores[assessment['assessment_name']] = assessment['assessment_score'] ?? 0;
          }
        }
        setState(() {
          maxScores = tempMaxScores;
        });
        print('Fetched max scores: $maxScores');
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load assessments: $e';
      });
      print('Error fetching assessments: $e');
    }
  }

  String getGradeForScore(String totalScore) {
    if (totalScore.isEmpty || totalScore == '') return 'N/A';
    try {
      final score = double.parse(totalScore);
      final sortedGrades = List<Map<String, dynamic>>.from(grades)
        ..sort((a, b) => (b['start'] as num).compareTo(a['start'] as num));
      for (var grade in sortedGrades) {
        if (score >= (grade['start'])) {
          return grade['grade_symbol'] as String;
        }
      }
      return 'F';
    } catch (e) {
      print('Error calculating grade for score $totalScore: $e');
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.subject} Result (View Only)',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
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
      body: SafeArea(
        child: SizedBox.expand(
          child: Container(
            decoration: Constants.customBoxDecoration(context),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildTermSection(),
                            _buildCoursesTable(),
                          ],
                        ),
                      ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermSection() {
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
                '${widget.year}/${int.parse(widget.year) + 1} ${widget.termName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesTable() {
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
            _buildStudentColumn(),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildScrollableColumn('Reg Number', 120, -1, isRegNo: true),
                    ...assessmentNames
                        .asMap()
                        .entries
                        .map((entry) => _buildScrollableColumn(
                              entry.value,
                              100,
                              entry.key,
                              isAssessment: true,
                            ))
                        .toList(),
                    _buildScrollableColumn('Total', 100, -2, isTotal: true),
                    _buildScrollableColumn('Grade', 100, -3, isGrade: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build fixed student column
  Widget _buildStudentColumn() {
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
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Build scrollable column for reg number, assessments, total, or grade
  Widget _buildScrollableColumn(String title, double width, int index,
      {bool isRegNo = false, bool isAssessment = false, bool isTotal = false, bool isGrade = false}) {
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
          ...courseResults.map((result) {
            String value = '-';
            if (isRegNo) {
              value = result['reg_no']?.toString() ?? '-';
            } else if (isAssessment) {
              final assessmentData = (result['assessments'] as List).firstWhere(
                (a) => a['assessment_name'] == title,
                orElse: () => {'score': ''},
              );
              value = assessmentData['score']?.toString() ?? '-';
            } else if (isTotal) {
              value = result['total_score']?.toString() ?? '-';
            } else if (isGrade) {
              value = getGradeForScore(result['total_score']?.toString() ?? '');
            }
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
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: isGrade ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
