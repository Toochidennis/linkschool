// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/dash_line.dart';
import 'package:linkschool/modules/portal/home/result/class_detail/attendance/attendance_history.dart';
import 'package:linkschool/modules/portal/home/result/class_detail/attendance/take_course_attendance.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final double cardWidth = 340;
  final double cardHeight = 200;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        elevation: 0,
        title: Text(
          'Attendance',
          style: AppTextStyles.normal600(
              fontSize: 20, color: AppColors.backgroundLight),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.backgroundLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/icons/result/search.svg',
              color: AppColors.backgroundLight,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.20,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
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
                    SizedBox(
                      width: 396,
                      height: 190,
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/result/study_book.svg',
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 22,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColors.videoColor4),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Third Term',
                                            style: AppTextStyles.normal600(
                                                fontSize: 12,
                                                color: AppColors.videoColor4),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'JSS2 A',
                                        style: AppTextStyles.normal600(
                                            fontSize: 22,
                                            color: AppColors.primaryLight),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '2015/2016 Academic session',
                                        style: AppTextStyles.normal500(
                                            fontSize: 14,
                                            color: AppColors.textGray),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const DashedLine(color: Colors.grey),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Text(
                                      'Date :',
                                      style: AppTextStyles.normal500(
                                          fontSize: 16,
                                          color: AppColors.textGray),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      '20 July, 2024',
                                      style: AppTextStyles.normal600(
                                          fontSize: 18,
                                          color: AppColors.primaryLight),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _showTakeAttendanceDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Take attendance',
                        style: AppTextStyles.normal600(
                            fontSize: 16, color: AppColors.backgroundLight),
                      ),
                    ),
                    const SizedBox(height: 44),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Attendance history',
                            style: AppTextStyles.normal600(fontSize: 18, color: AppColors.primaryLight),
                          ),
                          Text(
                            'See all',
                            style: AppTextStyles.normal600(fontSize: 14, color: AppColors.primaryLight),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      color: AppColors.backgroundLight,
                      height: 400, // Set a fixed height or adjust as needed
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: 8,
                        separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey[300],
                            indent: 16,
                            endIndent: 16),
                        itemBuilder: (context, index) {
                          final subjects = [
                            'English Language',
                            'Mathematics',
                            'Physics',
                            'Chemistry',
                            'Biology',
                            'History',
                            'Geography',
                            'Literature'
                          ];
                          final dates = [
                            'Thursday, 20 July, 2026',
                            'Friday, 21 July, 2026',
                            'Monday, 24 July, 2026',
                            'Tuesday, 25 July, 2026',
                            'Wednesday, 26 July, 2026',
                            'Thursday, 27 July, 2026',
                            'Friday, 28 July, 2026',
                            'Monday, 31 July, 2026'
                          ];
                          return ListTile(
                            leading: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check,
                                  color: Colors.white, size: 20),
                            ),
                            title: Text(dates[index]),
                            subtitle: Text(subjects[index],
                                style: const TextStyle(color: Colors.grey)),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AttendanceHistoryScreen(date: dates[index])));
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

void _showTakeAttendanceDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildAttendanceButton('Take class attendance', () {}),
            SizedBox(height: 16),
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
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Select course to take attendance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Column(
              children: [
                'Mathematics',
                'English',
                'Physics',
                'Chemistry',
                'Biology'
              ].map((subject) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildAttendanceButton(subject, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TakeCourseAttendance()));
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
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 3,
          offset: Offset(0, 2), // changes position of shadow
        ),
      ],
    ),
    child: Material(
      // color: Colors.transparent,
      color: AppColors.dialogBtnColor,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            // border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Container(
            width: double.infinity,
            height: 50,
            alignment: Alignment.center,
            child: Text(
              text,
              style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundDark),
            ),
          ),
        ),
      ),
    ),
  );
}

}
