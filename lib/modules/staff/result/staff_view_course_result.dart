import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:provider/provider.dart';

class StaffViewCourseResult extends StatefulWidget {
  final String classId;
  final String subject;
  final Map<String, dynamic> courseData;

  const StaffViewCourseResult({
    super.key,
    required this.classId,
    required this.subject,
    required this.courseData,
  });

  @override
  State<StaffViewCourseResult> createState() => _StaffViewCourseResultState();
}

class _StaffViewCourseResultState extends State<StaffViewCourseResult> {
  late double opacity;
  List<Map<String, dynamic>> courseResults = [];
  List<Map<String, dynamic>> grades = [];
  List<String> assessmentNames = [];
  bool isLoading = true;
  String? error;
  Map<String, int> maxScores = {};
  
  // Settings from local storage
  String year = '';
  int term = 0;
  String termName = '';

  @override
  void initState() {
    super.initState();
    print('Initializing StaffViewCourseResultFixed');
    _loadSettingsFromStorage();
  }

  Future<void> _loadSettingsFromStorage() async {
    try {
      final userBox = Hive.box('userData');
      
      // Try to get from different possible storage keys
      dynamic storedData = userBox.get('userData') ?? userBox.get('loginResponse');
      
      if (storedData != null) {
        Map<String, dynamic> processedData = storedData is String
            ? json.decode(storedData)
            : storedData;
            
        final response = processedData['response'] ?? processedData;
        final data = response['data'] ?? response;
        final settings = data['settings'] ?? {};
        
        setState(() {
          year = settings['year']?.toString() ?? '';
          term = settings['term'] ?? 0;
          termName = 'Term $term';
        });
        
        print('Loaded settings from storage - Year: $year, Term: $term');
        
        // Now fetch the course results with the correct parameters
        await fetchCourseResults();
        await fetchAssessments();
      } else {
        setState(() {
          error = 'Settings not found in local storage';
          isLoading = false;
        });
        print('No settings found in local storage');
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load settings: $e';
        isLoading = false;
      });
      print('Error loading settings: $e');
    }
  }

  Future<void> fetchCourseResults() async {
    if (year.isEmpty || term == 0) {
      setState(() {
        error = 'Invalid year or term from settings';
        isLoading = false;
      });
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = locator<ApiService>();
      
      if (authProvider.token != null) {
        apiService.setAuthToken(authProvider.token!);
      }

      final dbName = EnvConfig.dbName;
      final courseId = widget.courseData['course_id'].toString();
      
      // Get level_id from course data or use a default
      final levelId = widget.courseData['level_id']?.toString() ?? '66';

      final endpoint = 'portal/classes/${widget.classId}/courses/$courseId/results';
      final queryParams = {
        'term': term.toString(),
        'year': year,
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
                year.isNotEmpty && term > 0 
                    ? '$year/${int.parse(year) + 1} $termName'
                    : 'Loading session...',
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

  Widget _buildStudentColumn() {
    return Container(
      width: 140, // Increased width slightly for better text display
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Text(
              'Student Name',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ...courseResults.map((result) {
            final studentName = result['student_name']?.toString() ?? 'N/A';
            
            return Container(
              constraints: const BoxConstraints(
                minHeight: 60, // Increased minimum height to accommodate wrapped text
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Center(
                child: Text(
                  studentName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                    height: 1.3, // Improved line spacing
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3, // Allow up to 3 lines
                  overflow: TextOverflow.ellipsis,
                  softWrap: true, // Enable text wrapping
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

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
              constraints: const BoxConstraints(
                minHeight: 60, // Match the height of student name cells
              ),
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
                textAlign: TextAlign.center,
              ),
            );
          }),
        ],
      ),
    );
  }
}



