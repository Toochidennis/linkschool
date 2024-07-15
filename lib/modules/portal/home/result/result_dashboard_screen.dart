import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class ResultDashboardScreen extends StatefulWidget {
  const ResultDashboardScreen({super.key});

  @override
  State<ResultDashboardScreen> createState() => _ResultDashboardScreenState();
}

class _ResultDashboardScreenState extends State<ResultDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                    barGroups: [
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
                  swapAnimationDuration: const Duration(milliseconds: 500),
                ),
              ),
            ),
          ),
          // Color indicators
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIndicator(AppColors.barColor1, 'attendance'),
                    _buildIndicator(AppColors.barColor2, 'academics'),
                    _buildIndicator(AppColors.barColor3, 'behaviour'),
                  ],
                ),
              ),
            ),
          ),
          // Settings section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Constants.heading600(
                    title: 'Settings',
                    titleSize: 18.0,
                    titleColor: AppColors.resultColor1,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSettingsBox('assets/icons/assessment.png', 'Assessment', AppColors.boxColor1),
                      _buildSettingsBox('assets/icons/grading.png', 'Grading', AppColors.boxColor2),
                      _buildSettingsBox('assets/icons/behaviour.png', 'Behaviour', AppColors.boxColor3),
                      _buildSettingsBox('assets/icons/tools.png', 'Tools', AppColors.boxColor4),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Select Level section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Constants.heading600(
                    title: 'Select Level',
                    titleSize: 18.0,
                    titleColor: AppColors.resultColor1,
                  ),
                  const SizedBox(height: 10.0),
                  Column(
                    children: [
                      _buildLevelBox('BASIC ONE', 'assets/images/box_bg1.png'),
                      _buildLevelBox('BASIC TWO', 'assets/images/box_bg2.png'),
                      _buildLevelBox('JSS ONE', 'assets/images/box_bg3.png'),
                      _buildLevelBox('JSS TWO', 'assets/images/box_bg4.png'),
                      _buildLevelBox('JSS THREE', 'assets/images/box_bg5.png'),
                      // _buildLevelBox('SS ONE', 'assets/images/ss_one_bg.svg'),
                      // _buildLevelBox('SS TWO', 'assets/images/ss_two_bg.svg'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    final titles = <String>[
      'BASIC 2',
      'BASIC 1',
      'JSS1',
      'JSS2',
      'JSS3',
      'SS1',
      'SS2',
      'SS3'
    ];

    final Widget text = Text(titles[value.toInt()]);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, // margin top
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
            color: AppColors.barColor1,
            borderRadius: const BorderRadius.horizontal()),
        BarChartRodData(
            toY: y2,
            width: 10,
            color: AppColors.barColor2,
            borderRadius: const BorderRadius.horizontal()),
        BarChartRodData(
            toY: y3,
            width: 10,
            color: AppColors.barColor3,
            borderRadius: const BorderRadius.horizontal()),
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
        text = '';
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text),
    );
  }

  Widget _buildIndicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        const SizedBox(width: 8.0),
        Text(text, style: AppTextStyles.normal400(fontSize: 12, color: Colors.black)),
      ],
    );
  }

  Widget _buildSettingsBox(String iconPath, String text, Color color) {
    return Container(
      width: 80,
      height: 90,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 2.0
              )
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.avatarbgColor,
              child: Image.asset(iconPath, width: 24, height: 24),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(text, style: AppTextStyles.normal600(fontSize: 14, color: Colors.black)),
        ],
      ),
    );
  }

Widget _buildLevelBox(String levelText, String backgroundImagePath) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Container(
      width: 430,
      height: 108,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        image: DecorationImage(
          image: AssetImage(backgroundImagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            levelText,
            style: AppTextStyles.normal700P(fontSize: 20.0, color: AppColors.backgroundLight, height: 1.04),
          ),
          const SizedBox(height: 31), // gap between text and button
          Container(
            width: 130,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.backgroundLight, width: 1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(2)),
            ),
            child: TextButton(
              onPressed: () {
                // Add your onPressed code here!
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                
              ),
              child:  Text(
                'View level performance',
                style:  AppTextStyles.normal700P(fontSize: 10, color: AppColors.backgroundLight, height: 1.2),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}