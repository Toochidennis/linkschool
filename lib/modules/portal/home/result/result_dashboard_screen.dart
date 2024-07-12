import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/constants.dart';

import '../../../common/app_colors.dart';

class ResultDashboardScreen extends StatefulWidget {
  const ResultDashboardScreen({super.key});

  @override
  State<ResultDashboardScreen> createState() => _ResultDashboardScreenState();
}

class _ResultDashboardScreenState extends State<ResultDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.of(context).pop();
        }, icon: const Icon(Icons.arrow_back)),
        title: Text('Results'),
        centerTitle: true,
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: 16.0),
            ),
            SliverToBoxAdapter(
              child: Constants.heading600(
                title: 'Overall Performance',
                titleSize: 18.0,
                titleColor: AppColors.resultColor1,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24.0),
            ),
            SliverToBoxAdapter(
              child: AspectRatio(
                aspectRatio: 2.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: BarChart(
                    BarChartData(
                      maxY: 100,
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                              getTitlesWidget: _bottomTitles),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 30,
                            getTitlesWidget: _leftTitles,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      barGroups: [
                        // makeGroupData(0, 30, 70, 60),
                        makeGroupData(1, 70, 50, 20),
                        makeGroupData(2, 20, 10, 20),
                        makeGroupData(3, 20, 80, 90),
                        makeGroupData(4, 50, 10, 20),
                        makeGroupData(5, 20, 90, 20),
                        makeGroupData(6, 20, 60, 20),
                        makeGroupData(7, 20, 60, 20),
                      ],
                    ),
                    swapAnimationCurve: Curves.linear,
                    swapAnimationDuration: Duration(milliseconds: 500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    final titles = <String>['BASIC 2', 'BASIC 1','JSS1', 'JSS2', 'JSS3', 'SS1', 'SS2', 'SS3'];

    final Widget text = Text(titles[value.toInt()]);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: text,
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2, double y3) {
    return BarChartGroupData(
      barsSpace: 0.0,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          width: 10,
          color: Colors.black.withOpacity(0.2),
            borderRadius: const BorderRadius.horizontal()
        ),
        BarChartRodData(
          toY: y2,
          width: 10,
          color: Colors.green.withOpacity(0.8),
          borderRadius: const BorderRadius.horizontal()
        ),
        BarChartRodData(
          toY: y3,
          width: 10,
          color: Colors.blue.withOpacity(0.4),
            borderRadius: const BorderRadius.horizontal()
        ),
      ],
    );
  }

  Widget _leftTitles(double value, TitleMeta meta) {
    String text;
    switch (value) {
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
        text ='';
        break;
    }

    return SideTitleWidget(child: Text("$text"), axisSide: meta.axisSide);
  }
}
