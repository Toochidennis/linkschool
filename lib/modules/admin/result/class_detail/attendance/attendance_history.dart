import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/attendance_app_bar.dart';
import 'package:linkschool/modules/model/admin/register_model.dart';
import 'package:linkschool/modules/providers/admin/attendance_provider.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'dart:math';


class AttendanceHistoryScreen extends StatefulWidget {
  final String date;
  final String? attendanceId;

  const AttendanceHistoryScreen({
    super.key,
    required this.date,
    this.attendanceId,
  });

  @override
  _AttendanceHistoryScreenState createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> with RouteAware {
  final colors = [AppColors.videoColor7, AppColors.attHistColor1];
  final random = Random();
  late List<bool> _isChecked;
  late List<bool> _isSelected;
  late double opacity;

  @override
  void initState() {
    super.initState();
    _isChecked = [];
    _isSelected = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAttendanceDetails();
    });
  }


  @override
  void didPopNext() {
    super.didPopNext();
    _fetchAttendanceDetails(); // refresh data automatically
  }

  Future<void> _fetchAttendanceDetails() async {
    final attendanceProvider = locator<AttendanceProvider>();
    final userBox = Hive.box('userData');
    final userData = userBox.get('userData');
    final dbName = userData?['_db'] ?? 'aalmgzmy_linkskoo_practice';

    if (widget.attendanceId != null) {
      await attendanceProvider.fetchAttendanceDetails(
        attendanceId: widget.attendanceId!,
        dbName: dbName,
      );
      final studentCount = attendanceProvider.attendanceDetails?.register?.length ?? 0;
      setState(() {
        _isChecked = List<bool>.filled(studentCount, true);
        _isSelected = List<bool>.filled(studentCount, false);
      });
    }
  }

  // ✅ Add pull-to-refresh to the list
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: const AttendanceAppBar(), // use your custom AppBar
      body: RefreshIndicator(
        onRefresh: _fetchAttendanceDetails,
        color: AppColors.primaryLight,
        child: Consumer<AttendanceProvider>(
          builder: (context, attendanceProvider, child) {
            if (attendanceProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (attendanceProvider.error.isNotEmpty) {
              return Center(child: Text('Error: ${attendanceProvider.error}'));
            }

            final students = attendanceProvider.attendanceDetails?.register ?? [];
            if (students.isEmpty) {
              return const Center(child: Text('No students found for this attendance.'));
            }

            return Container(
              decoration: Constants.customBoxDecoration(context),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final circleColor = colors[random.nextInt(colors.length)];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSelected[index] = !_isSelected[index];
                      });
                    },
                    child: Container(
                      color: _isSelected[index]
                          ? const Color.fromRGBO(239, 227, 255, 1)
                          : Colors.transparent,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: circleColor,
                                    child: Text(
                                      student.name[0],
                                      style: const TextStyle(color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    student.name,
                                    style: AppTextStyles.normal600(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isChecked[index]
                                        ? Icons.check_circle
                                        : Icons.check_circle_outline,
                                    color: _isChecked[index] ? Colors.green : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isChecked[index] = !_isChecked[index];
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: Colors.grey[300]),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}




