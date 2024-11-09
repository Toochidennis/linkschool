import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/admin_portal/result/class_detail/attendance/take_course_attendance.dart';


class TakeAttendanceButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomLongElevatedButton(
      text: 'Take attendance',
      onPressed: () => _showTakeAttendanceDialog(context),
      backgroundColor: AppColors.videoColor4,
      textStyle: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundLight),
    );
  }

  void _showTakeAttendanceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildAttendanceButton('Take class attendance', () {}),
              const SizedBox(height: 16),
              _buildAttendanceButton('Take course attendance', () {
                Navigator.pop(context);
                _showSelectCourseDialog(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSelectCourseDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Select course to take attendance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Column(
                children: ['Mathematics', 'English', 'Physics', 'Chemistry', 'Biology'].map((subject) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildAttendanceButton(subject, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TakeCourseAttendance()));
                    }),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: AppColors.dialogBtnColor,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Ink(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              child: Text(text, style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundDark)),
            ),
          ),
        ),
      ),
    );
  }
}