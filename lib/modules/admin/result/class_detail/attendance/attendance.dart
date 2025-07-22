import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/attendance_app_bar.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/attendance_history_header.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/attendance_history_list.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/header_container.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/info_card.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/take_attendance_button.dart';
import 'package:linkschool/modules/providers/admin/attendance_provider.dart';
import 'package:provider/provider.dart';

class AttendanceScreen extends StatelessWidget {
  final String className;
  final String classId;
  
  const AttendanceScreen({
    super.key, 
    required this.className, 
    required this.classId
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Provider.of<AttendanceProvider>(context, listen: false),
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AttendanceAppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              HeaderContainer(),
              Transform.translate(
                offset: Offset(0, -MediaQuery.of(context).size.height * 0.15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      InfoCard(className: className, classId: classId),
                      const SizedBox(height: 20),
                      TakeAttendanceButton(classId: classId),
                      const SizedBox(height: 44),
                      AttendanceHistoryHeader(),
                      const SizedBox(height: 16),
                      AttendanceHistoryList(classId: classId),
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
}