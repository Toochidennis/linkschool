import 'package:flutter/material.dart';
import 'package:linkschool/config/env_config.dart';
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
        if (score >= (grade['start'] as num)) {
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
                          _buildTermSection(),
                          _buildSubjectsTable(),
                        ],
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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 10,
            headingRowHeight: 48,
            dataRowHeight: 50,
            headingRowColor: MaterialStateProperty.all(AppColors.eLearningBtnColor1),
            dividerThickness: 1, // Add vertical divider between columns
            columns: [
              const DataColumn(
                label: Text(
                  'Student Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Reg Number',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              ...assessmentNames.map((name) => DataColumn(
                    label: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  )),
              const DataColumn(
                label: Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Grade',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            rows: courseResults.asMap().entries.map((entry) {
              final index = entry.key;
              final result = entry.value;
              final resultId = result['result_id'] as int;

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      result['student_name']?.toString() ?? 'N/A',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  DataCell(
                    Text(
                      result['reg_no']?.toString() ?? 'N/A',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  ...assessmentNames.map((assessmentName) {
                    // Get the score from original data only (no editing capability)
                    final assessmentData = (result['assessments'] as List).firstWhere(
                      (a) => a['assessment_name'] == assessmentName,
                      orElse: () => {'score': ''},
                    );
                    final currentScore = assessmentData['score']?.toString() ?? '';
                    
                    return DataCell(
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          currentScore,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }),
                  DataCell(
                    Text(
                      result['total_score']?.toString() ?? 'N/A',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  DataCell(
                    Text(
                      getGradeForScore(result['total_score']?.toString() ?? ''),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}