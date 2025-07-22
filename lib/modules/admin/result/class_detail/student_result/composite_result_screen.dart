import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:provider/provider.dart';

// Screen for displaying composite results
class CompositeResultScreen extends StatefulWidget {
  final String classId;
  final String year;
  final String termName;
  final int termId;

  const CompositeResultScreen({
    super.key,
    required this.classId,
    required this.year,
    required this.termName,
    required this.termId,
  });

  @override
  State<CompositeResultScreen> createState() => _CompositeResultScreenState();
}

class _CompositeResultScreenState extends State<CompositeResultScreen> {
  List<Map<String, dynamic>> studentResults = [];
  List<Map<String, dynamic>> subjects = [];
  bool isLoading = true;
  String? error;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _initializeUserRole();
    fetchCompositeResults();
  }

  // Initialize user role from Hive storage
  void _initializeUserRole() {
    final userBox = Hive.box('userData');
    userRole = userBox.get('role')?.toString() ?? 'admin';
  }

  // Fetch composite results from API
  Future<void> fetchCompositeResults() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = locator<ApiService>();
      final userBox = Hive.box('userData');
      final levelId = userBox.get('currentLevelId')?.toString() ?? '66';

      if (authProvider.token != null) {
        apiService.setAuthToken(authProvider.token!);
      }

      final dbName = EnvConfig.dbName;
      final endpoint = 'portal/classes/${widget.classId}/composite-result';
      final queryParams = {
        '_db': dbName,
        'year': widget.year,
        'term': widget.termId.toString(),
        'level_id': levelId,
      };

      final response = await apiService.get(
        endpoint: endpoint,
        queryParams: queryParams,
      );

      if (response.success && response.rawData != null) {
        final responseData = response.rawData!['response'];
        setState(() {
          subjects = List<Map<String, dynamic>>.from(responseData['subjects']);
          studentResults = List<Map<String, dynamic>>.from(responseData['students']);
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
        error = 'Failed to load composite results: $e';
        isLoading = false;
      });
    }
  }

  // Helper function to format position with ordinal suffix
  String _formatPosition(dynamic position) {
    if (position == null) return 'N/A';
    final int pos = int.tryParse(position.toString()) ?? 0;
    if (pos == 0) return 'N/A';
    
    String suffix;
    switch (pos % 10) {
      case 1:
        suffix = pos % 100 == 11 ? 'th' : 'st';
        break;
      case 2:
        suffix = pos % 100 == 12 ? 'th' : 'nd';
        break;
      case 3:
        suffix = pos % 100 == 13 ? 'th' : 'rd';
        break;
      default:
        suffix = 'th';
    }
    return '$pos$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Composite Results',
          style: TextStyle(
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
      body: SafeArea(
        child: Container(
          decoration: Constants.customBoxDecoration(context),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
                  : Column(
                      children: [
                        // Term information card
                        _buildTermCard(),
                        // Composite results table
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildCompositeTable(),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  // Build card containing term information
  Widget _buildTermCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
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
        ),
      ),
    );
  }

  // Build composite results table with layout matching StaffSkillsBehaviourScreen
  Widget _buildCompositeTable() {
    if (studentResults.isEmpty || subjects.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No data available', style: TextStyle(color: Colors.black)),
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
                    ...subjects
                        .asMap()
                        .entries
                        .map((entry) => _buildScrollableColumn(
                              entry.value['abbr'] ?? 'N/A',
                              100,
                              entry.key,
                              isSubject: true,
                            ))
                        .toList(),
                    _buildScrollableColumn('Total', 100, -1, isTotal: true),
                    _buildScrollableColumn('Average', 100, -2, isAverage: true),
                    _buildScrollableColumn('Position', 100, -3, isPosition: true),
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
        color: Colors.blue[400],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            alignment: Alignment.center,
            child: const Text(
              'Students',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...studentResults.map((stud) {
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
                  stud['student_name']?.toString() ?? 'N/A',
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

  // Build scrollable column for subjects, total, average, or position
  Widget _buildScrollableColumn(String title, double width, int index,
      {bool isSubject = false, bool isTotal = false, bool isAverage = false, bool isPosition = false}) {
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
          ...studentResults.map((stud) {
            String value = '-';
            if (isSubject) {
              final courseId = subjects[index]['course_id'].toString();
              value = stud['subjects'][courseId]?.toString() ?? '-';
            } else if (isTotal) {
              value = stud['total_score']?.toString() ?? '0';
            } else if (isAverage) {
              value = stud['avg_score']?.toString() ?? '0';
            } else if (isPosition) {
              value = _formatPosition(stud['position']);
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
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            );
          }),
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

// // Screen for displaying composite results
// class CompositeResultScreen extends StatefulWidget {
//   final String classId;
//   final String year;
//   final String termName;
//   final int termId;

//   const CompositeResultScreen({
//     super.key,
//     required this.classId,
//     required this.year,
//     required this.termName,
//     required this.termId,
//   });

//   @override
//   State<CompositeResultScreen> createState() => _CompositeResultScreenState();
// }

// class _CompositeResultScreenState extends State<CompositeResultScreen> {
//   List<Map<String, dynamic>> studentResults = [];
//   List<Map<String, dynamic>> subjects = [];
//   bool isLoading = true;
//   String? error;
//   int _currentStudentIndex = 0;
//   final SwiperController _swiperController = SwiperController();
//   String? userRole;

//   @override
//   void initState() {
//     super.initState();
//     _initializeUserRole();
//     fetchCompositeResults();
//   }

//   @override
//   void dispose() {
//     _swiperController.dispose();
//     super.dispose();
//   }

//   // Initialize user role from Hive storage
//   void _initializeUserRole() {
//     final userBox = Hive.box('userData');
//     userRole = userBox.get('role')?.toString() ?? 'admin';
//   }

//   // Fetch composite results from API
//   Future<void> fetchCompositeResults() async {
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final apiService = locator<ApiService>();
//       final userBox = Hive.box('userData');
//       final levelId = userBox.get('currentLevelId')?.toString() ?? '66';

//       if (authProvider.token != null) {
//         apiService.setAuthToken(authProvider.token!);
//       }

//       final dbName = EnvConfig.dbName;
//       final endpoint = 'portal/classes/${widget.classId}/composite-result';
//       final queryParams = {
//         '_db': dbName,
//         'year': widget.year,
//         'term': widget.termId.toString(),
//         'level_id': levelId,
//       };

//       final response = await apiService.get(
//         endpoint: endpoint,
//         queryParams: queryParams,
//       );

//       if (response.success && response.rawData != null) {
//         final responseData = response.rawData!['response'];
//         setState(() {
//           subjects = List<Map<String, dynamic>>.from(responseData['subjects']);
//           studentResults = List<Map<String, dynamic>>.from(responseData['students']);
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           error = response.message;
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         error = 'Failed to load composite results: $e';
//         isLoading = false;
//       });
//     }
//   }

//   // Helper function to format position with ordinal suffix
//   String _formatPosition(dynamic position) {
//     if (position == null) return 'N/A';
//     final int pos = int.tryParse(position.toString()) ?? 0;
//     if (pos == 0) return 'N/A';
    
//     String suffix;
//     switch (pos % 10) {
//       case 1:
//         suffix = pos % 100 == 11 ? 'th' : 'st';
//         break;
//       case 2:
//         suffix = pos % 100 == 12 ? 'th' : 'nd';
//         break;
//       case 3:
//         suffix = pos % 100 == 13 ? 'th' : 'rd';
//         break;
//       default:
//         suffix = 'th';
//     }
//     return '$pos$suffix';
//   }

//   // Handle swiper index change
//   void _onSwiperIndexChanged(int index) {
//     setState(() {
//       _currentStudentIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final brightness = Theme.of(context).brightness;
//     final opacity = brightness == Brightness.light ? 0.1 : 0.15;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Composite Results',
//           style: TextStyle(
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
//       body: SafeArea(
//         child: Container(
//           decoration: Constants.customBoxDecoration(context),
//           child: isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : error != null
//                   ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
//                   : Column(
//                       children: [
//                         // Student and term card
//                         _buildStudentTermCard(),
//                         Expanded(
//                           child: Swiper(
//                             controller: _swiperController,
//                             itemCount: studentResults.length,
//                             index: _currentStudentIndex,
//                             onIndexChanged: _onSwiperIndexChanged,
//                             loop: false,
//                             itemBuilder: (context, index) {
//                               final student = studentResults[index];
//                               return SingleChildScrollView(
//                                 child: Column(
//                                   children: [
//                                     _buildCompositeTable(student),
//                                     const SizedBox(height: 16),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//         ),
//       ),
//     );
//   }

//   // Build card containing student and term information
//   Widget _buildStudentTermCard() {
//     if (studentResults.isEmpty) {
//       return const SizedBox.shrink();
//     }
//     final student = studentResults[_currentStudentIndex];
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   IconButton(
//                     onPressed: _currentStudentIndex > 0
//                         ? () => _swiperController.previous(animation: true)
//                         : null,
//                     icon: Icon(
//                       Icons.arrow_back_ios,
//                       color: _currentStudentIndex > 0 ? AppColors.eLearningBtnColor1 : Colors.grey,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 16,
//                         backgroundColor: Colors.primaries[_currentStudentIndex % Colors.primaries.length],
//                         child: Text(
//                           student['student_name']?.isNotEmpty == true
//                               ? student['student_name'][0].toUpperCase()
//                               : 'S',
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         student['student_name'] ?? 'N/A',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//                   IconButton(
//                     onPressed: _currentStudentIndex < studentResults.length - 1
//                         ? () => _swiperController.next(animation: true)
//                         : null,
//                     icon: Icon(
//                       Icons.arrow_forward_ios,
//                       color: _currentStudentIndex < studentResults.length - 1
//                           ? AppColors.eLearningBtnColor1
//                           : Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12.0),
//                 decoration: const BoxDecoration(
//                   border: Border(
//                     top: BorderSide(color: Colors.orange, width: 2),
//                     bottom: BorderSide(color: Colors.orange, width: 2),
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '${widget.year}/${int.parse(widget.year) + 1} ${widget.termName}',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.orange,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Build composite results table with layout matching StaffSkillsBehaviourScreen
//   Widget _buildCompositeTable(Map<String, dynamic> student) {
//     if (studentResults.isEmpty || subjects.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Text('No data available', style: TextStyle(color: Colors.black)),
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Container(
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey[300]!),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           children: [
//             _buildStudentColumn(),
//             Expanded(
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     ...subjects
//                         .asMap()
//                         .entries
//                         .map((entry) => _buildScrollableColumn(
//                               entry.value['abbr'] ?? 'N/A',
//                               100,
//                               entry.key,
//                               isSubject: true,
//                             ))
//                         .toList(),
//                     _buildScrollableColumn('Total', 100, -1, isTotal: true),
//                     _buildScrollableColumn('Average', 100, -2, isAverage: true),
//                     _buildScrollableColumn('Position', 100, -3, isPosition: true),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Build fixed student column
//   Widget _buildStudentColumn() {
//     return Container(
//       width: 120,
//       decoration: BoxDecoration(
//         color: Colors.blue[400],
//         borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             height: 48,
//             alignment: Alignment.center,
//             child: const Text(
//               'Students',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           ...studentResults.map((stud) {
//             return Container(
//               height: 50,
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 border: Border(
//                   top: BorderSide(color: Colors.grey[300]!),
//                   right: BorderSide(color: Colors.grey[300]!),
//                 ),
//               ),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   stud['student_name']?.toString() ?? 'N/A',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   // Build scrollable column for subjects, total, average, or position
//   Widget _buildScrollableColumn(String title, double width, int index,
//       {bool isSubject = false, bool isTotal = false, bool isAverage = false, bool isPosition = false}) {
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
//           ...studentResults.map((stud) {
//             String value = '-';
//             if (isSubject) {
//               final courseId = subjects[index]['course_id'].toString();
//               value = stud['subjects'][courseId]?.toString() ?? '-';
//             } else if (isTotal) {
//               value = stud['total_score']?.toString() ?? '0';
//             } else if (isAverage) {
//               value = stud['avg_score']?.toString() ?? '0';
//             } else if (isPosition) {
//               value = _formatPosition(stud['position']);
//             }
//             return Container(
//               height: 50,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 border: Border(
//                   top: BorderSide(color: Colors.grey[300]!),
//                   right: BorderSide(color: Colors.grey[300]!),
//                 ),
//               ),
//               child: Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: Colors.black,
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }