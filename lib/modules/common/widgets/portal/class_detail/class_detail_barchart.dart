import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';

class ClassDetailBarChart extends StatelessWidget {
  const ClassDetailBarChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
              groupsSpace: 22.44,
            ),
            swapAnimationCurve: Curves.linear,
            swapAnimationDuration: const Duration(microseconds: 500),
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
          style: const TextStyle(fontSize: 12, color: Colors.black),
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
}
