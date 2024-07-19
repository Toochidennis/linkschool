import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

import 'package:linkschool/modules/portal/home/result/assessment_settings.dart';
import 'package:linkschool/modules/portal/home/result/grading_settings.dart';
import 'package:linkschool/modules/portal/home/result/class_detail_screen.dart';

class ResultDashboardScreen extends StatefulWidget {
  const ResultDashboardScreen({super.key});

  @override
  State<ResultDashboardScreen> createState() => _ResultDashboardScreenState();
}

class _ResultDashboardScreenState extends State<ResultDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isOverlayVisible = false;
  String _selectedLevel = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleOverlay(String level) {
    setState(() {
      _selectedLevel = level;
      _isOverlayVisible = !_isOverlayVisible;
      if (_isOverlayVisible) {
        _controller.forward();
        _showClassSelectionDialog();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
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
                          checkToShowHorizontalLine: (value) => value % 20 == 0,
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
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
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 28.0,
                ),
              ),
              SliverToBoxAdapter(
                child: Constants.heading600(
                  title: 'Settings',
                  titleSize: 18.0,
                  titleColor: AppColors.resultColor1,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16.0),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildSettingsBox(
                                'assets/icons/assessment.png',
                                'Assessment',
                                AppColors.boxColor1, () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AssessmentSettingScreen()));
                            }),
                          ),
                          _buildSettingsBox('assets/icons/grading.png',
                              'Grading', AppColors.boxColor2, () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const GradingSettingsScreen()));
                          }),
                          _buildSettingsBox('assets/icons/behaviour.png',
                              'Behaviour', AppColors.boxColor3, () {}),
                          _buildSettingsBox('assets/icons/tools.png', 'Tools',
                              AppColors.boxColor4, () {}),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 48.0,
                ),
              ),
              SliverToBoxAdapter(
                child: Constants.heading600(
                  title: 'Select Level',
                  titleSize: 18.0,
                  titleColor: AppColors.resultColor1,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          _buildLevelBox(
                              'BASIC ONE', 'assets/images/box_bg1.png'),
                          _buildLevelBox(
                              'BASIC TWO', 'assets/images/box_bg2.png'),
                          _buildLevelBox(
                              'JSS ONE', 'assets/images/box_bg3.png'),
                          _buildLevelBox(
                              'JSS TWO', 'assets/images/box_bg4.png'),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 60.0),
                            child: _buildLevelBox(
                                'JSS THREE', 'assets/images/box_bg5.png'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isOverlayVisible)
          GestureDetector(
            onTap: () => _toggleOverlay(_selectedLevel),
            child: Container(
              color: Colors.black.withOpacity(0.5 * _animation.value),
            ),
          ),
      ],
    );
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    final titles = <String>[
      'BASIC 2',
      'BASIC1',
      'JSS1',
      'JSS2',
      'JSS3',
      'SS1',
      'SS2',
      'SS3'
    ];

    final Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(color: AppColors.barTextGray),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
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
        text = '';
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildIndicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.0),
          ),
        ),
        const SizedBox(width: 6.0),
        Text(text,
            style: AppTextStyles.normal400(fontSize: 12, color: Colors.black)),
      ],
    );
  }

  Widget _buildSettingsBox(
      String iconPath, String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 70,
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
                    border: Border.all(color: color, width: 2.0)),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.avatarbgColor,
                  child: Image.asset(iconPath, width: 24, height: 24),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                text,
                style:
                    AppTextStyles.normal600(fontSize: 12, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelBox(String levelText, String backgroundImagePath) {
    return GestureDetector(
      onTap: () => _toggleOverlay(levelText),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          width: 430,
          height: 140,
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
                style: AppTextStyles.normal700P(
                    fontSize: 20.0,
                    color: AppColors.backgroundLight,
                    height: 1.04),
              ),
              const SizedBox(height: 40),
              Container(
                width: 148,
                height: 32,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: AppColors.backgroundLight, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextButton(
                  onPressed: () => _toggleOverlay(levelText),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View level performance',
                    style: AppTextStyles.normal700P(
                        fontSize: 12,
                        color: AppColors.backgroundLight,
                        height: 1.2),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClassSelectionDialog() {
    final classes = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
    final levelPrefix = _selectedLevel.split(' ')[0];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        builder: (BuildContext context) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Select Class',
                  style: AppTextStyles.normal600(
                      fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    padding: const EdgeInsets.all(16),
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          // print(
                          //     "Button tapped: $levelPrefix ${classes[index]}");
                          Navigator.of(context).pop(); // Close the dialog
                          _navigateToClassDetail(
                              '$levelPrefix ${classes[index]}');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$levelPrefix ${classes[index]}',
                            style: AppTextStyles.normal400(
                                fontSize: 14, color: AppColors.resultColor1),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  void _navigateToClassDetail(String className) {
    // print(
    //     "Attempting to navigate to ClassDetailScreen with className: $className");

    // Attempt to navigate immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // print("Navigating to ClassDetailScreen");
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => ClassDetailScreen(className: className),
        ),
      )
          .then((_) {
        // print("Returned from ClassDetailScreen");
      });
    });
  }
}
