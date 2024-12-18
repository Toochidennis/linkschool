import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/admin_portal/payment/expenditure/add_expenditure_screen.dart';
import 'package:linkschool/modules/admin_portal/payment/expenditure/expense_history.dart';
import 'package:linkschool/modules/admin_portal/payment/receipt/generate_report/report_payment.dart';


class ExpenditureScreen extends StatefulWidget {
  const ExpenditureScreen({super.key});

  @override
  State<ExpenditureScreen> createState() => _ExpenditureScreenState();
}

class _ExpenditureScreenState extends State<ExpenditureScreen>
    with TickerProviderStateMixin {
  late double opacity;

  bool _isOverlayVisible = false;
  late TabController _tabController;
  int _currentTabIndex = 0;
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  int _selectedReportType = 0;
  String _selectedDateRange = 'Custom';
  String _selectedGrouping = 'Month';
  String _selectedLevel = 'JSS1';
  String _selectedClass = 'JSS1A';
    bool _isAmountHidden = false;

  final List<String> reportTypes = [
    'Termly report',
    'Session report',
    'Monthly report',
    'Class report',
    'Level report'
  ];
  final List<String> dateRangeOptions = [
    'Custom',
    'Today',
    'Yesterday',
    'This Week',
    'Last 7 days',
    'Last 30 days'
  ];

  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _buttonAnimation;
  late Animation<double> _animation;

  final List<Map<String, dynamic>> _fabButtons = [
    {
      'title': 'Setup report',
      'icon': 'assets/icons/profile/setup_report.svg',
      'onPressed': null,
    },
    {
      'title': 'Add expenditure',
      'icon': 'assets/icons/profile/add_receipt.svg',
      'onPressed': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _buttonAnimation = Tween<double>(begin: 0, end: 1).animate(_animation);

    // Initialize FAB button actions
    _fabButtons[0]['onPressed'] = () {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return _buildCustomOverlay();
        },
      );
    };

    _fabButtons[1]['onPressed'] = () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddExpenditureScreen(),
        ),
      );
    };
  }

  void _onFromDateChanged(DateTime date) {
    setState(() {
      _fromDate = date;
    });
  }

  void _onToDateChanged(DateTime date) {
    setState(() {
      _toDate = date;
    });
  }

// Add these methods to the _ExpenditureScreenState class

  void _showMonthYearPicker() {
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
                    'Select Month and Year',
                    style: AppTextStyles.normal600(
                      fontSize: 20,
                      color: const Color.fromRGBO(47, 85, 221, 1),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildMonthYearItem('January 2023'),
                      _buildMonthYearItem('February 2023'),
                      _buildMonthYearItem('March 2023'),
                      // Add more months
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSessionTermPicker() {
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
                      _buildSessionTermItem('2023/2024 1st Term'),
                      _buildSessionTermItem('2023/2024 2nd Term'),
                      _buildSessionTermItem('2023/2024 3rd Term'),
                      _buildSessionTermItem('2022/2023 3rd Term'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
            color: AppColors.paymentTxtColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Expenditures',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.paymentTxtColor1,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return _buildCustomOverlay();
                },
              );
            },
            icon: SvgPicture.asset(
              'assets/icons/profile/filter_icon.svg',
              color: Color.fromRGBO(47, 85, 221, 1),
            ),
          ),
        ],

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
                            onTap: _showMonthYearPicker,
                            child: Row(
                              children: [
                                const Text('February 2023'),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _showSessionTermPicker,
                            child: Row(
                              children: [
                                const Text('2023/2024 3rd Term'),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 118,
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
                                  Row(
                                    children: [
                                      Text(
                                        'Total Expenses',
                                        style: AppTextStyles.normal600(fontSize: 14, color: AppColors.backgroundLight),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _isAmountHidden
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isAmountHidden = !_isAmountHidden;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          198, 210, 255, 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child:  Text('7 payments', style: AppTextStyles.normal500(fontSize: 12, color: AppColors.paymentTxtColor1),),
                                  ),
                                ],
                              ),
                              Text(
                                _isAmountHidden ? '********' : '234,790.00',
                                    style: AppTextStyles.normal700(fontSize: 24, color: AppColors.backgroundLight),     
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
                                color: AppColors.videoColor4,
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
                          Text('Expense History',
                              style: AppTextStyles.normal600(
                                  fontSize: 18,
                                  color: AppColors.backgroundDark)),
                          GestureDetector(
                            onTap: () {
                              // Navigate to the report_payment screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ReportPaymentScreen()),
                              );
                            },
                            child: const Text(
                              'See all',
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Color.fromRGBO(47, 85, 221, 1),
                                  fontSize: 16.0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildExpenseHistoryItem(
                          'JSS', 234700.00, 'Joseph Raphael'),
                      _buildExpenseHistoryItem(
                          'SS', 189500.00, 'Maria Johnson'),
                      _buildExpenseHistoryItem(
                          'JSS', 276300.00, 'John Smith'),
                      _buildExpenseHistoryItem(
                          'SS', 205800.00, 'Emma Davis'),
                      _buildExpenseHistoryItem(
                          'JSS', 298100.00, 'Michael Brown'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _buttonAnimation,
        builder: (context, child) => _buildAnimatedFAB(),
      ),
    );
  }

  Widget _buildAnimatedFAB() {
    final bool showLabels = _buttonAnimation.value == 1;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isExpanded) ...[
          ..._fabButtons.map((button) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showLabels)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(47, 85, 221, 1),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          button['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ),
                  FloatingActionButton(
                    heroTag: button['title'],
                    mini: true,
                    onPressed: button['onPressed'],
                    backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
                    child: SvgPicture.asset(button['icon']),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
        FloatingActionButton(
          backgroundColor: AppColors.videoColor4,
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
              if (_isExpanded) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            });
          },
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 300),
            turns: _isExpanded ? 0.125 : 0,
            child: SvgPicture.asset(
              _isExpanded
                  ? 'assets/icons/profile/inverted_add_icon.svg'
                  : 'assets/icons/profile/add_icon.svg',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseHistoryItem(String grade, double amount, String name) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseHistoryScreen(
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
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          leading: SvgPicture.asset('assets/icons/profile/payment_icon.svg'),
          title: Text(
            name,
            style: AppTextStyles.normal600(
                fontSize: 18, color: AppColors.backgroundDark),
          ),
          subtitle: Text(
            '07-03-2018  17:23',
            style: AppTextStyles.normal500(fontSize: 12, color: AppColors.text10Light),
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '-$amount',
                style: AppTextStyles.normal700(fontSize: 18, color: Colors.red),
              ),

              const SizedBox(height: 4),
              Text(
                'Clinic medication',
                style: AppTextStyles.normal500(fontSize: 12, color: AppColors.text10Light),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportTypeTab(String text, int index) {
    return Container(
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: reportTypes.map((type) {
            int typeIndex = reportTypes.indexOf(type);
            bool isSelected = _selectedReportType == typeIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedReportType = typeIndex;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color.fromRGBO(228, 234, 255, 1)
                        : const Color.fromRGBO(247, 247, 247, 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: isSelected
                          ? const Color.fromRGBO(47, 85, 221, 1)
                          : const Color(0xFF414141),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterByTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterButton('Session'),
          const SizedBox(height: 12),
          _buildFilterButton('Term'),
          const SizedBox(height: 12),
          _buildFilterButton('Class'),
          const SizedBox(height: 12),
          _buildFilterButton('Level'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text) {
    return Container(
      width: double.infinity,
      height: 42,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(229, 229, 229, 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(text),
      ),
    );
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: dateRangeOptions.map((option) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDateRange = option;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedDateRange == option
                      ? const Color.fromRGBO(47, 85, 221, 1)
                      : const Color.fromRGBO(212, 222, 255, 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: _selectedDateRange == option
                        ? Colors.white
                        : AppColors.paymentTxtColor1,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomDateRange() {
    return Column(
      children: [
        _buildDateInput('From:', _fromDate, _onFromDateChanged),
        const SizedBox(height: 10),
        _buildDateInput('To:', _toDate, _onToDateChanged),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDateInput(
      String label, DateTime selectedDate, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2025),
            );
            if (picked != null) {
              onDateSelected(picked);
              if (mounted) {
                setState(() {});
              }
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
                  '${selectedDate.day}-${selectedDate.month}-${selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.paymentTxtColor1,
                  size: 24,
                ),
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
          _buildGroupingOption('Level'),
          _buildGroupingOption('Class'),
          _buildGroupingOption('Month'),
          // const SizedBox(height: 20),
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
        color: const Color.fromRGBO(229, 229, 229, 1),
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
          // const SizedBox(height: 20),
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

  Widget _buildCustomOverlay() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        // color: Colors.black54,
        child: GestureDetector(
          onTap: () {}, // Prevents taps from propagating
          child: Container(
            height: MediaQuery.of(context).size.height * 0.60,
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.2,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [

                // Report Type TabBar
                Container(
                  height: 120,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildReportTypeTabRow(reportTypes.sublist(0, 5)),
                        SizedBox(height: 8),
                        _buildReportTypeTabRow(reportTypes.sublist(0, 5)),
                      ],
                    ),
                  ),
                ),
                // Main TabBar and Content
                Expanded(
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                          child: TabBar(
                            onTap: (index) {
                              setState(() {
                                _currentTabIndex = index;
                              });
                            },
                            tabs: const [
                              Tab(text: 'Date Range'),
                              Tab(text: 'Grouping'),
                              Tab(text: 'Filter by'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildDateRangeTab(),
                              _buildGroupingTab(),
                              _buildFilterByTab(),
                            ],
                          ),
                        ),
                        // Fixed Generate Report Button
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ReportPaymentScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(47, 85, 221, 1),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text(
                              'Generate Report',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportTypeTabRow(List<String> types) {
    return Row(
      children: types.map((type) {
        int typeIndex = reportTypes.indexOf(type);
        bool isSelected = _selectedReportType == typeIndex;
        return Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedReportType = typeIndex;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Color.fromRGBO(228, 234, 255, 1)
                    : Color.fromRGBO(247, 247, 247, 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                type,
                style: TextStyle(
                  color: isSelected
                      ? const Color.fromRGBO(47, 85, 221, 1)
                      : Color.fromRGBO(65, 65, 65, 1),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Widget _buildCustomOverlay() {
  //   return GestureDetector(
  //     onTap: () => Navigator.pop(context),
  //     child: Container(
  //       color: Colors.black54,
  //       child: GestureDetector(
  //         onTap: () {}, // Prevents taps from propagating
  //         child: Container(
  //           height: MediaQuery.of(context).size.height * 0.58,
  //           margin: EdgeInsets.only(
  //             top: MediaQuery.of(context).size.height * 0.2,
  //           ),
  //           decoration: const BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //           ),
  //           child: Column(
  //             children: [
  //               // Report Type TabBar
  //               Container(
  //                 padding:
  //                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                   children: [
  //                     _buildReportTypeTab('Termly report', 0),
  //                     _buildReportTypeTab('Session report', 1),
  //                     _buildReportTypeTab('Monthly report', 2),
  //                   ],
  //                 ),
  //               ),
  //               // Main TabBar and Content
  //               Expanded(
  //                 child: DefaultTabController(
  //                   length: 3,
  //                   child: Column(
  //                     children: [
  //                       Container(
  //                         decoration: BoxDecoration(
  //                           color: Colors.grey[200],
  //                         ),
  //                         child: TabBar(
  //                           onTap: (index) {
  //                             setState(() {
  //                               _currentTabIndex = index;
  //                             });
  //                           },
  //                           tabs: const [
  //                             Tab(text: 'Date Range'),
  //                             Tab(text: 'Grouping'),
  //                             Tab(text: 'Filter by'),
  //                           ],
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: TabBarView(
  //                           children: [
  //                             _buildDateRangeTab(),
  //                             _buildGroupingTab(),
  //                             _buildFilterByTab(),
  //                           ],
  //                         ),
  //                       ),
  //                       // Fixed Generate Report Button
  //                       Container(
  //                         padding: const EdgeInsets.all(16),
  //                         decoration: BoxDecoration(
  //                           color: Colors.white,
  //                           boxShadow: [
  //                             BoxShadow(
  //                               color: Colors.grey.withOpacity(0.2),
  //                               spreadRadius: 1,
  //                               blurRadius: 4,
  //                               offset: const Offset(0, -2),
  //                             ),
  //                           ],
  //                         ),
  //                         child: ElevatedButton(
  //                           onPressed: () {
  //                             Navigator.push(
  //                               context,
  //                               MaterialPageRoute(
  //                                 builder: (context) =>
  //                                     const ReportPaymentScreen(),
  //                               ),
  //                             );
  //                           },
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor:
  //                                 const Color.fromRGBO(47, 85, 221, 1),
  //                             minimumSize: const Size(double.infinity, 50),
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(10.0),
  //                             ),
  //                           ),
  //                           child: const Text(
  //                             'Generate Report',
  //                             style: TextStyle(
  //                               color: Colors.white,
  //                               fontSize: 18,
  //                               fontWeight: FontWeight.w500,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMonthYearItem(String text) {
    return ListTile(
      title: Text(text),
      onTap: () {
        // Update selected month/year
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSessionTermItem(String text) {
    return ListTile(
      title: Text(text),
      onTap: () {
        // Update selected session/term
        Navigator.pop(context);
      },
    );
  }
}
