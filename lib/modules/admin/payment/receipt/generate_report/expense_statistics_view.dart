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
import 'package:linkschool/modules/services/admin/payment/expenditure_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
// import 'package:linkschool/lib/widgets/naira_svg_icon.dart';

class ExpenseStatisticsView extends StatefulWidget {
  final Map<String, dynamic>? initialParams;

  const ExpenseStatisticsView({super.key, this.initialParams});

  @override
  State<ExpenseStatisticsView> createState() => _ExpenseStatisticsViewState();
}

class _ExpenseStatisticsViewState extends State<ExpenseStatisticsView> {
  Map<String, dynamic>? _expenditureData;
  bool _isLoading = true;
  late Map<String, dynamic> _filterParams;
  final ExpenditureService _expenditureService = locator<ExpenditureService>();

  @override
  void initState() {
    super.initState();
    _filterParams =
        Map.from(widget.initialParams ?? {'report_type': 'monthly'});
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userBox = Hive.box('userData');
      _filterParams['_db'] = userBox.get('_db');
      final response = await _expenditureService.generateReport(_filterParams);
      if (response.success && response.data != null) {
        setState(() {
          _expenditureData = response.data;
          _isLoading = false;
        });
      } else {
        throw Exception(response.message ?? 'Failed to load data');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      CustomToaster.toastError(
          context, 'Error', 'Failed to load statistics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _expenditureData?['summary'] ?? {};
    final chartData = _expenditureData?['chart_data'] as List<dynamic>? ?? [];
    final transactions =
        _expenditureData?['transactions'] as List<dynamic>? ?? [];

    // Convert chartData to List<double> for dailyPayments
    final List<double> dailyPayments = chartData.map((e) {
      final yValue = e is Map<String, dynamic> ? e['y'] : null;
      if (yValue is int) return yValue.toDouble();
      if (yValue is double) return yValue;
      return 0.0; // Fallback for null or invalid types
    }).toList();

    // Create date labels for BarChart x-axis
    final List<String> dateLabels = chartData.map((e) {
      final dateStr = e is Map<String, dynamic> ? e['x']?.toString() ?? '' : '';
      try {
        final date = DateFormat('yyyy-MM-dd').parse(dateStr);
        return DateFormat('MMM d').format(date); // Format as "Sep 11"
      } catch (e) {
        return dateStr.isNotEmpty
            ? dateStr.substring(0, dateStr.length > 5 ? 5 : dateStr.length)
            : '';
      }
    }).toList();

    return Container(
        color: Colors.white,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(209, 219, 255, 1)
                            .withOpacity(0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _filterParams['report_type']
                                    ?.toString()
                                    .capitalize() ??
                                'Termly report',
                            style: AppTextStyles.normal500(
                                fontSize: 14, color: AppColors.backgroundDark),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Handle filter action
                            },
                            child: SvgPicture.asset(
                                'assets/icons/profile/filter_icon.svg',
                                height: 24,
                                width: 24),
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
                        const Text(
                          'Daily Payments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: dailyPayments.isEmpty
                              ? const Center(
                                  child: Text('No chart data available'))
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: dailyPayments.isNotEmpty
                                        ? dailyPayments.reduce(
                                                (a, b) => a > b ? a : b) *
                                            1.1
                                        : 30000,
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                        // tooltipBgColor: Colors.blueAccent,
                                        getTooltipItem:
                                            (group, groupIndex, rod, rodIndex) {
                                          return BarTooltipItem(
                                            '₦${rod.toY.toStringAsFixed(2)}\n${dateLabels[groupIndex]}',
                                            const TextStyle(
                                                color: Colors.white),
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
                                            if (index < 0 ||
                                                index >= dateLabels.length) {
                                              return const Text('');
                                            }
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                dateLabels[index],
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black),
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
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black),
                                            );
                                          },
                                        ),
                                      ),
                                      rightTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                      horizontalInterval:
                                          dailyPayments.isNotEmpty
                                              ? dailyPayments.reduce(
                                                      (a, b) => a > b ? a : b) /
                                                  5
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
                                            color: const Color.fromRGBO(
                                                209, 219, 255, 1),
                                            width: 20,
                                            borderRadius:
                                                BorderRadius.circular(4),
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
                              ? const Center(
                                  child: Text('No distribution data available',
                                      style: TextStyle(color: Colors.black)))
                              : PieChart(
                                  PieChartData(
                                    sections: transactions
                                        .take(3)
                                        .toList()
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final index = entry.key;
                                      final trans =
                                          entry.value as Map<String, dynamic>;
                                      final value = (trans['total_amount'] ??
                                          trans['amount'] ??
                                          7000.0) as num;
                                      final colors = [
                                        const Color.fromRGBO(209, 219, 255, 1),
                                        const Color.fromRGBO(47, 85, 221, 1),
                                        const Color.fromRGBO(198, 210, 255, 1),
                                      ];
                                      return PieChartSectionData(
                                        value: value.toDouble(),
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
                            ? const Center(
                                child: Text('No transactions available'))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: transactions.take(5).length,
                                itemBuilder: (context, index) {
                                  final item = transactions[index]
                                      as Map<String, dynamic>;
                                  final name =
                                      item['name']?.toString() ?? 'Unknown';
                                  final amount = (item['total_amount'] ??
                                      item['amount'] ??
                                      0.0) as num;
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12.0),
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
                                            name,
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
                                              amount.toStringAsFixed(2),
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
      title: Text(text),
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
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
