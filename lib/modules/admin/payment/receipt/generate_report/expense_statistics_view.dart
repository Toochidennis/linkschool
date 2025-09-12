import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/services/admin/payment/expenditure_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

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
    _filterParams = Map.from(widget.initialParams ?? {'report_type': 'monthly'});
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
      CustomToaster.toastError(context, 'Error', 'Failed to load statistics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _expenditureData?['summary'] ?? {};
    final chartData = _expenditureData?['chart_data'] as List<dynamic>? ?? [];
    final transactions = _expenditureData?['transactions'] as List<dynamic>? ?? [];

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
        return dateStr.isNotEmpty ? dateStr.substring(0, dateStr.length > 5 ? 5 : dateStr.length) : '';
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
                            _filterParams['report_type']?.toString().capitalize() ?? 'Termly report',
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2025),
                              );
                              if (picked != null) {
                                setState(() {
                                  _filterParams['start_date'] = DateFormat('yyyy-MM-dd').format(picked);
                                  _loadData();
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Text(_filterParams['start_date'] ?? 'February 2023'),
                                  const Icon(Icons.arrow_drop_down),
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
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: AppColors.backgroundLight,
                                builder: (BuildContext context) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).viewInsets.bottom,
                                    ),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Text(
                                              'Select Session and Term',
                                              style: AppTextStyles.normal600(
                                                fontSize: 20,
                                                color: const Color.fromRGBO(47, 85, 221, 1),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: ListView(
                                              children: [
                                                _buildSessionTermItem('2023/2024 1st Term', 2023, 1),
                                                _buildSessionTermItem('2023/2024 2nd Term', 2023, 2),
                                                _buildSessionTermItem('2023/2024 3rd Term', 2023, 3),
                                                _buildSessionTermItem('2022/2023 3rd Term', 2022, 3),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_filterParams['session'] ?? '2023/2024 3rd Term'),
                                  const Icon(Icons.arrow_drop_down),
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
                          child: dailyPayments.isEmpty
                              ? const Center(child: Text('No chart data available'))
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: dailyPayments.isNotEmpty ? dailyPayments.reduce((a, b) => a > b ? a : b) * 1.1 : 30000,
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                        // tooltipBgColor: Colors.blueAccent,
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          return BarTooltipItem(
                                            '₦${rod.toY.toStringAsFixed(2)}\n${dateLabels[groupIndex]}',
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
                                            if (index < 0 || index >= dateLabels.length) {
                                              return const Text('');
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                dateLabels[index],
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
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                      horizontalInterval: dailyPayments.isNotEmpty ? dailyPayments.reduce((a, b) => a > b ? a : b) / 5 : 5000,
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
                          child: transactions.isEmpty
                              ? const Center(child: Text('No distribution data available'))
                              : PieChart(
                                  PieChartData(
                                    sections: transactions.take(3).toList().asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final trans = entry.value as Map<String, dynamic>;
                                      final value = (trans['total_amount'] ?? trans['amount'] ?? 7000.0) as num;
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
                                  final item = transactions[index] as Map<String, dynamic>;
                                  final name = item['name']?.toString() ?? 'Unknown';
                                  final amount = (item['total_amount'] ?? item['amount'] ?? 0.0) as num;
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
                                            name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '₦${amount.toStringAsFixed(2)}',
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




// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:hive/hive.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';

// class StatisticsView extends StatefulWidget {
//   final Map<String, dynamic>? initialParams;

//   const StatisticsView({super.key, this.initialParams});

//   @override
//   _StatisticsViewState createState() => _StatisticsViewState();
// }

// class _StatisticsViewState extends State<StatisticsView> {
//   Map<String, dynamic>? expenditureData;
//   bool _isLoading = true;
//   late Map<String, dynamic> _filterParams;
//   List<Map<String, dynamic>> vendors = [];
//   List<Map<String, dynamic>> accounts = [];
//   String reportType = 'monthly';
//   String? groupBy;
//   String? customType;
//   String? startDate;
//   String? endDate;
//   List<int> selectedVendors = [];
//   List<int> selectedSessions = [];
//   List<int> selectedTerms = [];
//   List<int> selectedAccounts = [];
//   String db = 'aalmgzmy_linkskoo_practice'; // From login response
//   String token = ''; // Set from login response

//   @override
//   void initState() {
//     super.initState();
//     final userBox = Hive.box('userData');
//     token = userBox.get('token') ?? '';
//     _filterParams = Map.from(widget.initialParams ?? {'report_type': 'monthly'});
//     fetchVendors();
//     fetchAccounts();
//     _loadData();
//   }

//   Future<void> fetchVendors() async {
//     final response = await http.get(
//       Uri.parse('https://linkskool.net/api/v3/portal/payments/vendors?_db=$db'),
//       headers: {'Authorization': 'Bearer $token'},
//     );
//     if (response.statusCode == 200) {
//       setState(() {
//         vendors = List<Map<String, dynamic>>.from(json.decode(response.body)['response']);
//       });
//     }
//   }

//   Future<void> fetchAccounts() async {
//     final response = await http.get(
//       Uri.parse('https://linkskool.net/api/v3/portal/payments/accounts?page=1&limit=140&_db=$db'),
//       headers: {'Authorization': 'Bearer $token'},
//     );
//     if (response.statusCode == 200) {
//       setState(() {
//         accounts = List<Map<String, dynamic>>.from(json.decode(response.body)['response']['data']);
//       });
//     }
//   }

//   Future<void> _loadData() async {
//     setState(() => _isLoading = true);
//     try {
//       final userBox = Hive.box('userData');
//       _filterParams['_db'] = userBox.get('_db');
//       final response = await http.post(
//         Uri.parse('https://linkskool.net/api/v3/portal/payments/expenditure/report/generate'),
//         headers: {
//           'Authorization': 'Bearer ${userBox.get('token')}',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode(_filterParams),
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           expenditureData = json.decode(response.body)['data'];
//           _isLoading = false;
//         });
//       } else {
//         throw Exception('Failed to load data: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading statistics: $e')));
//     }
//   }

//   void showFilterOverlay(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => FilterBottomSheet(
//         reportType: reportType,
//         groupBy: groupBy,
//         customType: customType,
//         startDate: startDate,
//         endDate: endDate,
//         selectedVendors: selectedVendors,
//         selectedSessions: selectedSessions,
//         selectedTerms: selectedTerms,
//         selectedAccounts: selectedAccounts,
//         vendors: vendors,
//         accounts: accounts,
//         onApply: (filters) {
//           setState(() {
//             reportType = filters['reportType'] ?? 'monthly';
//             groupBy = filters['groupBy'];
//             customType = filters['customType'];
//             startDate = filters['startDate'];
//             endDate = filters['endDate'];
//             selectedVendors = filters['vendors'] ?? [];
//             selectedSessions = filters['sessions'] ?? [];
//             selectedTerms = filters['terms'] ?? [];
//             selectedAccounts = filters['accounts'] ?? [];
//             _filterParams = {
//               'report_type': reportType,
//               '_db': db,
//               if (groupBy != null) 'group_by': groupBy,
//               if (customType != null) 'custom_type': customType,
//               if (startDate != null) 'start_date': startDate,
//               if (endDate != null) 'end_date': endDate,
//               if (selectedVendors.isNotEmpty || selectedSessions.isNotEmpty || selectedTerms.isNotEmpty || selectedAccounts.isNotEmpty)
//                 'filters': {
//                   if (selectedVendors.isNotEmpty) 'vendors': selectedVendors,
//                   if (selectedSessions.isNotEmpty) 'sessions': selectedSessions,
//                   if (selectedTerms.isNotEmpty) 'terms': selectedTerms,
//                   if (selectedAccounts.isNotEmpty) 'accounts': selectedAccounts,
//                 },
//             };
//           });
//           _loadData();
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final summary = expenditureData?['summary'] ?? {};
//     final chartData = expenditureData?['chart_data'] ?? [];
//     final transactions = expenditureData?['transactions'] ?? [];

//     return Container(
//       decoration: Constants.customBoxDecoration(context),
//       child: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Termly Report and Filter
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Container(
//                       height: 50,
//                       decoration: BoxDecoration(
//                         color: const Color.fromRGBO(209, 219, 255, 1).withOpacity(0.35),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Expenditure Report',
//                             style: AppTextStyles.normal500(fontSize: 14, color: AppColors.backgroundDark),
//                           ),
//                           GestureDetector(
//                             onTap: () => showFilterOverlay(context),
//                             child: SvgPicture.asset(
//                               'assets/icons/profile/filter_icon.svg',
//                               height: 24,
//                               width: 24,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   // Summary Card
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Card(
//                       elevation: 4,
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Total Amount: ₦${summary['total_amount']?.toStringAsFixed(2) ?? '0.00'}',
//                               style: AppTextStyles.normal600(fontSize: 18, color: AppColors.backgroundDark),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Total Transactions: ${summary['total_transactions'] ?? 0}',
//                               style: AppTextStyles.normal500(fontSize: 14, color: Colors.grey),
//                             ),
//                             Text(
//                               'Unique Vendors: ${summary['unique_vendors'] ?? 0}',
//                               style: AppTextStyles.normal500(fontSize: 14, color: Colors.grey),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   // Daily Payments Section
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           groupBy == 'vendor' ? 'Payments by Vendor' : groupBy == 'account' ? 'Payments by Account' : 'Daily Payments',
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                         ),
//                         const SizedBox(height: 16),
//                         SizedBox(
//                           height: 300,
//                           child: BarChart(
//                             BarChartData(
//                               alignment: BarChartAlignment.spaceAround,
//                               maxY: (chartData.isNotEmpty
//                                       ? chartData.map((e) => e['y'] as double).reduce((a, b) => a > b ? a : b) * 1.2
//                                       : 10000)
//                                   .toDouble(),
//                               barTouchData: BarTouchData(enabled: true),
//                               titlesData: FlTitlesData(
//                                 show: true,
//                                 bottomTitles: AxisTitles(
//                                   sideTitles: SideTitles(
//                                     showTitles: true,
//                                     getTitlesWidget: (value, meta) {
//                                       if (value.toInt() >= chartData.length) return const SizedBox();
//                                       final label = chartData[value.toInt()]['x'].toString();
//                                       return Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Text(
//                                           label.length > 10 ? '${label.substring(0, 10)}...' : label,
//                                           style: const TextStyle(fontSize: 12),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                                 leftTitles: AxisTitles(
//                                   sideTitles: SideTitles(
//                                     showTitles: true,
//                                     reservedSize: 40,
//                                     getTitlesWidget: (value, meta) {
//                                       return Text(
//                                         '${(value / 1000).toInt()}k',
//                                         style: const TextStyle(fontSize: 12),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                                 rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                 topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                               ),
//                               gridData: FlGridData(
//                                 show: true,
//                                 horizontalInterval: (chartData.isNotEmpty
//                                         ? chartData.map((e) => e['y'] as double).reduce((a, b) => a > b ? a : b) / 5
//                                         : 5000)
//                                     .toDouble(),
//                                 drawVerticalLine: false,
//                               ),
//                               borderData: FlBorderData(show: false),
//                               barGroups: List.generate(
//                                 chartData.length,
//                                 (index) => BarChartGroupData(
//                                   x: index,
//                                   barRods: [
//                                     BarChartRodData(
//                                       toY: chartData[index]['y'].toDouble(),
//                                       color: const Color.fromRGBO(209, 219, 255, 1),
//                                       width: 20,
//                                       borderRadius: BorderRadius.circular(4),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Payments Distribution Section
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Payments Distributed by ${groupBy == 'vendor' ? 'Vendor' : 'Account'}',
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                         ),
//                         const SizedBox(height: 16),
//                         SizedBox(
//                           height: 200,
//                           child: PieChart(
//                             PieChartData(
//                               sections: transactions.isNotEmpty
//                                   ? transactions.asMap().entries.map((entry) {
//                                       final index = entry.key;
//                                       final data = entry.value;
//                                       const colors = [
//                                         Color.fromRGBO(209, 219, 255, 1),
//                                         Color(0xFF34A853),
//                                         Color(0xFFFBBC05),
//                                         Color(0xFFEA4335),
//                                         Color(0xFF4285F4),
//                                       ];
//                                       return PieChartSectionData(
//                                         value: data['total_amount'].toDouble(),
//                                         color: colors[index % colors.length],
//                                         title: '₦${data['total_amount'].toStringAsFixed(0)}',
//                                         radius: 50,
//                                         titleStyle: const TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black,
//                                         ),
//                                       );
//                                     }).toList()
//                                   : [
//                                       PieChartSectionData(
//                                         value: 1,
//                                         color: Colors.grey,
//                                         title: 'No Data',
//                                         radius: 50,
//                                         titleStyle: const TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                     ],
//                               sectionsSpace: 0,
//                               centerSpaceRadius: 40,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Leaderboard Section
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Leaderboard',
//                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                         ),
//                         const SizedBox(height: 16),
//                         transactions.isEmpty
//                             ? const Center(child: Text('No data available'))
//                             : ListView.builder(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemCount: transactions.length > 5 ? 5 : transactions.length,
//                                 itemBuilder: (context, index) {
//                                   final item = transactions[index];
//                                   return Padding(
//                                     padding: const EdgeInsets.only(bottom: 12.0),
//                                     child: Row(
//                                       children: [
//                                         Text(
//                                           '${index + 1}',
//                                           style: TextStyle(
//                                             color: index == 0
//                                                 ? const Color(0xFF4285F4)
//                                                 : index == 1
//                                                     ? const Color(0xFFEA4335)
//                                                     : Colors.grey,
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 16),
//                                         Expanded(
//                                           child: Text(
//                                             item['name'] ?? 'Unknown',
//                                             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                         Text(
//                                           '₦${item['total_amount']?.toStringAsFixed(2) ?? '0.00'}',
//                                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

// // Reuse FilterBottomSheet and MultiSelectBottomSheet from report_payment_screen.dart
// class FilterBottomSheet extends StatefulWidget {
//   final String reportType;
//   final String? groupBy;
//   final String? customType;
//   final String? startDate;
//   final String? endDate;
//   final List<int> selectedVendors;
//   final List<int> selectedSessions;
//   final List<int> selectedTerms;
//   final List<int> selectedAccounts;
//   final List<Map<String, dynamic>> vendors;
//   final List<Map<String, dynamic>> accounts;
//   final Function(Map<String, dynamic>) onApply;

//   const FilterBottomSheet({
//     super.key,
//     required this.reportType,
//     this.groupBy,
//     this.customType,
//     this.startDate,
//     this.endDate,
//     required this.selectedVendors,
//     required this.selectedSessions,
//     required this.selectedTerms,
//     required this.selectedAccounts,
//     required this.vendors,
//     required this.accounts,
//     required this.onApply,
//   });

//   @override
//   _FilterBottomSheetState createState() => _FilterBottomSheetState();
// }

// class _FilterBottomSheetState extends State<FilterBottomSheet> {
//   late String _reportType;
//   String? _groupBy;
//   String? _customType;
//   DateTime? _startDate;
//   DateTime? _endDate;
//   late List<int> _selectedVendors;
//   late List<int> _selectedSessions;
//   late List<int> _selectedTerms;
//   late List<int> _selectedAccounts;

//   @override
//   void initState() {
//     super.initState();
//     _reportType = widget.reportType;
//     _groupBy = widget.groupBy;
//     _customType = widget.customType;
//     _startDate = widget.startDate != null ? DateTime.parse(widget.startDate!) : null;
//     _endDate = widget.endDate != null ? DateTime.parse(widget.endDate!) : null;
//     _selectedVendors = List.from(widget.selectedVendors);
//     _selectedSessions = List.from(widget.selectedSessions);
//     _selectedTerms = List.from(widget.selectedTerms);
//     _selectedAccounts = List.from(widget.selectedAccounts);
//   }

//   void _showMultiSelectBottomSheet(String type, List items, List<int> selectedItems, Function(List<int>) onSave) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => MultiSelectBottomSheet(
//         title: 'Select $type',
//         items: items,
//         selectedItems: selectedItems,
//         onSave: onSave,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.7,
//       maxChildSize: 0.9,
//       minChildSize: 0.5,
//       builder: (context, scrollController) => Container(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           controller: scrollController,
//           children: [
//             const Text('Filter Options', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 16),
//             DropdownButton<String>(
//               value: _reportType,
//               items: ['monthly', 'termly', 'session', 'custom'].map((type) {
//                 return DropdownMenuItem(value: type, child: Text(type.capitalize()));
//               }).toList(),
//               onChanged: (value) => setState(() => _reportType = value!),
//             ),
//             if (_reportType == 'custom') ...[
//               DropdownButton<String>(
//                 value: _customType,
//                 hint: const Text('Select Custom Type'),
//                 items: ['last_30_days', 'last_month', 'range'].map((type) {
//                   return DropdownMenuItem(value: type, child: Text(type.replaceAll('_', ' ').capitalize()));
//                 }).toList(),
//                 onChanged: (value) => setState(() => _customType = value),
//               ),
//               if (_customType == 'range') ...[
//                 ListTile(
//                   title: Text('Start Date: ${_startDate?.toIso8601String().substring(0, 10) ?? 'Select'}'),
//                   onTap: () async {
//                     final date = await showDatePicker(
//                       context: context,
//                       initialDate: _startDate ?? DateTime.now(),
//                       firstDate: DateTime(2020),
//                       lastDate: DateTime(2030),
//                     );
//                     if (date != null) setState(() => _startDate = date);
//                   },
//                 ),
//                 ListTile(
//                   title: Text('End Date: ${_endDate?.toIso8601String().substring(0, 10) ?? 'Select'}'),
//                   onTap: () async {
//                     final date = await showDatePicker(
//                       context: context,
//                       initialDate: _endDate ?? DateTime.now(),
//                       firstDate: DateTime(2020),
//                       lastDate: DateTime(2030),
//                     );
//                     if (date != null) setState(() => _endDate = date);
//                   },
//                 ),
//               ],
//             ],
//             DropdownButton<String>(
//               value: _groupBy,
//               hint: const Text('Group By'),
//               items: ['vendor', 'account', 'month'].map((type) {
//                 return DropdownMenuItem(value: type, child: Text(type.capitalize()));
//               }).toList(),
//               onChanged: (value) => setState(() => _groupBy = value),
//             ),
//             ListTile(
//               title: Text('Vendors: ${_selectedVendors.length} selected'),
//               onTap: () => _showMultiSelectBottomSheet(
//                 'Vendors',
//                 widget.vendors,
//                 _selectedVendors,
//                 (selected) => setState(() => _selectedVendors = selected),
//               ),
//             ),
//             ListTile(
//               title: Text('Sessions: ${_selectedSessions.length} selected'),
//               onTap: () => _showMultiSelectBottomSheet(
//                 'Sessions',
//                 List.generate(5, (index) => 2025 - index),
//                 _selectedSessions,
//                 (selected) => setState(() => _selectedSessions = selected),
//               ),
//             ),
//             ListTile(
//               title: Text('Terms: ${_selectedTerms.length} selected'),
//               onTap: () => _showMultiSelectBottomSheet(
//                 'Terms',
//                 [1, 2, 3],
//                 _selectedTerms,
//                 (selected) => setState(() => _selectedTerms = selected),
//               ),
//             ),
//             ListTile(
//               title: Text('Accounts: ${_selectedAccounts.length} selected'),
//               onTap: () => _showMultiSelectBottomSheet(
//                 'Accounts',
//                 widget.accounts,
//                 _selectedAccounts,
//                 (selected) => setState(() => _selectedAccounts = selected),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 widget.onApply({
//                   'reportType': _reportType,
//                   'groupBy': _groupBy,
//                   'customType': _customType,
//                   'startDate': _startDate?.toIso8601String().substring(0, 10),
//                   'endDate': _endDate?.toIso8601String().substring(0, 10),
//                   'vendors': _selectedVendors,
//                   'sessions': _selectedSessions,
//                   'terms': _selectedTerms,
//                   'accounts': _selectedAccounts,
//                 });
//                 Navigator.pop(context);
//               },
//               child: const Text('Apply Filters'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MultiSelectBottomSheet extends StatefulWidget {
//   final String title;
//   final List items;
//   final List<int> selectedItems;
//   final Function(List<int>) onSave;

//   const MultiSelectBottomSheet({
//     super.key,
//     required this.title,
//     required this.items,
//     required this.selectedItems,
//     required this.onSave,
//   });

//   @override
//   _MultiSelectBottomSheetState createState() => _MultiSelectBottomSheetState();
// }

// class _MultiSelectBottomSheetState extends State<MultiSelectBottomSheet> {
//   late List<int> _selectedItems;

//   @override
//   void initState() {
//     super.initState();
//     _selectedItems = List.from(widget.selectedItems);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.7,
//       maxChildSize: 0.9,
//       minChildSize: 0.5,
//       builder: (context, scrollController) => Container(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             Expanded(
//               child: ListView.builder(
//                 controller: scrollController,
//                 itemCount: widget.items.length,
//                 itemBuilder: (context, index) {
//                   final item = widget.items[index];
//                   final id = item is Map ? item['id'] : item;
//                   final name = item is Map ? item['vendor_name'] ?? item['account_name'] ?? item.toString() : item.toString();
//                   return CheckboxListTile(
//                     title: Text(name),
//                     value: _selectedItems.contains(id),
//                     onChanged: (value) {
//                       setState(() {
//                         if (value == true) {
//                           _selectedItems.add(id);
//                         } else {
//                           _selectedItems.remove(id);
//                         }
//                       });
//                     },
//                   );
//                 },
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 widget.onSave(_selectedItems);
//                 Navigator.pop(context);
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Extension to capitalize strings
// extension StringExtension on String {
//   String capitalize() {
//     return "${this[0].toUpperCase()}${substring(1)}";
//   }
// }