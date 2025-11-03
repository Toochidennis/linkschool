import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/providers/admin/course_registration_provider.dart';
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
                    // Filter students with courseCount > 0 for the total count
                    final activeStudents = provider.registeredCourses
                        .where((student) => (student.courseCount ?? 0) > 0)
                        .toList();
                    return Text(
                      'Total Students: ${activeStudents.length}',
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

        // Filter students with courseCount > 0
        final activeStudents = provider.registeredCourses
            .where((student) => (student.courseCount ?? 0) > 0)
            .toList();

        if (activeStudents.isEmpty) {
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
          itemCount: activeStudents.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final student = activeStudents[index];
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


