import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:provider/provider.dart';

class StaffAddViewCourseResult extends StatefulWidget {
  final String classId;
  final String subject;
  final Map<String, dynamic> courseData;

  const StaffAddViewCourseResult({
    super.key,
    required this.classId,
    required this.subject,
    required this.courseData,
  });

  @override
  State<StaffAddViewCourseResult> createState() =>
      _StaffAddViewCourseResultState();
}

class _StaffAddViewCourseResultState extends State<StaffAddViewCourseResult> {
  late double opacity;
  List<Map<String, dynamic>> courseResults = [];
  List<Map<String, dynamic>> grades = [];
  List<String> assessmentNames = [];
  bool isLoading = true;
  String? error;
  Map<int, Map<String, String>> editedScores = {};
  Map<String, int> maxScores = {};
  final Map<String, TextEditingController> _controllers = {};
  final Set<String> _editingFields = {};
  String? _problematicFieldKey;
  // Settings from local storage
  String year = '';
  int term = 0;
  String termName = '';

  @override
  void initState() {
    super.initState();
    _problematicFieldKey = null;
    print('Initializing StaffAddViewCourseResultFixed');
    _loadSettingsFromStorage();
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _checkAndSetProblematicField() {
    // Clear existing problematic field
    _problematicFieldKey = null;

    // Find the first field that exceeds max score
    for (var resultId in editedScores.keys) {
      final resultScores = editedScores[resultId]!;
      for (var assessmentName in resultScores.keys) {
        final score = double.tryParse(resultScores[assessmentName] ?? '0') ?? 0;
        final maxScore = maxScores[assessmentName] ?? 0;
        if (score > maxScore) {
          _problematicFieldKey = '$resultId-$assessmentName';
          return; // Return after finding the first problematic field
        }
      }
    }
  }

  bool _hasExceededLimitFields() {
    for (var resultId in editedScores.keys) {
      final resultScores = editedScores[resultId]!;
      for (var assessmentName in resultScores.keys) {
        final score = double.tryParse(resultScores[assessmentName] ?? '0') ?? 0;
        final maxScore = maxScores[assessmentName] ?? 0;
        if (score > maxScore) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> _loadSettingsFromStorage() async {
    try {
      final userBox = Hive.box('userData');

      // Try to get from different possible storage keys
      dynamic storedData =
          userBox.get('userData') ?? userBox.get('loginResponse');

      if (storedData != null) {
        Map<String, dynamic> processedData =
            storedData is String ? json.decode(storedData) : storedData;

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

      final endpoint =
          'portal/classes/${widget.classId}/courses/$courseId/results';
      final queryParams = {
        'term': term.toString(),
        'year': year,
        '_db': dbName,
        'level_id': levelId,
      };

      print(
          'Fetching course results from: $endpoint with params: $queryParams');

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
          print(
              'Result assessments for result_id ${result['result_id']}: $assessments');
          for (var assessment in assessments) {
            uniqueAssessments.add(assessment['assessment_name'] as String);
          }
        }

        setState(() {
          courseResults = List<Map<String, dynamic>>.from(results);
          grades = List<Map<String, dynamic>>.from(gradesData);
          assessmentNames = uniqueAssessments.toList();
          isLoading = false;
          editedScores.clear();
          _editingFields.clear();
          _controllers.forEach((_, controller) => controller.dispose());
          _controllers.clear();
        });

        print(
            'Fetched ${courseResults.length} results, ${grades.length} grades, ${assessmentNames.length} assessments');
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
      print('Assessments API response: ${response.rawData}');

      if (response.success && response.rawData != null) {
        final tempMaxScores = <String, int>{};

        // Try different possible response structures
        dynamic assessmentsData = response.rawData!['assessments'] ??
            response.rawData!['response']?['assessments'] ??
            response.rawData!['data']?['assessments'];

        if (assessmentsData != null && assessmentsData is List) {
          for (var assessmentData in assessmentsData) {
            // Handle nested assessments structure
            if (assessmentData.containsKey('assessments') &&
                assessmentData['assessments'] is List) {
              final assessments = assessmentData['assessments'] as List;
              for (var assessment in assessments) {
                final assessmentName =
                    assessment['assessment_name']?.toString();
                final assessmentScore = assessment['assessment_score'];

                if (assessmentName != null && assessmentScore != null) {
                  tempMaxScores[assessmentName] = assessmentScore is int
                      ? assessmentScore
                      : int.tryParse(assessmentScore.toString()) ?? 0;
                }
              }
            } else {
              // Handle flat structure
              final assessmentName =
                  assessmentData['assessment_name']?.toString();
              final assessmentScore = assessmentData['assessment_score'];

              if (assessmentName != null && assessmentScore != null) {
                tempMaxScores[assessmentName] = assessmentScore is int
                    ? assessmentScore
                    : int.tryParse(assessmentScore.toString()) ?? 0;
              }
            }
          }
        }

        setState(() {
          maxScores = tempMaxScores;
        });
        print('Fetched max scores: $maxScores');

        // Debug: Print each assessment name and max score
        maxScores.forEach((name, score) {
          print('Assessment: $name, Max Score: $score');
        });
      } else {
        print('Failed to fetch assessments: ${response.message}');
      }
    } catch (e) {
      print('Error fetching assessments: $e');
      // Don't set error state for assessments failure as it's not critical
    }
  }

  Future<void> saveEditedResult(int resultId) async {
    if (!editedScores.containsKey(resultId)) {
      print('No edits for resultId: $resultId');
      return;
    }

    _checkAndSetProblematicField();
    if (_problematicFieldKey != null) {
      CustomToaster.toastWarning(
        context,
        'Validation Error',
        'Please fix all exceeded scores before saving',
      );
      return;
    }

    try {
      final apiService = locator<ApiService>();
      final userBox = Hive.box('userData');
      final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
      final userData = userBox.get('userData');
      final staffId = userData != null && userData['data'] != null
          ? userData['data']['profile']['staff_id'] ?? 0
          : 0;

      if (staffId == 0) {
        CustomToaster.toastError(
          context,
          'Error',
          'Staff ID not found',
        );
        print('Staff ID not found');
        return;
      }

      final editedResult = editedScores[resultId]!;
      final result =
          courseResults.firstWhere((r) => r['result_id'] == resultId);
      final assessments = <Map<String, dynamic>>[];
      double totalScore = 0;

      for (var assessmentName in assessmentNames) {
        final scoreStr = editedResult[assessmentName] ??
            result['assessments']
                .firstWhere(
                  (a) => a['assessment_name'] == assessmentName,
                  orElse: () => {'score': ''},
                )['score']
                .toString();
        final score = double.tryParse(scoreStr) ?? 0;
        final maxScore = maxScores[assessmentName] ?? 0;

        if (score > maxScore) {
          CustomToaster.toastWarning(
            context,
            'Validation Error',
            'Score for $assessmentName exceeds max score of $maxScore',
          );
          print(
              'Validation failed: Score $score for $assessmentName exceeds max $maxScore');
          return;
        }

        totalScore += score;
        assessments.add({
          'assessment_name': assessmentName,
          'score': score,
          'max_score': maxScore,
        });
      }

      final payload = {
        'course_results': [
          {
            'result_id': resultId,
            'staff_id': staffId,
            'total_score': totalScore,
            'assessments': assessments,
          }
        ],
        '_db': dbName,
      };

      print('Saving for resultId: $resultId with payload: $payload');

      final response = await apiService.put(
        endpoint: 'portal/result/class-result',
        body: payload,
      );

      if (response.success) {
        setState(() {
          final resultIndex =
              courseResults.indexWhere((r) => r['result_id'] == resultId);
          if (resultIndex != -1) {
            courseResults[resultIndex]['total_score'] = totalScore.toString();
            courseResults[resultIndex]['assessments'] = assessments
                .map((a) => {
                      'assessment_name': a['assessment_name'],
                      'score': a['score'].toString(),
                      'max_score': a['max_score'].toString(),
                    })
                .toList();
          }

          editedScores.remove(resultId);

          for (var assessmentName in assessmentNames) {
            final controllerKey = '$resultId-$assessmentName';
            final newScore = assessments
                .firstWhere(
                  (a) => a['assessment_name'] == assessmentName,
                  orElse: () => {'score': 0},
                )['score']
                .toString();

            if (_controllers.containsKey(controllerKey)) {
              _controllers[controllerKey]!.text = newScore;
            }
            _editingFields.remove(controllerKey);
          }
        });

        CustomToaster.toastSuccess(
          context,
          'Success',
          'Result updated successfully',
        );
        print('Result updated successfully for resultId: $resultId');
      } else {
        CustomToaster.toastError(
          context,
          'Update Failed',
          'Failed to update result: ${response.message}',
        );
        print('Failed to update result: ${response.message}');
      }
    } catch (e) {
      CustomToaster.toastError(
        context,
        'Error',
        'Error updating result: $e',
      );
      print('Error updating result: $e');
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

  String _calculateTotal(Map<String, dynamic> result, int resultId) {
    if (editedScores.containsKey(resultId)) {
      double total = 0;
      for (var assessmentName in assessmentNames) {
        final scoreStr = editedScores[resultId]![assessmentName] ??
            (result['assessments'] as List)
                .firstWhere(
                  (a) => a['assessment_name'] == assessmentName,
                  orElse: () => {'score': '0'},
                )['score']
                .toString();
        total += double.tryParse(scoreStr) ?? 0;
      }
      return total.toString();
    }
    return result['total_score']?.toString() ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    final isEditing = editedScores.isNotEmpty;

    print(
        'Building UI with isEditing: $isEditing, editedScores: $editedScores');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.subject} Result',
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
        actions: [
          if (isEditing)
            TextButton(
              onPressed: () async {
                print(
                    'Save button pressed, processing ${editedScores.keys.length} edited results');
                final resultIds = editedScores.keys.toList();
                for (var resultId in resultIds) {
                  await saveEditedResult(resultId);
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  color: AppColors.eLearningBtnColor1,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
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
                    ? Center(
                        child: Text(error!,
                            style: const TextStyle(color: Colors.red)))
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
                    _buildScrollableColumn('Reg Number', 120, -1,
                        isRegNo: true),
                    ...assessmentNames
                        .asMap()
                        .entries
                        .map((entry) => _buildScrollableColumn(
                              entry.value,
                              100,
                              entry.key,
                              isAssessment: true,
                            )),
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
                minHeight:
                    60, // Increased minimum height to accommodate wrapped text
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

  // Replace the _buildScrollableColumn method entirely with this updated version:

  Widget _buildScrollableColumn(String title, double width, int index,
      {bool isRegNo = false,
      bool isAssessment = false,
      bool isTotal = false,
      bool isGrade = false}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // UPDATED HEADER - Shows max score for assessments
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
            child: isAssessment
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '(Max: ${maxScores[title] ?? 0})',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          ...courseResults.map((result) {
            final resultId = result['result_id'] as int;

            if (isRegNo) {
              // Registration Number - Non-editable
              return Container(
                constraints: const BoxConstraints(
                  minHeight: 60,
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
                  result['reg_no']?.toString() ?? '-',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            } else if (isAssessment) {
              // Assessment Scores - Editable
              final controllerKey = '$resultId-$title';
              String currentScore;
              if (editedScores.containsKey(resultId) &&
                  editedScores[resultId]!.containsKey(title)) {
                currentScore = editedScores[resultId]![title]!;
              } else {
                final assessmentData =
                    (result['assessments'] as List).firstWhere(
                  (a) => a['assessment_name'] == title,
                  orElse: () => {'score': ''},
                );
                currentScore = assessmentData['score']?.toString() ?? '';
              }

              if (!_controllers.containsKey(controllerKey)) {
                _controllers[controllerKey] =
                    TextEditingController(text: currentScore);
              } else if (!_editingFields.contains(controllerKey)) {
                _controllers[controllerKey]!.text = currentScore;
              }

              // Add validation variables
              final maxScore = maxScores[title] ?? 0;
              final currentValue =
                  double.tryParse(_controllers[controllerKey]!.text) ?? 0;
              final isThisFieldProblematic =
                  _problematicFieldKey == controllerKey;
              final hasProblematicField = _problematicFieldKey != null;
              final isFieldEnabled =
                  !hasProblematicField || isThisFieldProblematic;

              return Container(
                constraints: const BoxConstraints(
                  minHeight: 60,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isFieldEnabled ? Colors.grey[100] : Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                    right: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextField(
                    controller: _controllers[controllerKey],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          (currentValue > maxScore) ? Colors.red : Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: '0/$maxScore',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                      filled: !isFieldEnabled,
                      fillColor: !isFieldEnabled
                          ? Colors.grey[100]
                          : Colors.transparent,
                    ),
                    enabled: isFieldEnabled,
                    onTap: () {
                      // If there's already a problematic field and this isn't it, show warning
                      if (_problematicFieldKey != null &&
                          _problematicFieldKey != controllerKey) {
                        CustomToaster.toastWarning(
                          context,
                          'Fix Required',
                          'Please fix the score for the highlighted field first',
                        );
                        return;
                      }

                      setState(() {
                        editedScores[resultId] ??= {};
                        _editingFields.add(controllerKey);
                        print(
                            'Tapped assessment: $title for resultId: $resultId - field ready for editing');
                      });
                    },
                    onChanged: (value) {
                      final newScore = double.tryParse(value) ?? 0;
                      final maxScore = maxScores[title] ?? 0;

                      setState(() {
                        editedScores[resultId] ??= {};
                        editedScores[resultId]![title] = value;

                        // Check if this field exceeds max score
                        if (newScore > maxScore) {
                          _problematicFieldKey = controllerKey;
                        } else {
                          // If this was the problematic field and is now fixed, clear it
                          if (_problematicFieldKey == controllerKey) {
                            _problematicFieldKey = null;
                          }
                        }
                        print(
                            'Changed $title for resultId: $resultId to: $value');
                      });

                      // Show warning if score exceeds max
                      if (newScore > maxScore) {
                        CustomToaster.toastWarning(
                          context,
                          'Score Limit Exceeded',
                          'Score for $title cannot exceed $maxScore. Fix this field to continue.',
                        );
                      }
                    },
                    onSubmitted: (value) {
                      setState(() {
                        _editingFields.remove(controllerKey);
                      });
                    },
                    onEditingComplete: () {
                      setState(() {
                        _editingFields.remove(controllerKey);
                      });
                    },
                  ),
                ),
              );
            } else if (isTotal) {
              // Total Score - Calculated
              return Container(
                constraints: const BoxConstraints(
                  minHeight: 60,
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
                  _calculateTotal(result, resultId),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            } else if (isGrade) {
              // Grade - Calculated
              return Container(
                constraints: const BoxConstraints(
                  minHeight: 60,
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
                  getGradeForScore(_calculateTotal(result, resultId)),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            // Default return for other cases
            return Container(
              constraints: const BoxConstraints(
                minHeight: 60,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: const Text(
                '-',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
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
