import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/portal/home/result/class_detail/attendance/attendance_history.dart';

class AttendanceHistoryList extends StatelessWidget {
  final List<String> subjects = ['English Language', 'Mathematics', 'Physics', 'Chemistry', 'Biology', 'History', 'Geography', 'Literature'];
  final List<String> dates = ['Thursday, 20 July, 2026', 'Friday, 21 July, 2026', 'Monday, 24 July, 2026', 'Tuesday, 25 July, 2026', 'Wednesday, 26 July, 2026', 'Thursday, 27 July, 2026', 'Friday, 28 July, 2026', 'Monday, 31 July, 2026'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.backgroundLight,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 8,
          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300], indent: 16, endIndent: 16),
          itemBuilder: (context, index) => _buildAttendanceHistoryItem(context, index),
        ),
      ),
    );
  }

  Widget _buildAttendanceHistoryItem(BuildContext context, int index) {
    return ListTile(
      leading: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
        child: const Icon(Icons.check, color: Colors.white, size: 20),
      ),
      title: Text(dates[index]),
      subtitle: Text(subjects[index], style: const TextStyle(color: Colors.grey)),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AttendanceHistoryScreen(date: dates[index]))),
    );
  }
}