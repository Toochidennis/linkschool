// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/portal/home/result/class_detail/attendance/attendance.dart';
import 'package:linkschool/modules/portal/home/result/class_detail/registration/registration.dart';
import 'package:linkschool/modules/portal/home/result/class_detail/student_result/course_result_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/portal/home/result/class_detail/student_result/student_result.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/text_styles.dart';

class ClassDetailScreen extends StatelessWidget {
  final String className;

  const ClassDetailScreen({Key? key, required this.className})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          className,
          style: AppTextStyles.normal600(fontSize: 18.0, color: Colors.black),
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
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13.0),
            child: SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text(
                  'See class list',
                  style: AppTextStyles.normal700(
                    fontSize: 14,
                    color: AppColors.backgroundLight,
                  ),
                ),
              ),
            ),
          ),
        ],
        backgroundColor: AppColors.bgColor1,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.bgColor1,
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 15.0)),
                SliverToBoxAdapter(
                  child: Container(
                    height: 250,
                    width: 196,
                    color: AppColors.bgColor1,
                    child: AspectRatio(
                      aspectRatio: 2.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: BarChart(
                          BarChartData(
                            maxY: 100,
                            titlesData: FlTitlesData(
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 42,
                                  getTitlesWidget: getTitles,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget: _leftTitles,
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 20,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.black.withOpacity(0.3),
                                  strokeWidth: 1,
                                  dashArray: [5, 5],
                                );
                              },
                              checkToShowHorizontalLine: (value) =>
                                  value % 20 == 0,
                            ),
                            barGroups: [
                              _buildBarGroup(0, 60, AppColors.primaryLight),
                              _buildBarGroup(1, 25, AppColors.videoColor4),
                              _buildBarGroup(2, 75, AppColors.primaryLight),
                              _buildBarGroup(3, 60, AppColors.primaryLight),
                              _buildBarGroup(4, 25, AppColors.videoColor4),
                              _buildBarGroup(5, 75, AppColors.primaryLight),
                              _buildBarGroup(6, 75, AppColors.primaryLight),
                            ],
                            groupsSpace: 22.44,
                          ),
                          swapAnimationCurve: Curves.linear,
                          swapAnimationDuration:
                              const Duration(microseconds: 500),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    width: 360,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, -1),
                          blurRadius: 4,
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: exploreButtonItem(
                                  backgroundColor: AppColors.bgXplore1,
                                  label: 'Student Result',
                                  iconPath: 'assets/icons/result/assessment_icon.svg',
                                  onTap: () =>
                                      _showStudentResultOverlay(context),
                                ),
                              ),
                              Expanded(
                                child: exploreButtonItem(
                                  backgroundColor: AppColors.bgXplore2,
                                  label: 'Registration',
                                  iconPath: 'assets/icons/result/registration_icon.svg',
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RegistrationScreen()));
                                  },
                                ),
                              ),
                              Expanded(
                                child: exploreButtonItem(
                                  backgroundColor:
                                      AppColors.bgXplore3,
                                  label: 'Attendance',
                                  iconPath: 'assets/icons/result/attendance_icon.svg',
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (contex) =>
                                                AttendanceScreen()));
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '2015/2016 Session',
                                style: AppTextStyles.normal700(
                                    fontSize: 18,
                                    color: AppColors.primaryLight),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildTermRow(
                            'First Term',
                            0.75,
                            AppColors.primaryLight,
                            onTap: () =>
                                _showTermOverlay(context,),
                          ),
                          _buildTermRow(
                            'Second Term',
                            0.75,
                            AppColors.videoColor4,
                            onTap: () =>
                                _showTermOverlay(context,),
                          ),
                          _buildTermRow(
                            'Third Term',
                            0.75,
                            AppColors.classProgressBar1,
                            onTap: () =>
                                _showTermOverlay(context,),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '2016/2017 Session',
                                style: AppTextStyles.normal700(
                                    fontSize: 18,
                                    color: AppColors.primaryLight),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildTermRow(
                            'First Term',
                            0.75,
                            AppColors.primaryLight,
                            onTap: () =>
                                _showTermOverlay(context,),
                          ),
                          _buildTermRow(
                            'Second Term',
                            0.75,
                            AppColors.videoColor4,
                            onTap: () =>
                                _showTermOverlay(context,),
                          ),
                          _buildTermRow(
                            'Third Term',
                            0.75,
                            AppColors.classProgressBar1,
                            onTap: () =>
                                _showTermOverlay(context,),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20.46,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        )
      ],
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const subjects = ['Math', 'Eng', 'Chem', 'Bio', 'Phy', 'CRS', 'Civic'];
    final index = value.toInt();
    if (index >= 0 && index < subjects.length) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 4.0,
        child: Text(
          subjects[index],
          style: AppTextStyles.normal400(fontSize: 12, color: Colors.black),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10, color: AppColors.barTextGray);
    String text;
    switch (value.toInt()) {
      case 0:
        text = '00';
        break;
      case 20:
        text = '20';
        break;
      case 40:
        text = '40';
        break;
      case 60:
        text = '60';
        break;
      case 80:
        text = '80';
        break;
      case 100:
        text = '100';
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(text, style: style, textAlign: TextAlign.right),
    );
  }

  Widget exploreButtonItem({
    required Color backgroundColor,
    required String label,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(
            top: 30.0, bottom: 15.0, left: 6, right: 8),
        child: Container(
          width: 110,
          height: 80,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
              BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  offset: const Offset(0, -1),
                  blurRadius: 4),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconPath,
                width: 25,
                height: 25,
                color: AppColors.backgroundLight,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.backgroundLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermRow(String term, double percent, Color indicatorColor,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 75,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderGray, width: 1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                term,
                style:
                    AppTextStyles.normal700(fontSize: 14, color: Colors.black),
              ),
              CircularPercentIndicator(
                radius: 20.0,
                lineWidth: 4.92,
                percent: percent,
                center: Text(
                  "${(percent * 100).toInt()}%",
                  style: AppTextStyles.normal600(
                      fontSize: 10, color: Colors.black),
                ),
                progressColor: indicatorColor,
                backgroundColor: Colors.transparent,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentResultOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.5,
            builder: (_, controller) {
              return GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          controller: controller,
                          itemCount: 4,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final studentNames = [
                              'Tochukwu Dennis',
                              'Vincent Rapheal',
                              'Victor Anya',
                              'Joseph onwe'
                            ];
                            final studentName = studentNames[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors
                                    .primaries[index % Colors.primaries.length],
                                child: Text(
                                  studentName[0],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(studentName),
                              onTap: () {
                                Navigator.pop(context); // Close the bottom sheet
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudentResultScreen(
                                      studentName: studentName,
                                      className: 'Student Result',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

void _showTermOverlay(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.4, // Fixed height
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                  itemCount: 4,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final icons = [
                      'assets/icons/result/comment.svg',
                      'assets/icons/result/skill.svg',
                      'assets/icons/result/course.svg',
                      'assets/icons/result/composite_result.svg',
                    ];
                    final labels = [
                      'Comment on results',
                      'Skills and Behaviour',
                      'Course result',
                      'Composite result',
                    ];
                    final colors = [
                      AppColors.bgColor2,
                      AppColors.bgColor3,
                      AppColors.bgColor4,
                      AppColors.bgColor5,
                    ];
                    final iconColors = [
                      AppColors.iconColor1,
                      AppColors.iconColor2,
                      AppColors.iconColor3,
                      AppColors.iconColor4,
                    ];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors[index],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            icons[index],
                            color: iconColors[index],
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      title: Text(labels[index]),
                      onTap: () {
                        if (labels[index] == 'Course result') {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseResultScreen(),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
}
