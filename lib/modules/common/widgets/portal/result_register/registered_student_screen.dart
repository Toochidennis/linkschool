import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/providers/admin/course_registration_provider.dart';
import 'package:linkschool/modules/model/admin/course_registration_model.dart';
import 'package:provider/provider.dart';

class RegisteredStudentsScreen extends StatefulWidget {
  final int year;
  final int termValue;
  final String termName;
  final String classId;

  const RegisteredStudentsScreen({
    super.key,
    required this.year,
    required this.termValue,
    required this.termName,
    required this.classId,
  });

  @override
  State<RegisteredStudentsScreen> createState() => _RegisteredStudentsScreenState();
}

class _RegisteredStudentsScreenState extends State<RegisteredStudentsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the data when the screen loads
    _fetchRegisteredStudents();
  }

  Future<void> _fetchRegisteredStudents() async {
    // Use CourseRegistrationProvider to fetch registered students
    final provider = Provider.of<CourseRegistrationProvider>(context, listen: false);
    await provider.fetchRegisteredCourses(
      widget.classId,
      widget.termValue.toString(),
      widget.year.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registered Students',
          style: AppTextStyles.normal600(
            fontSize: 18,
            color: AppColors.backgroundDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.backgroundDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.year}/${widget.year + 1} - ${widget.termName}',
                  style: AppTextStyles.normal700(
                    fontSize: 18,
                    color: AppColors.backgroundDark,
                  ),
                ),
                Consumer<CourseRegistrationProvider>(
                  builder: (context, provider, _) {
                    return Text(
                      'Total Students: ${provider.registeredCourses.length}',
                      style: AppTextStyles.normal500(
                        fontSize: 14,
                        color: AppColors.regTextGray,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _buildStudentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    return Consumer<CourseRegistrationProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryLight,
            ),
          );
        }

        if (provider.registeredCourses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No registered students found for this term',
                  style: AppTextStyles.normal600(
                    fontSize: 16,
                    color: AppColors.regTextGray,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchRegisteredStudents,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                  ),
                  child: Text(
                    'Refresh',
                    style: AppTextStyles.normal600(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: provider.registeredCourses.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final student = provider.registeredCourses[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              title: Text(
                student.studentName ?? 'Unknown Student',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: AppColors.backgroundDark,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Courses: ${student.courseCount ?? 0}',
                  style: AppTextStyles.normal500(
                    fontSize: 14,
                    color: AppColors.regTextGray,
                  ),
                ),
              ),
              trailing: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.regBgColor1),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.primaryLight,
                ),
              ),
              onTap: () {
                // Handle student selection if needed
                // For example, navigate to student details page
              },
            );
          },
        );
      },
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';
// // import 'package:linkschool/modules/services/api_service.dart';

// class RegisteredStudentsScreen extends StatefulWidget {
//   final int year;
//   final int termValue;
//   final String termName;
//   final String classId;

//   const RegisteredStudentsScreen({
//     super.key,
//     required this.year,
//     required this.termValue,
//     required this.termName,
//     required this.classId,
//   });

//   @override
//   State<RegisteredStudentsScreen> createState() => _RegisteredStudentsScreenState();
// }

// class _RegisteredStudentsScreenState extends State<RegisteredStudentsScreen> {
//   final ApiService _apiService = ApiService();
//   bool _isLoading = true;
//   String _errorMessage = '';
//   List<Map<String, dynamic>> _registeredStudents = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchRegisteredStudents();
//   }

//   Future<void> _fetchRegisteredStudents() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       // Get the registered students for the selected term and year
//       final response = await _apiService.get(
//         endpoint: 'portal/classes/${widget.classId}/registered-students',
//         queryParams: {
//           '_db': 'aalmgzmy_linkskoo_practice',
//           'year': widget.year.toString(),
//           'term': widget.termValue.toString(),
//         },
//       );

//       if (response.success && response.rawData != null) {
//         final List<dynamic> studentsList = response.rawData!['registered_students'] ?? [];
        
//         // Convert to list of maps
//         setState(() {
//           _registeredStudents = studentsList.map((student) => {
//             'id': student['id'],
//             'student_name': student['student_name'],
//             'course_count': student['course_count'],
//           }).toList();
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _errorMessage = response.message;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load registered students: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Registered Students',
//           style: AppTextStyles.normal600(
//             fontSize: 18,
//             color: AppColors.backgroundDark,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColors.backgroundDark),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '${widget.year}/${widget.year + 1} - ${widget.termName}',
//                   style: AppTextStyles.normal700(
//                     fontSize: 18,
//                     color: AppColors.backgroundDark,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Total Students: ${_registeredStudents.length}',
//                   style: AppTextStyles.normal500(
//                     fontSize: 14,
//                     color: AppColors.regTextGray,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1),
//           Expanded(
//             child: _buildStudentsList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStudentsList() {
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(
//           color: AppColors.primaryLight,
//         ),
//       );
//     }

//     if (_errorMessage.isNotEmpty) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 _errorMessage,
//                 style: AppTextStyles.normal600(
//                   fontSize: 16,
//                   color: Colors.red,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _fetchRegisteredStudents,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryLight,
//                 ),
//                 child: Text(
//                   'Retry',
//                   style: AppTextStyles.normal600(
//                     fontSize: 14,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (_registeredStudents.isEmpty) {
//       return Center(
//         child: Text(
//           'No registered students found for this term',
//           style: AppTextStyles.normal600(
//             fontSize: 16,
//             color: AppColors.regTextGray,
//           ),
//         ),
//       );
//     }

//     return ListView.separated(
//       padding: const EdgeInsets.all(16),
//       itemCount: _registeredStudents.length,
//       separatorBuilder: (context, index) => const Divider(height: 1),
//       itemBuilder: (context, index) {
//         final student = _registeredStudents[index];
//         return ListTile(
//           contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//           title: Text(
//             student['student_name'] ?? 'Unknown Student',
//             style: AppTextStyles.normal600(
//               fontSize: 16,
//               color: AppColors.backgroundDark,
//             ),
//           ),
//           subtitle: Padding(
//             padding: const EdgeInsets.only(top: 8.0),
//             child: Text(
//               'Courses: ${student['course_count'] ?? 0}',
//               style: AppTextStyles.normal500(
//                 fontSize: 14,
//                 color: AppColors.regTextGray,
//               ),
//             ),
//           ),
//           trailing: Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: AppColors.backgroundLight,
//               borderRadius: BorderRadius.circular(18),
//               border: Border.all(color: AppColors.regBgColor1),
//             ),
//             child: const Icon(
//               Icons.arrow_forward_ios,
//               size: 14,
//               color: AppColors.primaryLight,
//             ),
//           ),
//           onTap: () {
//             // Handle student selection if needed
//             // For example, navigate to student details page
//           },
//         );
//       },
//     );
//   }
// }