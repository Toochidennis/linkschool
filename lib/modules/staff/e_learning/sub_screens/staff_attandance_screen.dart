import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/attendance_history_header.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/attendance_history_list.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/info_card.dart';
import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_class_attendance_screen.dart';
import 'package:linkschool/modules/staff/home/staff_take_attandance_screen.dart';

class StaffAttandanceScreen extends StatefulWidget {
  final String classId;
  final String? courseId;
  final String className;
  final String? courseName;
  final bool isFromFormClasses;

  const StaffAttandanceScreen({
    super.key,
    required this.classId,
    required this.className,
    this.courseId,
    this.courseName,
    this.isFromFormClasses = false,
  });

  @override
  State<StaffAttandanceScreen> createState() => _StaffAttandanceScreenState();
}

class _StaffAttandanceScreenState extends State<StaffAttandanceScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<AttendanceHistoryListState> _attendanceHistoryKey = GlobalKey();

  // Add a refresh counter to force rebuild of the entire widget tree
  int _refreshCounter = 0;

  Future<void> _handleRefresh() async {
    // This will refresh the entire page by forcing a rebuild
    setState(() {
      _refreshCounter++;
    });

    // Also refresh the AttendanceHistoryList specifically
    if (_attendanceHistoryKey.currentState != null) {
      await _attendanceHistoryKey.currentState!.refreshData();
    }

    // You can add other refresh logic here for other components
    // For example, refresh InfoCard data, etc.
    
    // Simulate a delay for better UX
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  void _refreshAfterAttendance() {
    // Refresh after taking attendance
    _handleRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: AppColors.paymentTxtColor1,
        elevation: 0,
        title: Text(
          'Attendance',
          style: AppTextStyles.normal600(
              fontSize: 20, color: AppColors.backgroundLight),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.backgroundLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        actions: [
          // Add refresh button in app bar
          IconButton(
            onPressed: () {
              _refreshIndicatorKey.currentState?.show();
            },
            icon: const Icon(Icons.refresh, color: AppColors.backgroundLight),
          ),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/icons/result/search.svg',
              color: AppColors.backgroundLight,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.20,
                decoration: const BoxDecoration(
                  color: AppColors.paymentTxtColor1,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -MediaQuery.of(context).size.height * 0.15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Add key to InfoCard to force rebuild on refresh
                      InfoCard(
                        key: ValueKey('info_card_$_refreshCounter'),
                        className: widget.className, 
                        classId: widget.classId
                      ),
                      const SizedBox(height: 20),
                      CustomLongElevatedButton(
                        text: 'Take attendance',
                        onPressed: () => _showTakeAttendanceDialog(context),
                        backgroundColor: AppColors.videoColor4,
                        textStyle: AppTextStyles.normal600(
                            fontSize: 16, color: AppColors.backgroundLight),
                      ),
                      const SizedBox(height: 44),
                      // Add key to AttendanceHistoryHeader to force rebuild
                      AttendanceHistoryHeader(key: ValueKey('header_$_refreshCounter')),
                      const SizedBox(height: 16),
                      AttendanceHistoryList(
                        key: _attendanceHistoryKey,
                        classId: widget.classId,
                        onRefresh: _refreshAfterAttendance,
                      ),
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

  void _showTakeAttendanceDialog(BuildContext context) {
    if (widget.isFromFormClasses) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildAttendanceButton('Take class attendance', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StaffTakeClassAttendance(
                        classId: widget.classId,
                        className: widget.className,
                      ),
                    ),
                  ).then((_) {
                    // Refresh entire page when returning from attendance
                    _refreshAfterAttendance();
                  });
                }),
                const SizedBox(height: 16),
                // _buildAttendanceButton('Take course attendance', () {
                //   Navigator.pop(context);
                //   _showSelectCourseDialog(context);
                // }),
              ],
            ),
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StaffTakeAttendanceScreen(
            classId: widget.classId,
            courseId: widget.courseId!,
            className: widget.className,
            courseName: widget.courseName!,
          ),
        ),
      ).then((_) {
        // Refresh entire page when returning from attendance
        _refreshAfterAttendance();
      });
    }
  }

  void _showSelectCourseDialog(BuildContext context) {
    final userDataBox = Hive.box('userData');
    final userData = userDataBox.get('userData');
    final List<dynamic> staffCourses = userData?['data']['courses'] ?? [];
    final filteredCourses = staffCourses
        .where((courseData) => courseData['class_id'].toString() == widget.classId)
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Select course to take attendance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: filteredCourses.map<Widget>((courseData) {
                      final courseId = courseData['courses'][0]['course_id'].toString();
                      final courseName = courseData['courses'][0]['course_name'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildAttendanceButton(courseName, () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StaffTakeAttendanceScreen(
                                classId: widget.classId,
                                courseId: courseId,
                                className: widget.className,
                                courseName: courseName,
                              ),
                            ),
                          ).then((_) {
                            // Refresh entire page when returning from attendance
                            _refreshAfterAttendance();
                          });
                        }),
                      );
                    }).toList(),
                  ),
                ),
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
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2))
        ],
      ),
      child: Material(
        color: AppColors.dialogBtnColor,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Ink(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              child: Text(text,
                  style: AppTextStyles.normal600(
                      fontSize: 16, color: AppColors.backgroundDark)),
            ),
          ),
        ),
      ),
    );
  }
}