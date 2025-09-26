import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class PerformanceChart extends StatefulWidget {
  const PerformanceChart({super.key});

  @override
  State<PerformanceChart> createState() => _PerformanceChartState();
}

class _PerformanceChartState extends State<PerformanceChart> {
  List<Map<String, dynamic>> performanceData = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPerformanceData();
  }

  Future<void> _fetchPerformanceData() async {
    try {
      final userBox = Hive.box('userData');
      final settings = userBox.get('settings');
      final db = userBox.get('_db');
      final token = userBox.get('token');

      if (settings == null || db == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'No settings or database configuration found. Please login again.';
        });
        return;
      }

      if (token == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'No authentication token found. Please login again.';
        });
        return;
      }

      final year = settings['year']?.toString();
      final term = settings['term']?.toString();

      if (year == null || term == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'Year or term not found in settings.';
        });
        return;
      }

      final apiService = locator<ApiService>();
      // Set the authentication token in ApiService
      apiService.setAuthToken(token);

      final response = await apiService.get(
        endpoint: 'portal/levels/result/performance',
        queryParams: {
          'year': year,
          'term': term,
          '_db': db,
        },
        fromJson: (json) => json['response'] as List<dynamic>,
      );

      if (response.success && response.data != null) {
        setState(() {
          performanceData = List<Map<String, dynamic>>.from(response.data!);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = response.message;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load performance data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!, style: AppTextStyles.normal400(fontSize: 14, color: Colors.red)));
    }

    if (performanceData.isEmpty) {
      return  Center(child: Text('No performance data available', style: AppTextStyles.normal400(fontSize: 14, color: Colors.black)));
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 2.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BarChart(
              BarChartData(
                maxY: 100,
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: _bottomTitles,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
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
                barGroups: _generateBarGroups(),
              ),
              swapAnimationCurve: Curves.linear,
              swapAnimationDuration: const Duration(milliseconds: 500),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIndicator(AppColors.barColor2, 'Average Score'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    return performanceData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final score = double.tryParse(data['average_score'].toString()) ?? 0.0;
      return BarChartGroupData(
        x: index + 1,
        barRods: [
          BarChartRodData(
            toY: score,
            width: 15,
            color: AppColors.barColor2,
            borderRadius: const BorderRadius.horizontal(),
          ),
        ],
      );
    }).toList();
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
        Text(
          text,
          style: AppTextStyles.normal400(fontSize: 12, color: Colors.black),
        ),
      ],
    );
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    final index = value.toInt() - 1;
    if (index < 0 || index >= performanceData.length) {
      return const SizedBox.shrink();
    }
    final levelName = performanceData[index]['level_name'] ?? '';
    return SideTitleWidget(
      axisSide: meta.axisSide, // pass just this instead of `meta`
      space: 16,
      child: Text(
        levelName,
        style: const TextStyle(color: AppColors.barTextGray, fontSize: 12),
      ),
    );
  }

  Widget _leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10, color: AppColors.barTextGray);
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0';
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
      axisSide: meta.axisSide, // pass just this instead of `meta`
      space: 8,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.right,
      ),
    );
  }
}

// // lib/widgets/performance_chart.dart
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';


// class PerformanceChart extends StatelessWidget {
//   const PerformanceChart({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         AspectRatio(
//           aspectRatio: 2.0,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: BarChart(
//               BarChartData(
//                 maxY: 100,
//                 titlesData: FlTitlesData(
//                   rightTitles: const AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                   topTitles: const AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 42,
//                       getTitlesWidget: _bottomTitles,
//                     ),
//                   ),
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       interval: 1,
//                       reservedSize: 30,
//                       getTitlesWidget: _leftTitles,
//                     ),
//                   ),
//                 ),
//                 borderData: FlBorderData(show: false),
//                 gridData: FlGridData(
//                   show: true,
//                   drawVerticalLine: false,
//                   horizontalInterval: 20,
//                   getDrawingHorizontalLine: (value) {
//                     return FlLine(
//                       color: Colors.black.withOpacity(0.3),
//                       strokeWidth: 1,
//                       dashArray: [5, 5],
//                     );
//                   },
//                   checkToShowHorizontalLine: (value) => value % 20 == 0,
//                 ),
//                 barGroups: [
//                   makeGroupData(1, 70, 50, 20),
//                   makeGroupData(2, 20, 10, 20),
//                   makeGroupData(3, 20, 80, 90),
//                   makeGroupData(4, 50, 10, 20),
//                   makeGroupData(5, 20, 90, 20),
//                   makeGroupData(6, 20, 60, 20),
//                   makeGroupData(7, 20, 60, 20),
//                 ],
//               ),
//               swapAnimationCurve: Curves.linear,
//               swapAnimationDuration: const Duration(milliseconds: 500),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
//           child: Center(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildIndicator(AppColors.barColor1, 'attendance'),
//                 _buildIndicator(AppColors.barColor2, 'academics'),
//                 _buildIndicator(AppColors.barColor3, 'behaviour'),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildIndicator(Color color, String text) {
//     return Row(
//       children: [
//         Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(3.0),
//           ),
//         ),
//         const SizedBox(width: 6.0),
//         Text(text,
//             style: AppTextStyles.normal400(fontSize: 12, color: Colors.black)),
//       ],
//     );
//   }

//   Widget _bottomTitles(double value, TitleMeta meta) {
//     final titles = <String>[
//       'BASIC 2',
//       'BASIC1',
//       'JSS1',
//       'JSS2',
//       'JSS3',
//       'SS1',
//       'SS2',
//       'SS3'
//     ];

//     final Widget text = Text(
//       titles[value.toInt()],
//       style: const TextStyle(color: AppColors.barTextGray),
//     );

//     return SideTitleWidget(
//       meta: meta,
//       space: 16,
//       child: text,
//     );
//   }

//   BarChartGroupData makeGroupData(int x, double y1, double y2, double y3) {
//     return BarChartGroupData(
//       barsSpace: 0.0,
//       x: x,
//       barRods: [
//         BarChartRodData(
//             toY: y1,
//             width: 10,
//             color: AppColors.barColor1,
//             borderRadius: const BorderRadius.horizontal()),
//         BarChartRodData(
//             toY: y2,
//             width: 10,
//             color: AppColors.barColor2,
//             borderRadius: const BorderRadius.horizontal()),
//         BarChartRodData(
//             toY: y3,
//             width: 10,
//             color: AppColors.barColor3,
//             borderRadius: const BorderRadius.horizontal()),
//       ],
//     );
//   }

//   Widget _leftTitles(double value, TitleMeta meta) {
//     const style = TextStyle(fontSize: 10, color: AppColors.barTextGray);
//     String text;
//     switch (value.toInt()) {
//       case 0:
//         text = '00';
//         break;
//       case 20:
//         text = '20';
//         break;
//       case 40:
//         text = '40';
//         break;
//       case 60:
//         text = '60';
//         break;
//       case 80:
//         text = '80';
//         break;
//       case 100:
//         text = '100';
//         break;
//       default:
//         text = '';
//         break;
//     }

//     return SideTitleWidget(
//       meta: meta,
//       space: 8,
//       child: Text(
//         text,
//         style: style,
//         textAlign: TextAlign.right,
//       ),
//     );
//   }
// }