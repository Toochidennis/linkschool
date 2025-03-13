import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button_2.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
import 'package:linkschool/modules/student/home/new_post_dialog.dart';
import 'package:linkschool/modules/student/result/student_annual_result_screen.dart';
import 'package:linkschool/modules/student/result/student_term_result_screen.dart';

import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

class StudentResultScreen extends StatefulWidget {
  final String studentName;
  final String className;
  const StudentResultScreen({
    super.key,
    required this.studentName,
    required this.className,

  });

  @override
  State<StudentResultScreen> createState() => _StudentResultScreenState();
}

class _StudentResultScreenState extends State<StudentResultScreen> {
  late double opacity;

  void _showNewPostDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NewPostDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: CustomStudentAppBar(
        title: 'Welcome',
        subtitle: 'Tochukwu',
        showNotification: true,
        // showPostInput: true,
        onNotificationTap: () {},
        // onPostTap: _showNewPostDialog,
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: SingleChildScrollView(
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2015/2016 Session',
                      style: AppTextStyles.normal700(
                          fontSize: 18, color: AppColors.paymentTxtColor1),
                    ),
                    const SizedBox(height: 10),
                    _buildTermRow(
                        'First Term', 0.75, AppColors.paymentTxtColor1),
                    _buildTermRow('Second Term', 0.75, AppColors.videoColor4),
                    _buildTermRow(
                        'Third Term', 0.75, AppColors.exploreButton3Light),
                    const SizedBox(height: 30),
                    CustomOutlineButton2(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const StudentAnnualResultScreen(),
                          ),
                        );
                      },
                      text: 'See annual result',
                      borderColor: AppColors.paymentTxtColor1,
                      textColor: AppColors.paymentTxtColor1,
                      fontSize: 18,
                      borderRadius: 10.0,
                      buttonHeight: 48,
                    ),

                    // OutlinedButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) =>
                    //             const StudentAnnualResultScreen(),
                    //       ),
                    //     );
                    //   },
                    //   style: OutlinedButton.styleFrom(
                    //       side: const BorderSide(
                    //           color: AppColors.paymentTxtColor1),
                    //       minimumSize: const Size(double.infinity, 48),
                    //       shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(10.0))),
                    //   child: Text(
                    //     'See annual result',
                    //     style: AppTextStyles.normal600(
                    //       fontSize: 18,
                    //       color: AppColors.paymentTxtColor1,
                    //     ),
                    //   ),
                    // ),
                    SizedBox(
                      height: 60,
                    ),
                    Text(
                      'Session average chart',
                      style: AppTextStyles.normal700(
                        fontSize: 18,
                        color: AppColors.paymentTxtColor1,
                      ),
                    ),
                    const SizedBox(height: 40.0), // Increased from 15.0 to 30.0
                    SizedBox(
                      height: 200.0,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceEvenly,
                          maxY: 100,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value,
                                        TitleMeta meta) =>
                                    getTitles(value, meta), // Pass `meta` here
                                reservedSize: 38,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) => Text(
                                  value.toInt().toString(),
                                  style: AppTextStyles.normal400(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          // titlesData: FlTitlesData(
                          //   show: true,
                          //   bottomTitles: AxisTitles(
                          //     sideTitles: SideTitles(
                          //       showTitles: true,
                          //       getTitlesWidget: getTitles,
                          //       reservedSize: 38,
                          //     ),
                          //   ),
                          //   leftTitles: AxisTitles(
                          //     sideTitles: SideTitles(
                          //       showTitles: true,
                          //       reservedSize: 40,
                          //       getTitlesWidget: (value, meta) => Text(
                          //         value.toInt().toString(),
                          //         style: AppTextStyles.normal400(
                          //             color: Colors.black, fontSize: 12),
                          //       ),
                          //     ),
                          //   ),
                          //   topTitles: const AxisTitles(
                          //       sideTitles: SideTitles(showTitles: false)),
                          //   rightTitles: const AxisTitles(
                          //       sideTitles: SideTitles(showTitles: false)),
                          // ),
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
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            _buildBarGroup(0, 60, AppColors.paymentTxtColor1),
                            _buildBarGroup(1, 25, AppColors.videoColor4),
                            _buildBarGroup(2, 75, AppColors.paymentTxtColor1),
                          ],
                          groupsSpace: 0, // Reduced space between bars
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderGray, width: 1),
          bottom: BorderSide(color: AppColors.borderGray, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.normal700(fontSize: 14, color: Colors.black),
            ),
            Text(
              value,
              style: AppTextStyles.normal700(
                  fontSize: 14, color: AppColors.paymentTxtColor1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermRow(String term, double percent, Color indicatorColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TermResultScreen(termTitle: term),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 75,
        decoration: const BoxDecoration(
            border: Border(
          bottom: BorderSide(color: AppColors.borderGray, width: 1),
        )),
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

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 60,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '1st Term';
        break;
      case 1:
        text = '2nd Term';
        break;
      case 2:
        text = '3rd Term';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      space: 4.0,
      meta: meta,
      child: Text(text,
          style: AppTextStyles.normal400(fontSize: 12, color: Colors.black)),
    );
  }
}
