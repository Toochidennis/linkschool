import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:provider/provider.dart';

import '../../../../common/widgets/portal/class_detail/overlays.dart';
import '../../../../providers/admin/student_provider.dart';

class StudentList extends StatefulWidget {
  

  const StudentList({super.key, required });

  @override
  State createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<StudentProvider>(context, listen: false)
    //       .fetchStudents(widget.classId);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
        title: Text(
          'Student List',
          style: AppTextStyles.normal600(
            fontSize: 18,
            color: AppColors.primaryLight,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                fillColor: AppColors.dialogBtnColor,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide:
                      const BorderSide(color: AppColors.textFieldBorderLight),
                ),
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search...',
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
              onChanged: (value) {
                // Implement search functionality here if needed
              },
            ),
          ),
          Expanded(
            child: Consumer<StudentProvider>(
              builder: (context, studentProvider, child) {
                if (studentProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (studentProvider.errorMessage.isNotEmpty) {
                  return Center(
                    child: Text('Error: ${studentProvider.errorMessage}'),
                  );
                }

                return ListView.separated(
                  itemCount: studentProvider.students.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: AppColors.textFieldBorderLight,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final student = studentProvider.students[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      leading: CircleAvatar(
                        backgroundColor:
                            Colors.primaries[index % Colors.primaries.length],
                        child: Text(
                          student.name[0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        student.name,
                        style: AppTextStyles.normal500(
                            fontSize: 18, color: AppColors.textLight),
                      ),
                      onTap: () =>
                          showStudentResultOverlay(context, 
                             ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
