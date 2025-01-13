import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class StudentList extends StatefulWidget {
  const StudentList({super.key});

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  final List<Map<String, dynamic>> students = [
    {'name': 'Toochi', 'color': Colors.red},
    {'name': 'Dennis', 'color': Colors.blue},
    {'name': 'Ifeanyi', 'color': Colors.green},
    {'name': 'Joseph', 'color': Colors.orange},
    {'name': 'Amaka', 'color': Colors.purple},
    {'name': 'Vincent', 'color': Colors.teal},
    {'name': 'Mitchel', 'color': Colors.pink},
    {'name': 'Victor', 'color': Colors.amber},
    {'name': 'Miriam', 'color': Colors.indigo},
    {'name': 'Raphael', 'color': Colors.cyan},
    {'name': 'Gloria', 'color': Colors.brown},
  ];

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
                  borderSide: const BorderSide(color: AppColors.textFieldBorderLight),
                ),
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search...',
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: students.length,
              separatorBuilder: (context, index) => const Divider(
                color: AppColors.textFieldBorderLight,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final student = students[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: student['color'],
                        child: Text(
                          student['name'][0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Text(student['name'], style: AppTextStyles.normal500(fontSize: 18, color: AppColors.textLight),),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}