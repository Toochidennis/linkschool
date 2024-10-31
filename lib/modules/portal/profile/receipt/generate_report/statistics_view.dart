import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<double> dailyPayments = [25000, 22000, 5000, 8000, 20000, 12500];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Existing Termly Report Container
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            // width: 327,
            height: 50,
            decoration: BoxDecoration(
              color:  const Color.fromRGBO(209, 219, 255, 1).withOpacity(0.35),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Termly report', style: AppTextStyles.normal500(fontSize: 14, color: AppColors.backgroundDark),),
                SvgPicture.asset('assets/icons/profile/filter_icon.svg', height: 24, width: 24,),
              ],
            ),
          ),
        ),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Container(
          //     width: 327,
          //     height: 40,
          //     decoration: BoxDecoration(
          //       color: const Color.fromRGBO(209, 219, 255, 1),
          //       borderRadius: BorderRadius.circular(4),
          //     ),
          //     padding: const EdgeInsets.symmetric(horizontal: 16),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         const Text('Termly report'),
          //         SvgPicture.asset('assets/icons/profile/filter_icon.svg'),
          //       ],
          //     ),
          //   ),
          // ),

          // Existing Date and Session Picker Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Handle date picker
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Row(
                        children: [
                          Text('February 2023'),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Handle session picker
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('2023/2024 3rd Term'),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Daily Payments Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Payments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 30000,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '02-${(23 + value.toInt()).toString()}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${(value / 1000).toInt()}k',
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 5000,
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(
                        dailyPayments.length,
                        (index) => BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: dailyPayments[index],
                              color: const Color.fromRGBO(209, 219, 255, 1),
                              width: 20,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Payments Distribution Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payments distributed',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: 7000,
                          color: const Color.fromRGBO(209, 219, 255, 1),
                          title: '₦7,000',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        PieChartSectionData(
                          value: 7000,
                          color: const Color(0xFF34A853),
                          title: '₦7,000',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        PieChartSectionData(
                          value: 7000,
                          color: const Color(0xFFFBBC05),
                          title: '₦7,000',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Leaderboard Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final items = [
                      {'name': 'Electricity', 'amount': '₦234,790.00'},
                      {'name': 'Feeding', 'amount': '₦43,790.00'},
                      {'name': 'Water', 'amount': '₦20,790.00'},
                      {'name': 'Water', 'amount': '₦20,790.00'},
                      {'name': 'Water', 'amount': '₦20,790.00'},
                    ];
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: index == 0
                                  ? const Color(0xFF4285F4)
                                  : index == 1
                                      ? const Color(0xFFEA4335)
                                      : Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            items[index]['name']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            items[index]['amount']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}