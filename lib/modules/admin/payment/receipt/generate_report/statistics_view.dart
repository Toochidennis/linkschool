import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
import 'package:linkschool/modules/services/admin/payment/payment_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/modules/model/admin/payment_model.dart';
// import 'package:linkschool/lib/widgets/naira_svg_icon.dart';

class ReceiptStatisticsView extends StatefulWidget {
  final Map<String, dynamic>? initialParams;

  const ReceiptStatisticsView({super.key, this.initialParams});

  @override
  State<ReceiptStatisticsView> createState() => _ReceiptStatisticsViewState();
}

class _ReceiptStatisticsViewState extends State<ReceiptStatisticsView> {
  IncomeReport? _incomeData;
  bool _isLoading = true;
  late Map<String, dynamic> _filterParams;
  final PaymentService _paymentService = locator<PaymentService>();

  @override
  void initState() {
    super.initState();
    _filterParams = Map.from(widget.initialParams ?? {
      'report_type': 'monthly',
      'group_by': 'level',
    });
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userBox = Hive.box('userData');
      _filterParams['_db'] = userBox.get('_db');
      
      final response = await _paymentService.getIncomeReport(_filterParams);
      setState(() {
        _incomeData = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      CustomToaster.toastError(context, 'Error', 'Failed to load statistics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _incomeData?.summary;
    final chartData = _incomeData?.chartData ?? [];
    final transactions = _incomeData?.transactions ?? [];

    // Convert chartData to List<double> for bar chart
    final List<double> dailyPayments = chartData.map((e) => e.y).toList();

    // Create labels for chart x-axis
    final List<String> chartLabels = chartData.map((e) {
      // Handle different x-axis formats (dates, levels, etc.)
      try {
        // Try parsing as date first
        if (e.x.contains('-') && e.x.length >= 7) {
          final date = DateFormat('yyyy-MM-dd').parse(e.x);
          return DateFormat('MMM d').format(date);
        } else {
          // If not a date, use the value directly (e.g., "JSS2", "SSS3")
          return e.x.length > 8 ? e.x.substring(0, 8) : e.x;
        }
      } catch (ex) {
        return e.x.length > 8 ? e.x.substring(0, 8) : e.x;
      }
    }).toList();

    return Container(
      decoration: Constants.customBoxDecoration(context),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Report type header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(209, 219, 255, 1).withOpacity(0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_filterParams['report_type']?.toString().capitalize() ?? 'Monthly'} report',
                            style: AppTextStyles.normal500(fontSize: 14, color: AppColors.backgroundDark),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Handle filter action
                            },
                            child: SvgPicture.asset('assets/icons/profile/filter_icon.svg', height: 24, width: 24),
                          ),
                        ],
                      ),
                    ),
                  ),

                  
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _filterParams['group_by'] == 'level' ? 'Payments by Level' : 'Daily Payments',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: dailyPayments.isEmpty
                              ? const Center(child: Text('No chart data available', style: TextStyle(color: Colors.black)))
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: dailyPayments.isNotEmpty 
                                        ? dailyPayments.reduce((a, b) => a > b ? a : b) * 1.1 
                                        : 30000,
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          return BarTooltipItem(
                                            '₦${rod.toY.toStringAsFixed(0)}\n${chartLabels.length > groupIndex ? chartLabels[groupIndex] : ''}',
                                            const TextStyle(color: Colors.white),
                                          );
                                        },
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          getTitlesWidget: (value, meta) {
                                            final index = value.toInt();
                                            if (index < 0 || index >= chartLabels.length) {
                                              return const Text('');
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                chartLabels[index],
                                                style: const TextStyle(fontSize: 12, color: Colors.black),
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
                                              style: const TextStyle(fontSize: 12, color: Colors.black),
                                            );
                                          },
                                        ),
                                      ),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                      horizontalInterval: dailyPayments.isNotEmpty 
                                          ? dailyPayments.reduce((a, b) => a > b ? a : b) / 5 
                                          : 5000,
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
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: transactions.isEmpty
                              ? const Center(child: Text('No distribution data available'))
                              : PieChart(
                                  PieChartData(
                                    sections: transactions.take(3).toList().asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final trans = entry.value;
                                      final value = trans.totalAmount ?? trans.amount ?? 0.0;
                                      final colors = [
                                        const Color.fromRGBO(209, 219, 255, 1),
                                        const Color.fromRGBO(47, 85, 221, 1),
                                        const Color.fromRGBO(198, 210, 255, 1),
                                      ];
                                      return PieChartSectionData(
                                        value: value,
                                        color: colors[index % colors.length],
                                        title: '₦${value.toStringAsFixed(0)}',
                                        radius: 50,
                                        titleStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      );
                                    }).toList(),
                                    sectionsSpace: 0,
                                    centerSpaceRadius: 40,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  // Summary Statistics
                  if (summary != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(209, 219, 255, 1).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Summary Statistics',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Amount:', style: TextStyle(color: Colors.black)),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const NairaSvgIcon(
                                      width: 12.0,
                                      height: 12.0,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      summary.totalAmount.toStringAsFixed(2),
                                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Transactions:', style: TextStyle(color: Colors.black)),
                                Text(
                                  '${summary.totalTransactions}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Unique Students:', style: TextStyle(color: Colors.black)),
                                Text(
                                  '${summary.uniqueStudents}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                            color: Colors.black,                            
                          ),
                        ),
                        const SizedBox(height: 16),
                        transactions.isEmpty
                            ? const Center(child: Text('No transactions available'))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: transactions.take(5).length,
                                itemBuilder: (context, index) {
                                  final item = transactions[index];
                                  final displayName = item.name.isNotEmpty ? item.name : 'Unknown';
                                  final displayAmount = item.totalAmount ?? item.amount ?? 0.0;
                                  
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
                                        Expanded(
                                          child: Text(
                                            displayName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const NairaSvgIcon(
                                              width: 12.0,
                                              height: 12.0,
                                              color: Colors.black,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              displayAmount.toStringAsFixed(2),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
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
            ),
    );
  }

  Widget _buildSessionTermItem(String text, int year, int term) {
    return ListTile(
      title: Text(text, style: const TextStyle(color: Colors.black)),
      onTap: () {
        setState(() {
          _filterParams['session'] = '$year/${year + 1}';
          _filterParams['term'] = term;
          _loadData();
        });
        Navigator.pop(context);
      },
    );
  }
}


// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}





// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';


// class ReceiptStatisticsView extends StatelessWidget {
//   const ReceiptStatisticsView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final List<double> dailyPayments = [25000, 22000, 5000, 8000, 20000, 12500];

//     return Container(
//       decoration: Constants.customBoxDecoration(context),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Existing Termly Report Container
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Container(
//               // width: 327,
//               height: 50,
//               decoration: BoxDecoration(
//                 color:  const Color.fromRGBO(209, 219, 255, 1).withOpacity(0.35),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('Termly report', style: AppTextStyles.normal500(fontSize: 14, color: AppColors.backgroundDark),),
//                   SvgPicture.asset('assets/icons/profile/filter_icon.svg', height: 24, width: 24,),
//                 ],
//               ),
//             ),
//           ),
      
//             // Existing Date and Session Picker Row
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         // Handle date picker
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(12),
//                         child: const Row(
//                           children: [
//                             Text('February 2023'),
//                             Icon(Icons.arrow_drop_down),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         // Handle session picker
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(12),
//                         child: const Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text('2023/2024 3rd Term'),
//                             Icon(Icons.arrow_drop_down),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
      
//             // Daily Payments Section
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Daily Payments',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   SizedBox(
//                     height: 300,
//                     child: BarChart(
//                       BarChartData(
//                         alignment: BarChartAlignment.spaceAround,
//                         maxY: 30000,
//                         barTouchData: BarTouchData(enabled: true),
//                         titlesData: FlTitlesData(
//                           show: true,
//                           bottomTitles: AxisTitles(
//                             sideTitles: SideTitles(
//                               showTitles: true,
//                               getTitlesWidget: (value, meta) {
//                                 return Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Text(
//                                     '02-${(23 + value.toInt()).toString()}',
//                                     style: const TextStyle(fontSize: 12),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                           leftTitles: AxisTitles(
//                             sideTitles: SideTitles(
//                               showTitles: true,
//                               reservedSize: 40,
//                               getTitlesWidget: (value, meta) {
//                                 return Text(
//                                   '${(value / 1000).toInt()}k',
//                                   style: const TextStyle(fontSize: 12),
//                                 );
//                               },
//                             ),
//                           ),
//                           rightTitles: const AxisTitles(
//                             sideTitles: SideTitles(showTitles: false),
//                           ),
//                           topTitles: const AxisTitles(
//                             sideTitles: SideTitles(showTitles: false),
//                           ),
//                         ),
//                         gridData: FlGridData(
//                           show: true,
//                           horizontalInterval: 5000,
//                           drawVerticalLine: false,
//                         ),
//                         borderData: FlBorderData(show: false),
//                         barGroups: List.generate(
//                           dailyPayments.length,
//                           (index) => BarChartGroupData(
//                             x: index,
//                             barRods: [
//                               BarChartRodData(
//                                 toY: dailyPayments[index],
//                                 color: const Color.fromRGBO(209, 219, 255, 1),
//                                 width: 20,
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
      
//             // Payments Distribution Section
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Payments distributed',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   SizedBox(
//                     height: 200,
//                     child: PieChart(
//                       PieChartData(
//                         sections: [
//                           PieChartSectionData(
//                             value: 7000,
//                             color: const Color.fromRGBO(209, 219, 255, 1),
//                             title: '₦7,000',
//                             radius: 50,
//                             titleStyle: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                           ),
//                           PieChartSectionData(
//                             value: 7000,
//                             color: const Color(0xFF34A853),
//                             title: '₦7,000',
//                             radius: 50,
//                             titleStyle: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                           ),
//                           PieChartSectionData(
//                             value: 7000,
//                             color: const Color(0xFFFBBC05),
//                             title: '₦7,000',
//                             radius: 50,
//                             titleStyle: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ],
//                         sectionsSpace: 0,
//                         centerSpaceRadius: 40,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
      
//             // Leaderboard Section
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Leaderboard',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: 5,
//                     itemBuilder: (context, index) {
//                       final items = [
//                         {'name': 'Electricity', 'amount': '₦234,790.00'},
//                         {'name': 'Feeding', 'amount': '₦43,790.00'},
//                         {'name': 'Water', 'amount': '₦20,790.00'},
//                         {'name': 'Water', 'amount': '₦20,790.00'},
//                         {'name': 'Water', 'amount': '₦20,790.00'},
//                       ];
                      
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 12.0),
//                         child: Row(
//                           children: [
//                             Text(
//                               '${index + 1}',
//                               style: TextStyle(
//                                 color: index == 0
//                                     ? const Color(0xFF4285F4)
//                                     : index == 1
//                                         ? const Color(0xFFEA4335)
//                                         : Colors.grey,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Text(
//                               items[index]['name']!,
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                             const Spacer(),
//                             Text(
//                               items[index]['amount']!,
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }