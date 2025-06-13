import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:provider/provider.dart';

class CommentCourseResultScreen extends StatefulWidget {
  final String classId;
  final String year;
  final String termName;
  final int term;

  const CommentCourseResultScreen({
    super.key,
    required this.classId,
    required this.year,
    required this.termName,
    required this.term,
  });

  @override
  State<CommentCourseResultScreen> createState() => _CommentCourseResultScreenState();
}

class _CommentCourseResultScreenState extends State<CommentCourseResultScreen> {
  List<Map<String, dynamic>> studentResults = [];
  List<String> assessmentNames = [];
  bool isLoading = true;
  String? error;
  final TextEditingController _commentController = TextEditingController();
  int _currentStudentIndex = 0;
  final SwiperController _swiperController = SwiperController();

  @override
  void initState() {
    super.initState();
    fetchStudentResults();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> fetchStudentResults() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = locator<ApiService>();
      final userBox = Hive.box('userData');
      final levelId = userBox.get('currentLevelId')?.toString() ?? '66';
      final role = userBox.get('role')?.toString() ?? 'admin';

      if (authProvider.token != null) {
        apiService.setAuthToken(authProvider.token!);
      }

      final dbName = EnvConfig.dbName;
      final endpoint = 'portal/classes/${widget.classId}/students-result';
      final queryParams = {
        '_db': dbName,
        'year': widget.year,
        'term': widget.term.toString(),
        'level_id': levelId,
        'role': role,
      };

      print('Fetching student results from: $endpoint with params: $queryParams');

      final response = await apiService.get(
        endpoint: endpoint,
        queryParams: queryParams,
      );

      if (response.success && response.rawData != null) {
        final results = response.rawData!['response'] as List;
        final uniqueAssessments = <String>{};

        for (var student in results) {
          for (var subject in student['subjects'] as List) {
            for (var assessment in subject['assessments'] as List) {
              uniqueAssessments.add(assessment['assessment_name'] as String);
            }
          }
        }

        setState(() {
          studentResults = List<Map<String, dynamic>>.from(results);
          assessmentNames = uniqueAssessments.toList();
          _commentController.text = studentResults.isNotEmpty ? studentResults[0]['comment'] ?? '' : '';
          isLoading = false;
        });
        print('Fetched ${studentResults.length} student results, ${assessmentNames.length} assessments');
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

  Future<void> submitComment(int studentId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = locator<ApiService>();
      final userBox = Hive.box('userData');
      final role = userBox.get('role')?.toString() ?? 'admin';

      if (authProvider.token != null) {
        apiService.setAuthToken(authProvider.token!);
      }

      final dbName = EnvConfig.dbName;
      final endpoint = 'portal/students/result/comment';
      final payload = {
        'student_id': studentId,
        'comment': _commentController.text,
        'role': role,
        'year': int.parse(widget.year),
        'term': widget.term,
        '_db': dbName,
      };

      print('Submitting comment to: $endpoint with payload: $payload');

      final response = await apiService.post(
        endpoint: endpoint,
        body: payload,
      );

      if (response.success) {
        setState(() {
          studentResults[_currentStudentIndex]['comment'] = _commentController.text;
        });
        print('Comment submitted successfully for student $studentId');
      } else {
        setState(() {
          error = response.message;
        });
        print('Failed to submit comment: ${response.message}');
      }
    } catch (e) {
      setState(() {
        error = 'Failed to submit comment: $e';
      });
      print('Error submitting comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Comment on Results',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.eLearningBtnColor1,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
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
              ),
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
                  : Stack(
                      children: [
                        Swiper(
                          controller: _swiperController,
                          itemCount: studentResults.length,
                          index: _currentStudentIndex,
                          onIndexChanged: (index) {
                            setState(() {
                              _currentStudentIndex = index;
                              _commentController.text = studentResults[index]['comment'] ?? '';
                            });
                          },
                          itemBuilder: (context, index) {
                            final student = studentResults[index];
                            return Column(
                              children: [
                                _buildStudentHeader(student),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        _buildTermSection(),
                                        _buildSubjectsTable(student),
                                        _buildCommentDisplay(student),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: _buildCommentInput(),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildStudentHeader(Map<String, dynamic> student) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _currentStudentIndex > 0
                ? () => _swiperController.previous(animation: true)
                : null,
            icon: Icon(
              Icons.arrow_back_ios,
              color: _currentStudentIndex > 0 ? AppColors.eLearningBtnColor1 : Colors.grey,
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.primaries[_currentStudentIndex % Colors.primaries.length],
                child: Text(
                  student['student_name']?.isNotEmpty == true
                      ? student['student_name'][0].toUpperCase()
                      : 'S',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                student['student_name'] ?? 'N/A',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _currentStudentIndex < studentResults.length - 1
                ? () => _swiperController.next(animation: true)
                : null,
            icon: Icon(
              Icons.arrow_forward_ios,
              color: _currentStudentIndex < studentResults.length - 1
                  ? AppColors.eLearningBtnColor1
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
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
    );
  }

  Widget _buildSubjectsTable(Map<String, dynamic> student) {
    final subjects = student['subjects'] as List;
    if (subjects.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No subjects available'),
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
            dividerThickness: 1,
            columns: [
              const DataColumn(
                label: Text(
                  'Subjects',
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
              const DataColumn(
                label: Text(
                  'Remark',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            rows: subjects.asMap().entries.map((entry) {
              final subject = entry.value;
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      subject['course_name']?.toString() ?? 'N/A',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  ...assessmentNames.map((assessmentName) {
                    final assessmentData = (subject['assessments'] as List).firstWhere(
                      (a) => a['assessment_name'] == assessmentName,
                      orElse: () => {'score': ''},
                    );
                    final currentScore = assessmentData['score']?.toString() ?? '';
                    return DataCell(
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          currentScore,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }),
                  DataCell(
                    Text(
                      subject['total_score']?.toString() ?? 'N/A',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  DataCell(
                    Text(
                      subject['grade']?.toString() ?? 'N/A',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(
                    Text(
                      subject['remark']?.toString() ?? 'N/A',
                      style: const TextStyle(fontSize: 14),
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

  Widget _buildCommentDisplay(Map<String, dynamic> student) {
    final comment = student['comment']?.toString() ?? '';
    if (comment.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Previous Comment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              comment,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Enter comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.eLearningBtnColor1),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(8.0),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              if (_commentController.text.isNotEmpty && _currentStudentIndex < studentResults.length) {
                submitComment(studentResults[_currentStudentIndex]['student_id']);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.eLearningBtnColor1,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:flutter_swiper_view/flutter_swiper_view.dart';
// import 'package:hive/hive.dart';
// import 'package:linkschool/config/env_config.dart';
// import 'package:linkschool/modules/auth/provider/auth_provider.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';
// import 'package:linkschool/modules/services/api/service_locator.dart';
// import 'package:provider/provider.dart';

// class CommentCourseResultScreen extends StatefulWidget {
//   final String classId;
//   final String year;
//   final String termName;
//   final int term;

//   const CommentCourseResultScreen({
//     super.key,
//     required this.classId,
//     required this.year,
//     required this.termName,
//     required this.term,
//   });

//   @override
//   State<CommentCourseResultScreen> createState() => _CommentCourseResultScreenState();
// }

// class _CommentCourseResultScreenState extends State<CommentCourseResultScreen> {
//   List<Map<String, dynamic>> studentResults = [];
//   List<String> assessmentNames = [];
//   bool isLoading = true;
//   String? error;
//   final TextEditingController _commentController = TextEditingController();
//   int _currentStudentIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     fetchStudentResults();
//   }

//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }

//   Future<void> fetchStudentResults() async {
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final apiService = locator<ApiService>();
//       final userBox = Hive.box('userData');
//       final levelId = userBox.get('currentLevelId')?.toString() ?? '66';
//       final role = userBox.get('role')?.toString() ?? 'admin';

//       if (authProvider.token != null) {
//         apiService.setAuthToken(authProvider.token!);
//       }

//       final dbName = EnvConfig.dbName;
//       final endpoint = 'portal/classes/${widget.classId}/students-result';
//       final queryParams = {
//         '_db': dbName,
//         'year': widget.year,
//         'term': widget.term.toString(),
//         'level_id': levelId,
//         'role': role,
//       };

//       print('Fetching student results from: $endpoint with params: $queryParams');

//       final response = await apiService.get(
//         endpoint: endpoint,
//         queryParams: queryParams,
//       );

//       if (response.success && response.rawData != null) {
//         final results = response.rawData!['response'] as List;
//         final uniqueAssessments = <String>{};

//         for (var student in results) {
//           for (var subject in student['subjects'] as List) {
//             for (var assessment in subject['assessments'] as List) {
//               uniqueAssessments.add(assessment['assessment_name'] as String);
//             }
//           }
//         }

//         setState(() {
//           studentResults = List<Map<String, dynamic>>.from(results);
//           assessmentNames = uniqueAssessments.toList();
//           isLoading = false;
//         });
//         print('Fetched ${studentResults.length} student results, ${assessmentNames.length} assessments');
//       } else {
//         setState(() {
//           error = response.message;
//           isLoading = false;
//         });
//         print('Failed to fetch results: ${response.message}');
//       }
//     } catch (e) {
//       setState(() {
//         error = 'Failed to load results: $e';
//         isLoading = false;
//       });
//       print('Error fetching results: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final brightness = Theme.of(context).brightness;
//     final opacity = brightness == Brightness.light ? 0.1 : 0.15;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Comment on Results',
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: AppColors.eLearningBtnColor1,
//           ),
//         ),
//         leading: IconButton(
//           onPressed: () => Navigator.of(context).pop(),
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
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: SizedBox.expand(
//         child: Container(
//           decoration: Constants.customBoxDecoration(context),
//           child: isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : error != null
//                   ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
//                   : Swiper(
//                       itemCount: studentResults.length,
//                       index: _currentStudentIndex,
//                       onIndexChanged: (index) {
//                         setState(() {
//                           _currentStudentIndex = index;
//                           _commentController.text = studentResults[index]['comment'] ?? '';
//                         });
//                       },
//                       itemBuilder: (context, index) {
//                         final student = studentResults[index];
//                         return SingleChildScrollView(
//                           child: Column(
//                             children: [
//                               _buildTermSection(student),
//                               _buildSubjectsTable(student),
//                               _buildCommentInput(student),
//                             ],
//                           ),
//                         );
//                       },
//                       pagination: const SwiperPagination(
//                         alignment: Alignment.topCenter,
//                         builder: DotSwiperPaginationBuilder(
//                           activeColor: AppColors.eLearningBtnColor1,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTermSection(Map<String, dynamic> student) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Student: ${student['student_name']}',
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: AppColors.primaryLight,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16.0),
//             decoration: const BoxDecoration(
//               border: Border(
//                 top: BorderSide(color: Colors.orange, width: 2),
//                 bottom: BorderSide(color: Colors.orange, width: 2),
//               ),
//             ),
//             child: Center(
//               child: Text(
//                 '${widget.year}/${int.parse(widget.year) + 1} ${widget.termName}',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.orange,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSubjectsTable(Map<String, dynamic> student) {
//     final subjects = student['subjects'] as List;
//     if (subjects.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Text('No subjects available'),
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Container(
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey[300]!),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: DataTable(
//             columnSpacing: 10,
//             headingRowHeight: 48,
//             dataRowHeight: 50,
//             headingRowColor: MaterialStateProperty.all(AppColors.eLearningBtnColor1),
//             dividerThickness: 1,
//             columns: [
//               const DataColumn(
//                 label: Text(
//                   'Subjects',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               ...assessmentNames.map((name) => DataColumn(
//                     label: Text(
//                       name,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white,
//                       ),
//                     ),
//                   )),
//               const DataColumn(
//                 label: Text(
//                   'Total',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               const DataColumn(
//                 label: Text(
//                   'Grade',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               const DataColumn(
//                 label: Text(
//                   'Remark',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//             rows: subjects.asMap().entries.map((entry) {
//               final subject = entry.value;
//               return DataRow(
//                 cells: [
//                   DataCell(
//                     Text(
//                       subject['course_name']?.toString() ?? 'N/A',
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   ),
//                   ...assessmentNames.map((assessmentName) {
//                     final assessmentData = (subject['assessments'] as List).firstWhere(
//                       (a) => a['assessment_name'] == assessmentName,
//                       orElse: () => {'score': ''},
//                     );
//                     final currentScore = assessmentData['score']?.toString() ?? '';
//                     return DataCell(
//                       Container(
//                         alignment: Alignment.center,
//                         child: Text(
//                           currentScore,
//                           style: const TextStyle(fontSize: 14),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     );
//                   }),
//                   DataCell(
//                     Text(
//                       subject['total_score']?.toString() ?? 'N/A',
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   ),
//                   DataCell(
//                     Text(
//                       subject['grade']?.toString() ?? 'N/A',
//                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                   DataCell(
//                     Text(
//                       subject['remark']?.toString() ?? 'N/A',
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   ),
//                 ],
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCommentInput(Map<String, dynamic> student) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Comment',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: AppColors.primaryLight,
//             ),
//           ),
//           const SizedBox(height: 8),
//           TextField(
//             controller: _commentController,
//             maxLines: 4,
//             decoration: InputDecoration(
//               hintText: 'Enter your comment here...',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: Colors.grey[300]!),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: const BorderSide(color: AppColors.eLearningBtnColor1),
//               ),
//               filled: true,
//               fillColor: Colors.white,
//               contentPadding: const EdgeInsets.all(12.0),
//             ),
//             style: const TextStyle(fontSize: 14),
//             onChanged: (value) {
//               // You can add logic to save the comment here if needed
//             },
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () {
//               // Implement comment submission logic here
//               print('Comment submitted for student ${student['student_id']}: ${_commentController.text}');
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.eLearningBtnColor1,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               'Submit Comment',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }