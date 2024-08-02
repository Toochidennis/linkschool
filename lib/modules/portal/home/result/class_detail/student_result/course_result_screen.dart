import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class CourseResultScreen extends StatefulWidget {
  @override
  State<CourseResultScreen> createState() => _CourseResultScreenState();
}

class _CourseResultScreenState extends State<CourseResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: Text(
          'Course Result 2023/2024',
          style: AppTextStyles.normal500(
              fontSize: 18.0, color: AppColors.primaryLight),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Image.asset(
              'assets/icons/arrow_back.png',
              height: 34.0,
              width: 34.0,
              color: AppColors.primaryLight,
            )),
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
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 15.0,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 250,
                    width: 196,
                    color: AppColors.bgColor1,
                    child: AspectRatio(
                      aspectRatio: 2.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: BarChart(
                          BarChartData(
                            maxY: 100,
                            titlesData: FlTitlesData(
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 42,
                                  getTitlesWidget: _getTitles,
                                )
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget: _leftTitles
                                )
                              )
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
                                  dashArray: [5, 5]
                                );
                              },
                              checkToShowHorizontalLine: (value) => value % 20 == 0,
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
                            groupsSpace: 22.44
                          ),
                          swapAnimationCurve: Curves.linear,
                          swapAnimationDuration: const Duration(microseconds: 500),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: _buildSubjectRows(),
                    ),
                  ),
                ),
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

  Widget _getTitles(double value, TitleMeta meta) {
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

  List<Widget> _buildSubjectRows() {
    final subjects = ['Mathematics', 'English', 'Chemistry', 'Biology', 'Physics', 'CRS', 'Civic Education', 'Literature', 'Government', 'Economics'];
    
    return subjects.map((subject) => _buildSubjectRow(subject)).toList();
  }

  Widget _buildSubjectRow(String subject) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircularLetter(subject[0]),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                subject,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          _buildCircularProgressBar(),
        ],
      ),
    );
  }

  Widget _buildCircularLetter(String letter) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryLight,
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCircularProgressBar() {
    return Container(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -3.14159 / 2, // Rotate 90 degrees counterclockwise
            child: CircularProgressIndicator(
              value: 0.75,
              strokeWidth: 5,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.progressBarColor1),
            ),
          ),
          Text(
            '75%',
            style: AppTextStyles.normal600(fontSize: 12, color: AppColors.backgroundDark),
          ),
        ],
      ),
    );
  }
}