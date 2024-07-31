import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class TakeCourseAttendance extends StatefulWidget {
  @override
  State<TakeCourseAttendance> createState() => _TakeCourseAttendanceState();
}

class _TakeCourseAttendanceState extends State<TakeCourseAttendance> {
  List<bool> _selectedStudents = List.generate(12, (_) => false);
  bool _selectAll = false;

  final List<String> _studentNames = [
    'Alice Johnson',
    'Bob Smith',
    'Charlie Brown',
    'David Lee',
    'Emma Watson',
    'Frank Miller',
    'Grace Chen',
    'Henry Ford',
    'Ivy Zhang',
    'Jack Wilson',
    'Kate Taylor',
    'Liam Harris',
  ];

  final List<Color> _circleColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.brown,
    Colors.lime,
  ];

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      _selectedStudents = List.generate(12, (_) => _selectAll);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: Text(
          'Wednesday 20 July, 2024',
          style: AppTextStyles.normal500(
              fontSize: 18, color: AppColors.backgroundDark),
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
          GestureDetector(
            onTap: _toggleSelectAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                  color: AppColors.attBgColor1,
                  border: Border.all(color: AppColors.attBorderColor1)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select all students',
                    style: AppTextStyles.normal500(
                        fontSize: 16, color: AppColors.backgroundDark),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                        color: _selectAll ? AppColors.attCheckColor1 : AppColors.attBgColor1,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.attCheckColor1)),
                    child: Icon(
                      Icons.check,
                      color: _selectAll ? Colors.white : AppColors.attCheckColor1,
                      size: 16,
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: 12,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey[300],
                height: 1,
              ),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _circleColors[index],
                    child: Text(
                      _studentNames[index][0],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(_studentNames[index]),
                  trailing: _selectedStudents[index]
                      ? Icon(Icons.check_circle, color: AppColors.attCheckColor2)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedStudents[index] = !_selectedStudents[index];
                      _selectAll = _selectedStudents.every((element) => element);
                    });
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