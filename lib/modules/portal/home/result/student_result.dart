import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../common/text_styles.dart';
import '../../../common/app_colors.dart';

class StudentResultScreen extends StatelessWidget {
  final String studentName;
  final String className; 
  const StudentResultScreen({Key? key, required this.studentName, required this.className}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'Student result',
      //     style: AppTextStyles.normal600(fontSize: 18.0, color: Colors.black),
      //   ),
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Colors.black),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 13.0),
      //       child: ElevatedButton(
              
      //         onPressed: () {
      //           // Add your onPressed code here!
      //         },
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: AppColors.secondaryLight,
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(4.0),
      //           ),
      //           padding: const EdgeInsets.symmetric(horizontal: 8.0)
      //         ),
      //         child: Text(
      //           'See student list',
      //           style: AppTextStyles.normal700(
      //             fontSize: 14.0,
      //             color: AppColors.backgroundLight,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      //   backgroundColor: AppColors.backgroundLight,
      //   elevation: 0.0,
      // ),

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
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
              ),
              child: Text(
                'See student list',
                style: AppTextStyles.normal700(
                  fontSize: 14,
                  color: AppColors.backgroundLight,
                ),
              ),
            ),
          ),
        ],
        backgroundColor: AppColors.backgroundLight,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                AppBar().preferredSize.height,
          ),
          child: Stack(children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 30, // Reduced from 50 to 30
                  ),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.backgroundLight,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          studentName,
                          style: AppTextStyles.normal700(
                            fontSize: 20,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow('Student ID:', '3ye7458918947y3'),
                  _buildInfoRow('Class:', 'JSS2 A'),
                  _buildInfoRow('Gender:', 'Female'),
                  _buildInfoRow('Student Average:', '76.80%'),
                  const SizedBox(height: 30),
                  Text(
                    '2015/2016 Session',
                    style: AppTextStyles.normal700(
                        fontSize: 18, color: AppColors.primaryLight),
                  ),
                  const SizedBox(height: 10),
                  _buildTermRow('First Term', 0.75, AppColors.primaryLight),
                  _buildTermRow('Second Term', 0.75, AppColors.videoColor4),
                  const SizedBox(height: 30),
                  Text(
                    'Session average chart',
                    style: AppTextStyles.normal700(
                      fontSize: 18,
                      color: AppColors.primaryLight,
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
                              getTitlesWidget: getTitles,
                              reservedSize: 38,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) =>
                                  Text(value.toInt().toString(), style: AppTextStyles.normal400(color: Colors.black, fontSize: 12),),
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
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
                          _buildBarGroup(0, 60, AppColors.primaryLight),
                          _buildBarGroup(1, 25, AppColors.videoColor4),
                          _buildBarGroup(2, 75, AppColors.primaryLight),
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
                  fontSize: 14, color: AppColors.primaryLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermRow(String term, double percent, Color indicatorColor) {
    return Container(
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
              style: AppTextStyles.normal700(fontSize: 14, color: Colors.black),
            ),
            CircularPercentIndicator(
              radius: 20.0,
              lineWidth: 4.92,
              percent: percent,
              center: Text("${(percent * 100).toInt()}%", style: AppTextStyles.normal600(fontSize: 10, color: Colors.black),),
              progressColor: indicatorColor,
              backgroundColor: Colors.transparent,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ],
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
      axisSide: meta.axisSide,
      space: 4.0,
      child: Text(text, style: AppTextStyles.normal400(fontSize: 12, color: Colors.black)),
    );
  }
}
