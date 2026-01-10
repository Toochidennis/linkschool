import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';

class ClassDetailBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;

  const ClassDetailBarChart({super.key, this.chartData = const []});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      color: AppColors.bgColor1,
      child: AspectRatio(
        aspectRatio: 2.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: BarChart(
            BarChartData(
              maxY: 100,
              titlesData: FlTitlesData(
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
              barGroups: _buildBarGroups(),
              groupsSpace: 22.44,
            ),
            swapAnimationCurve: Curves.linear,
            swapAnimationDuration: const Duration(milliseconds: 500),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return chartData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final score = (data['average_score'] as num?)?.toDouble() ?? 0.0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: score,
            color:
                index % 2 == 0 ? AppColors.primaryLight : AppColors.videoColor4,
            width: 20.46,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget getTitles(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index >= 0 && index < chartData.length) {
      final abbr = chartData[index]['abbr']?.toString() ?? '';
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 8.0,
        child: Text(
          abbr,
          style: const TextStyle(fontSize: 11, color: Colors.black),
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
