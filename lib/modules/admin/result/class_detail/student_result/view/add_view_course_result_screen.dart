import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:provider/provider.dart';

class AddViewCourseResultScreen extends StatefulWidget {
  final String classId;
  final String year;
  final int term;
  final String termName;
  final String subject;
  final Map<String, dynamic> courseData;

  const AddViewCourseResultScreen({
    super.key,
    required this.classId,
    required this.year,
    required this.term,
    required this.termName,
    required this.subject,
    required this.courseData,
  });

  @override
  State<AddViewCourseResultScreen> createState() =>
      _AddViewCourseResultScreenState();
}

class _AddViewCourseResultScreenState extends State<AddViewCourseResultScreen> {
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

  @override
  void initState() {
    super.initState();
    print('Initializing AddViewCourseResultScreen');
    _problematicFieldKey = null;
    fetchCourseResults();
    fetchAssessments();
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
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
          authProvider
              .getLevels()
              .firstWhere(
                (level) => level['level_name'] == 'JSS1',
                orElse: () => {'id': '66'},
              )['id']
              .toString();

      final endpoint =
          'portal/classes/${widget.classId}/courses/$courseId/results';
      final queryParams = {
        'term': widget.term.toString(),
        'year': widget.year,
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

      if (response.success && response.rawData != null) {
        final assessmentsData = response.rawData!['assessments'] as List;
        final tempMaxScores = <String, int>{};
        for (var assessmentData in assessmentsData) {
          final assessments = assessmentData['assessments'] as List;
          for (var assessment in assessments) {
            tempMaxScores[assessment['assessment_name']] =
                assessment['assessment_score'] ?? 0;
          }
        }
        setState(() {
          maxScores = tempMaxScores;
        });
        print('Fetched max scores: $maxScores}');
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load assessments: $e';
      });
      print('Error fetching assessments: $e');
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
      // ... rest of your existing saveEditedResult code
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

      // ... rest of your existing payload and API call
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
      body: SizedBox.expand(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed Student Name Column (unchanged)
            Container(
              width: 150,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 48,
                    color: AppColors.eLearningBtnColor1,
                    child: const Center(
                      child: Text(
                        'Student Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  ...courseResults.asMap().entries.map((entry) {
                    final result = entry.value;
                    return Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          result['student_name']?.toString() ?? 'N/A',
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            // Scrollable Columns
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    // Header Row with max scores
                    Container(
                      height: 48,
                      color: AppColors.eLearningBtnColor1,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: const Center(
                              child: Text(
                                'Reg Number',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          ...assessmentNames.map((name) => SizedBox(
                                width: 100,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '(Max: ${maxScores[name] ?? 0})',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                          SizedBox(
                            width: 80,
                            child: const Center(
                              child: Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: const Center(
                              child: Text(
                                'Grade',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Data Rows
                    ...courseResults.asMap().entries.map((entry) {
                      final result = entry.value;
                      final resultId = result['result_id'] as int;
                      return Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom:
                                BorderSide(color: Colors.grey[300]!, width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 120,
                              child: Center(
                                child: Text(
                                  result['reg_no']?.toString() ?? 'N/A',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            ...assessmentNames.map((assessmentName) {
                              final controllerKey = '$resultId-$assessmentName';
                              String currentScore;
                              if (editedScores.containsKey(resultId) &&
                                  editedScores[resultId]!
                                      .containsKey(assessmentName)) {
                                currentScore =
                                    editedScores[resultId]![assessmentName]!;
                              } else {
                                final assessmentData =
                                    (result['assessments'] as List).firstWhere(
                                  (a) => a['assessment_name'] == assessmentName,
                                  orElse: () => {'score': ''},
                                );
                                currentScore =
                                    assessmentData['score']?.toString() ?? '';
                              }

                              if (!_controllers.containsKey(controllerKey)) {
                                _controllers[controllerKey] =
                                    TextEditingController(text: currentScore);
                              } else if (!_editingFields
                                  .contains(controllerKey)) {
                                _controllers[controllerKey]!.text =
                                    currentScore;
                              }

                              final maxScore = maxScores[assessmentName] ?? 0;
                              final currentValue = double.tryParse(
                                      _controllers[controllerKey]!.text) ??
                                  0;
                              final isThisFieldProblematic =
                                  _problematicFieldKey == controllerKey;
                              final hasProblematicField =
                                  _problematicFieldKey != null;
                              final isFieldEnabled = !hasProblematicField ||
                                  isThisFieldProblematic;

                              return SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: _controllers[controllerKey],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: (currentValue > maxScore)
                                        ? Colors.red
                                        : Colors.black,
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
                                    });
                                  },
                                  onChanged: (value) {
                                    final newScore =
                                        double.tryParse(value) ?? 0;
                                    final maxScore =
                                        maxScores[assessmentName] ?? 0;

                                    setState(() {
                                      editedScores[resultId] ??= {};
                                      editedScores[resultId]![assessmentName] =
                                          value;

                                      // Check if this field exceeds max score
                                      if (newScore > maxScore) {
                                        _problematicFieldKey = controllerKey;
                                      } else {
                                        // If this was the problematic field and is now fixed, clear it
                                        if (_problematicFieldKey ==
                                            controllerKey) {
                                          _problematicFieldKey = null;
                                        }
                                      }
                                    });

                                    // Show warning if score exceeds max
                                    if (newScore > maxScore) {
                                      CustomToaster.toastWarning(
                                        context,
                                        'Score Limit Exceeded',
                                        'Score for $assessmentName cannot exceed $maxScore. Fix this field to continue.',
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
                              );
                            }),
                            SizedBox(
                              width: 80,
                              child: Center(
                                child: Text(
                                  _calculateTotal(result, resultId),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Center(
                                child: Text(
                                  getGradeForScore(
                                      _calculateTotal(result, resultId)),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
}
