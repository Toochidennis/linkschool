import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button_2.dart';
import 'package:linkschool/modules/common/text_styles.dart';

import 'package:linkschool/modules/student/result/single_termresult.dart';
import 'package:linkschool/modules/student/result/student_annual_result_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/providers/admin/student_provider.dart';
// Import the overlays.dart to access the showStudentResultOverlay function
import 'package:linkschool/modules/common/widgets/portal/class_detail/overlays.dart';

class StudentResultScreen extends StatelessWidget {
  final String? studentName;
  final String? className;

  const StudentResultScreen({super.key, this.studentName, this.className});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          className!,
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
          SizedBox(
            height: 32,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13.0),
              child: CustomMediumElevatedButton(
                text: 'See student list',
                onPressed: () {
                  // Use the same overlay function instead of navigating to a new screen
                  showStudentResultOverlay(context,
                      className: className ?? 'Unknown Class');
                },
                backgroundColor: AppColors.videoColor4,
                textStyle: AppTextStyles.normal700(
                    fontSize: 14, color: AppColors.backgroundLight),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
              ),
            ),
          ),
        ],
        backgroundColor: AppColors.backgroundLight,
        elevation: 0.0,
      ),
      body: Consumer<StudentProvider>(
        builder: (context, studentProvider, child) {
          if (studentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (studentProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                'Error: ${studentProvider.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final student = studentProvider.student;
          final terms = studentProvider.studentTerms;

          if (student == null) {
            return const Center(
              child: Text('Student information not available'),
            );
          }

          // Process the result terms
          final Map<String, List<Map<String, dynamic>>> processedTerms = {};
          List<Map<String, dynamic>> chartData = [];

          if (terms != null && terms.isNotEmpty) {
            terms.forEach((year, yearData) {
              if (yearData is Map && yearData.containsKey('terms')) {
                processedTerms[year] = [];
                final termsList = yearData['terms'] as List;

                for (var termData in termsList) {
                  final term = termData['term'] ?? termData['term_value'];
                  final termName = termData['term_name'] ?? '';
                  final averageScore =
                      double.tryParse(termData['average_score'].toString()) ??
                          0.0;
                  final percent = averageScore / 100.0;

                  processedTerms[year]!.add({
                    'termName': termName,
                    'percent': percent,
                    'averageScore': averageScore,
                  });

                  chartData.add({
                    'term': term,
                    'termName': termName,
                    'averageScore': averageScore,
                  });
                }
              }
            });
          }

          // Determine if there's a "profile picture" or use icon
          Widget profileImage;
          if (student.pictureUrl != null && student.pictureUrl!.isNotEmpty) {
            profileImage = Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(
                    'https://linkskool.net/${student.pictureUrl}',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else {
            profileImage = Container(
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
            );
          }

          // Get the current year's data for display
          String currentYear = '';
          List<Map<String, dynamic>> currentYearTerms = [];

          if (processedTerms.isNotEmpty) {
            currentYear = processedTerms.keys.first;
            currentYearTerms = processedTerms[currentYear]!;
          }

          return SingleChildScrollView(
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
                      const SizedBox(height: 30),
                      Center(
                        child: Column(
                          children: [
                            profileImage,
                            const SizedBox(height: 10),
                            Text(
                              student.fullName,
                              style: AppTextStyles.normal700(
                                fontSize: 20,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow('Student ID:', student.registrationNo),
                      _buildInfoRow('Class:',
                          className!), // Class info passed as parameter
                      _buildInfoRow('Gender:',
                          'Female'), // Gender info not in student data

                      // Calculate average if terms data is available
                      _buildInfoRow(
                          'Student Average:',
                          chartData.isEmpty
                              ? 'N/A'
                              : '${(chartData.map((e) => e['averageScore']).reduce((a, b) => a + b) / chartData.length).toStringAsFixed(2)}%'),

                      const SizedBox(height: 30),
                      if (currentYear.isNotEmpty)
                        Text(
                          '$currentYear/${int.parse(currentYear) + 1} Session',
                          style: AppTextStyles.normal700(
                              fontSize: 18, color: AppColors.primaryLight),
                        ),
                      const SizedBox(height: 10),

                      // Display terms for current session or show error message if no data
                      if (currentYearTerms.isEmpty)
                        Center(
                          child: Text(
                            'No data available for the current session',
                          ),
                        )
                      else
                        ...currentYearTerms.map((termData) {
                          Color indicatorColor;
                          if (termData['termName'] == 'First Term') {
                            indicatorColor = AppColors.primaryLight;
                          } else if (termData['termName'] == 'Second Term') {
                            indicatorColor = AppColors.videoColor4;
                          } else {
                            indicatorColor = AppColors.exploreButton3Light;
                          }

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SingleTermResult(),
                                ),
                              );
                            },
                            child: _buildTermRow(
                              termData['termName'],
                              termData['percent'],
                              indicatorColor,
                            ),
                          );
                        }),

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
                        borderColor: AppColors.videoColor4,
                        textColor: AppColors.videoColor4,
                        fontSize: 18,
                        borderRadius: 10.0,
                        buttonHeight: 48,
                      ),

                      const SizedBox(height: 60),
                      Text(
                        'Session average chart',
                        style: AppTextStyles.normal700(
                          fontSize: 18,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(height: 40.0),

                      // Chart display
                      if (chartData.isNotEmpty)
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
                                    getTitlesWidget: (value, meta) => Text(
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
                              barGroups: chartData.map((data) {
                                final termIndex = (data['term'] as int) -
                                    1; // Convert to 0-based index
                                final averageScore =
                                    data['averageScore'] as double;
                                Color barColor = AppColors.primaryLight;

                                if (termIndex == 1) {
                                  // Second term
                                  barColor = AppColors.videoColor4;
                                } else if (termIndex == 2) {
                                  // Third term
                                  barColor = AppColors.exploreButton3Light;
                                }

                                return BarChartGroupData(
                                  x: termIndex,
                                  barRods: [
                                    BarChartRodData(
                                      toY: averageScore,
                                      color: barColor,
                                      width: 60,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        topRight: Radius.circular(4),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),

                              // barGroups: chartData.map((data) {
                              //   final termIndex = data['term'] as int;
                              //   final averageScore = data['averageScore'] as double;
                              //   Color barColor = AppColors.primaryLight;

                              //   if (termIndex == 2) {
                              //     barColor = AppColors.videoColor4;
                              //   } else if (termIndex == 3) {
                              //     barColor = AppColors.exploreButton3Light;
                              //   }

                              //   return _buildBarGroup(
                              //     termIndex - 1, // 0-based index
                              //     averageScore,
                              //     barColor
                              //   );
                              // }).toList(),
                              groupsSpace: 0,
                            ),
                          ),
                        ),
                      if (chartData.isEmpty)
                        const Center(
                          child: Text('No chart data available'),
                        ),
                    ],
                  ),
                ),
              ]),
            ),
          );
        },
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
              center: Text(
                "${(percent * 100).toInt()}%",
                style:
                    AppTextStyles.normal600(fontSize: 10, color: Colors.black),
              ),
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
      space: 4.0,
      meta: meta,
      child: Text(text,
          style: AppTextStyles.normal400(fontSize: 12, color: Colors.black)),
    );
  }
}
