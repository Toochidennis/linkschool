

import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';

class AddStaffViewCourseResultScreen extends StatefulWidget {
      // final String classId;
      // final String year;
      // final int term;
      // final String termName;
      // final String subject;
      // final Map<String, dynamic> courseData;

  const AddStaffViewCourseResultScreen({
    super.key,
        // required this.classId,
        // required this.year,
        // required this.term,
        // required this.termName,
        // required this.subject,
        // required this.courseData,
  });

  @override
  State<AddStaffViewCourseResultScreen> createState() => _AddStaffViewCourseResultScreenState();
}

class _AddStaffViewCourseResultScreenState extends State<AddStaffViewCourseResultScreen> {
  late double opacity;
  List<Map<String, dynamic>> courseResults = [];
  List<Map<String, dynamic>> grades = [];
  List<String> assessmentNames = [];
  bool isLoading = true;
  String? error;
  Map<int, Map<String, String>> editedScores = {};
  Map<String, int> maxScores = {};
  Map<String, TextEditingController> _controllers = {};
  // Add this to track which fields are being edited
  Set<String> _editingFields = {};

  @override
  void initState() {
    super.initState();
    print('Initializing AddViewCourseResultScreen');
    // fetchCourseResults();
    // fetchAssessments();
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // Future<void> fetchCourseResults() async {
  //   try {
  //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
  //     final apiService = locator<ApiService>();

  //     if (authProvider.token != null) {
  //       apiService.setAuthToken(authProvider.token!);
  //     }

  //     final dbName = EnvConfig.dbName;
  //     final courseId = widget.courseData['course_id'].toString();
  //     final levelId = widget.courseData['level_id']?.toString() ??
  //         authProvider.getLevels().firstWhere(
  //               (level) => level['level_name'] == 'JSS1',
  //               orElse: () => {'id': '66'},
  //             )['id'].toString();

  //     final endpoint = 'portal/classes/${widget.classId}/courses/$courseId/results';
  //     final queryParams = {
  //       'term': widget.term.toString(),
  //       'year': widget.year,
  //       '_db': dbName,
  //       'level_id': levelId,
  //     };

  //     print('Fetching course results from: $endpoint with params: $queryParams');

  //     final response = await apiService.get(
  //       endpoint: endpoint,
  //       queryParams: queryParams,
  //     );

  //     if (response.success && response.rawData != null) {
  //       final results = response.rawData!['response']['course_results'] as List;
  //       final gradesData = response.rawData!['response']['grades'] as List;

  //       final uniqueAssessments = <String>{};
  //       for (var result in results) {
  //         final assessments = result['assessments'] as List;
  //         print('Result assessments for result_id ${result['result_id']}: $assessments');
  //         for (var assessment in assessments) {
  //           uniqueAssessments.add(assessment['assessment_name'] as String);
  //         }
  //       }

  //       setState(() {
  //         courseResults = List<Map<String, dynamic>>.from(results);
  //         grades = List<Map<String, dynamic>>.from(gradesData);
  //         assessmentNames = uniqueAssessments.toList();
  //         isLoading = false;
  //         // Clear editing state when fresh data is loaded
  //         editedScores.clear();
  //         _editingFields.clear();
  //         // Dispose and clear controllers to prevent stale data
  //         _controllers.forEach((_, controller) => controller.dispose());
  //         _controllers.clear();
  //       });
  //       print('Fetched ${courseResults.length} results, ${grades.length} grades, ${assessmentNames.length} assessments');
  //     } else {
  //       setState(() {
  //         error = response.message;
  //         isLoading = false;
  //       });
  //       print('Failed to fetch results: ${response.message}');
  //     }
  //   } catch (e) {
  //     setState(() {
  //       error = 'Failed to load results: $e';
  //       isLoading = false;
  //     });
  //     print('Error fetching results: $e');
  //   }
  // }

  // Future<void> fetchAssessments() async {
  //   try {
  //     final apiService = locator<ApiService>();
  //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
  //     if (authProvider.token != null) {
  //       apiService.setAuthToken(authProvider.token!);
  //     }

  //     final dbName = EnvConfig.dbName;
  //     final response = await apiService.get(
  //       endpoint: 'portal/assessments',
  //       queryParams: {'_db': dbName},
  //     );

  //     print('Fetching assessments with db: $dbName');

  //     if (response.success && response.rawData != null) {
  //       final assessmentsData = response.rawData!['assessments'] as List;
  //       final tempMaxScores = <String, int>{};
  //       for (var assessmentData in assessmentsData) {
  //         final assessments = assessmentData['assessments'] as List;
  //         for (var assessment in assessments) {
  //           tempMaxScores[assessment['assessment_name']] = assessment['assessment_score'] ?? 0;
  //         }
  //       }
  //       setState(() {
  //         maxScores = tempMaxScores;
  //       });
  //       print('Fetched max scores: $maxScores}');
  //     }
  //   } catch (e) {
  //     setState(() {
  //       error = 'Failed to load assessments: $e';
  //     });
  //     print('Error fetching assessments: $e');
  //   }
  // }

  // Future<void> saveEditedResult(int resultId) async {
  //   if (!editedScores.containsKey(resultId)) {
  //     print('No edits for resultId: $resultId');
  //     return;
  //   }

  //   try {
  //     final apiService = locator<ApiService>();
  //     final userBox = Hive.box('userData');
  //     final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
  //     final userData = userBox.get('userData');
  //     final staffId = userData != null && userData['data'] != null
  //         ? userData['data']['profile']['staff_id'] ?? 0
  //         : 0;

  //     if (staffId == 0) {
  //       CustomToaster.toastError(
  //         context,
  //         'Error',
  //         'Staff ID not found',
  //       );
  //       print('Staff ID not found');
  //       return;
  //     }

  //     final editedResult = editedScores[resultId]!;
  //     final result = courseResults.firstWhere((r) => r['result_id'] == resultId);
  //     final assessments = <Map<String, dynamic>>[];

  //     double totalScore = 0;
  //     for (var assessmentName in assessmentNames) {
  //       final scoreStr = editedResult[assessmentName] ?? result['assessments'].firstWhere(
  //             (a) => a['assessment_name'] == assessmentName,
  //             orElse: () => {'score': ''},
  //           )['score'].toString();
  //       final score = double.tryParse(scoreStr) ?? 0;
  //       final maxScore = maxScores[assessmentName] ?? 0;

  //       if (score > maxScore) {
  //         CustomToaster.toastWarning(
  //           context,
  //           'Validation Error',
  //           'Score for $assessmentName exceeds max score of $maxScore',
  //         );
  //         print('Validation failed: Score $score for $assessmentName exceeds max $maxScore');
  //         return;
  //       }

  //       totalScore += score;
  //       assessments.add({
  //         'assessment_name': assessmentName,
  //         'score': score,
  //         'max_score': maxScore,
  //       });
  //     }

  //     final payload = {
  //       'course_results': [
  //         {
  //           'result_id': resultId,
  //           'staff_id': staffId,
  //           'total_score': totalScore,
  //           'assessments': assessments,
  //         }
  //       ],
  //       '_db': dbName,
  //     };

  //     print('Saving for resultId: $resultId with payload: $payload');

  //     final response = await apiService.put(
  //       endpoint: 'portal/result/class-result',
  //       body: payload,
  //     );

  //     if (response.success) {
  //       setState(() {
  //         // Update the courseResults with the new data
  //         final resultIndex = courseResults.indexWhere((r) => r['result_id'] == resultId);
  //         if (resultIndex != -1) {
  //           courseResults[resultIndex]['total_score'] = totalScore.toString();
  //           courseResults[resultIndex]['assessments'] = assessments.map((a) => {
  //                 'assessment_name': a['assessment_name'],
  //                 'score': a['score'].toString(),
  //                 'max_score': a['max_score'].toString(),
  //               }).toList();
  //         }
          
  //         // Clear edited scores for this result
  //         editedScores.remove(resultId);
          
  //         // Update controllers with new values and clear editing state
  //         for (var assessmentName in assessmentNames) {
  //           final controllerKey = '$resultId-$assessmentName';
  //           final newScore = assessments.firstWhere(
  //             (a) => a['assessment_name'] == assessmentName,
  //             orElse: () => {'score': 0},
  //           )['score'].toString();
            
  //           if (_controllers.containsKey(controllerKey)) {
  //             _controllers[controllerKey]!.text = newScore;
  //           }
  //           _editingFields.remove(controllerKey);
  //         }
  //       });
        
  //       CustomToaster.toastSuccess(
  //         context,
  //         'Success',
  //         'Result updated successfully',
  //       );
  //       print('Result updated successfully for resultId: $resultId');
  //     } else {
  //       CustomToaster.toastError(
  //         context,
  //         'Update Failed',
  //         'Failed to update result: ${response.message}',
  //       );
  //       print('Failed to update result: ${response.message}');
  //     }
  //   } catch (e) {
  //     CustomToaster.toastError(
  //       context,
  //       'Error',
  //       'Error updating result: $e',
  //     );
  //     print('Error updating result: $e');
  //   }
  // }

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
    print('Building UI with isEditing: $isEditing, editedScores: $editedScores');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Result',
          // '${widget.subject} Result',
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
                print('Save button pressed, processing ${editedScores.keys.length} edited results');
                final resultIds = editedScores.keys.toList();
                for (var resultId in resultIds) {
                  // await saveEditedResult(resultId);
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
           child: 
           //isLoading
              // ? const Center(child: CircularProgressIndicator())
              // : error != null
              //     ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
                   SingleChildScrollView(
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
                'term',
                // '${widget.year}/${int.parse(widget.year) + 1} ${widget.termName}',
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
                    final controllerKey = '$resultId-$assessmentName';
                    
                    // Get the current score from either edited scores or original data
                    String currentScore;
                    if (editedScores.containsKey(resultId) && editedScores[resultId]!.containsKey(assessmentName)) {
                      currentScore = editedScores[resultId]![assessmentName]!;
                    } else {
                      final assessmentData = (result['assessments'] as List).firstWhere(
                        (a) => a['assessment_name'] == assessmentName,
                        orElse: () => {'score': ''},
                      );
                      currentScore = assessmentData['score']?.toString() ?? '';
                    }
                    
                    // Initialize controller only if it doesn't exist
                    if (!_controllers.containsKey(controllerKey)) {
                      _controllers[controllerKey] = TextEditingController(text: currentScore);
                    } else if (!_editingFields.contains(controllerKey)) {
                      // Update controller text if not currently being edited
                      _controllers[controllerKey]!.text = currentScore;
                    }
                    
                    print('Score for resultId $resultId, $assessmentName: $currentScore');
                    
                    return DataCell(
                      TextField(
                        controller: _controllers[controllerKey],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onTap: () {
                          setState(() {
                            editedScores[resultId] ??= {};
                            _editingFields.add(controllerKey);
                            print('Tapped assessment: $assessmentName for resultId: $resultId - field ready for editing');
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            editedScores[resultId] ??= {};
                            editedScores[resultId]![assessmentName] = value;
                            print('Changed $assessmentName for resultId: $resultId to: $value');
                          });
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
                  DataCell(
                    Text(
                      _calculateTotal(result, resultId),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  DataCell(
                    Text(
                      getGradeForScore(_calculateTotal(result, resultId)),
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

  String _calculateTotal(Map<String, dynamic> result, int resultId) {
    if (editedScores.containsKey(resultId)) {
      double total = 0;
      for (var assessmentName in assessmentNames) {
        final scoreStr = editedScores[resultId]![assessmentName] ??
            (result['assessments'] as List).firstWhere(
              (a) => a['assessment_name'] == assessmentName,
              orElse: () => {'score': '0'},
            )['score'].toString();
        total += double.tryParse(scoreStr) ?? 0;
      }
      return total.toString();
    }
    return result['total_score']?.toString() ?? 'N/A';
  }
}




