// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/portal/profile/receipt/reciept_payment_detail.dart';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen>
    with SingleTickerProviderStateMixin {
  late double opacity;
  bool _isOverlayVisible = false;
  late TabController _tabController;
  int _currentTabIndex = 0;
  String _selectedDateRange = 'Custom';
  String _selectedGrouping = 'Month';
  String _selectedLevel = 'JSS1';
  String _selectedClass = 'JSS1A';
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Receipts',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: Constants.customBoxDecoration(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isOverlayVisible = true;
                              });
                            },
                            child: const Row(
                              children: [
                                Text('February 2023'),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                          const Row(
                            children: [
                              Text('2023/2024 3rd Term'),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(47, 85, 221, 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Amount Received',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          198, 210, 255, 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text('7 payments'),
                                  ),
                                ],
                              ),
                              const Text(
                                '234,790.00',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    switch (value.toInt()) {
                                      case 0:
                                        return const Text('Basic');
                                      case 1:
                                        return const Text('JSS');
                                      case 2:
                                        return const Text('SSS');
                                      default:
                                        return const Text('');
                                    }
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            minX: 0,
                            maxX: 2,
                            minY: 0,
                            maxY: 6,
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  const FlSpot(0, 3),
                                  const FlSpot(1, 1),
                                  const FlSpot(2, 4),
                                ],
                                isCurved: true,
                                color: const Color.fromRGBO(47, 85, 221, 1),
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color:
                                      const Color.fromRGBO(47, 85, 221, 0.102),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Payment History',
                              style: AppTextStyles.normal600(
                                  fontSize: 18,
                                  color: AppColors.backgroundDark)),
                          const Text(
                            'See all',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Color.fromRGBO(47, 85, 221, 1),
                                fontSize: 16.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      _buildPaymentHistoryItem(
                          'JSS', '234,700.00', 'Joseph Raphael'),
                      _buildPaymentHistoryItem(
                          'SS', '189,500.00', 'Maria Johnson'),
                      _buildPaymentHistoryItem(
                          'JSS', '276,300.00', 'John Smith'),
                      _buildPaymentHistoryItem(
                          'SS', '205,800.00', 'Emma Davis'),
                      _buildPaymentHistoryItem(
                          'JSS', '298,100.00', 'Michael Brown'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isOverlayVisible) _buildCustomOverlay(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
          color: AppColors.backgroundLight,
        ),
        backgroundColor: AppColors.videoColor4,
        onPressed: () {},
      ),
    );
  }

  Widget _buildCustomOverlay() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isOverlayVisible = false;
        });
      },
      child: Container(
        color: Colors.black54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {},
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      _buildTabBar(),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildDateRangeTab(),
                            _buildGroupingTab(),
                            _buildFilterTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.grey[200],
      child: TabBar(
        controller: _tabController,
        tabs: [
          const Tab(text: 'Date Range'),
          const Tab(text: 'Grouping'),
          const Tab(text: 'Filter'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTabIndex) {
      case 0:
        return _buildDateRangeTab();
      case 1:
        return _buildGroupingTab();
      case 2:
        return _buildFilterTab();
      default:
        return Container();
    }
  }

  Widget _buildDateRangeTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeOptions(),
          const SizedBox(height: 20),
          if (_selectedDateRange == 'Custom') _buildCustomDateRange(),
        ],
      ),
    );
  }

  Widget _buildDateRangeOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['Custom', 'Today', 'Yesterday', 'This Week'].map((option) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDateRange = option;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _selectedDateRange == option
                  ? const Color.fromRGBO(47, 85, 221, 1)
                  : const Color.fromRGBO(212, 222, 255, 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              option,
              style: TextStyle(
                color:
                    _selectedDateRange == option ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomDateRange() {
    return Column(
      children: [
        _buildDateInput('From:', _fromDate, (date) {
          setState(() {
            _fromDate = date;
          });
        }),
        const SizedBox(height: 10),
        _buildDateInput('To:', _toDate, (date) {
          setState(() {
            _toDate = date;
          });
        }),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Generate report logic
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
          ),
          child: Text(
            'Generate Report',
            style: AppTextStyles.normal500(
                fontSize: 18, color: AppColors.backgroundLight),
          ),
        ),
      ],
    );
  }

  Widget _buildDateInput(
      String label, DateTime initialDate, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2025),
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${initialDate.day}-${initialDate.month}-${initialDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                SvgPicture.asset('assets/icons/profile/calender_icon.svg'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupingTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Group by:',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          _buildGroupingOption('Month'),
          _buildGroupingOption('Vendor'),
          _buildGroupingOption('Account'),
          const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Generate report logic
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
            minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
          ),
          child: Text(
            'Generate Report',
            style: AppTextStyles.normal500(
                fontSize: 18, color: AppColors.backgroundLight),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildGroupingOption(String option) {
    return Container(
      width: double.infinity,
      height: 42,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Color.fromRGBO(229, 229, 229, 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(option),
      ),
    );
  }

  Widget _buildFilterTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by:',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          _buildFilterOption('Level', ['JSS1', 'JSS2', 'JSS3'], _selectedLevel,
              (value) {
            setState(() {
              _selectedLevel = value;
            });
          }),
          const SizedBox(height: 10),
          _buildFilterOption(
              'Class', ['JSS1A', 'JSS1B', 'JSS1C'], _selectedClass, (value) {
            setState(() {
              _selectedClass = value;
            });
          }),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Generate report logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
            ),
            child: Text(
              'Generate Report',
              style: AppTextStyles.normal500(
                  fontSize: 18, color: AppColors.backgroundLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, List<String> options,
      String selectedValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(229, 229, 229, 1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButton<String>(
            value: selectedValue,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistoryItem(String grade, String amount, String name) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentReceiptDetailScreen(
              grade: grade,
              amount: amount,
              name: name,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/icons/profile/payment_icon.svg'),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: AppTextStyles.normal600(
                        fontSize: 18, color: AppColors.backgroundDark),
                  ),
                ],
              ),
              Text(amount,
                  style: AppTextStyles.normal700(
                      fontSize: 18,
                      color: const Color.fromRGBO(47, 85, 221, 1))),
            ],
          ),
        ),
      ),
    );
  }
}