import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/admin/payment/expenditure/add_expenditure_screen.dart';
import 'package:linkschool/modules/admin/payment/expenditure/expenditure_report_payment_screen.dart';
import 'package:linkschool/modules/admin/payment/expenditure/expense_history.dart';
import 'package:linkschool/modules/admin/payment/receipt/generate_report/report_payment.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/admin/vendor/vendor_model.dart';
import 'package:linkschool/modules/services/admin/payment/account_service.dart';
import 'package:linkschool/modules/services/admin/payment/vendor_service.dart';
import 'package:linkschool/modules/services/admin/payment/expenditure_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class ExpenditureScreen extends StatefulWidget {
  const ExpenditureScreen({super.key});

  @override
  State<ExpenditureScreen> createState() => _ExpenditureScreenState();
}

class _ExpenditureScreenState extends State<ExpenditureScreen> with TickerProviderStateMixin {
  late double opacity;
  late TabController _tabController;
  int _currentTabIndex = 0;
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  int _selectedReportType = 0;
  String _selectedDateRange = 'Custom';
  final String _selectedGrouping = 'Month';
  String _selectedLevel = 'JSS1';
  String _selectedClass = 'JSS1A';
  bool _isAmountHidden = false;
  final VendorService _vendorService = locator<VendorService>();
  final ExpenditureService _expenditureService = locator<ExpenditureService>();

  // Server data state
  Map<String, dynamic>? _expenditureData;
  bool _isDataLoading = false;
  String _db = '';

  // Filter state
  String _reportType = 'monthly';
  String? _groupBy;
  String? _customType;
  String? _startDate;
  String? _endDate;
  Map<String, List<dynamic>> _filters = {};
  List<Map<String, dynamic>> _vendors = [];
  List<Map<String, dynamic>> _accounts = [];

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
    _initializeData();
    _fetchVendors();
    _fetchAccounts();
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

    _fabButtons[1]['onPressed'] = () async {
      final response = await _vendorService.fetchVendors();
      if (response.success && response.data != null && response.data!.isNotEmpty) {
        final selectedVendor = response.data![0];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddExpenditureScreen(vendor: selectedVendor),
          ),
        );
      } else {
        CustomToaster.toastError(context, 'Error', 'No vendors available');
      }
    };

    _fetchExpenditureData();
  }

  void _initializeData() {
    final userBox = Hive.box('userData');
    _db = userBox.get('_db') ?? '';
    if (_db.isEmpty) {
      CustomToaster.toastError(context, 'Error', 'No database configuration found');
    }
  }

  Future<void> _fetchVendors() async {
    try {
      final response = await _vendorService.fetchVendors();
      if (response.success && response.data != null) {
        setState(() {
          _vendors = response.data!.map((vendor) => {
            'id': vendor.id,
            'vendor_name': vendor.vendorName,
          }).toList();
        });
      }
    } catch (e) {
      CustomToaster.toastError(context, 'Error', 'Failed to load vendors: $e');
    }
  }

  Future<void> _fetchAccounts() async {
    try {
      final response = await locator<AccountService>().fetchAccounts();
      if (response.success && response.data != null && response.data!.data != null) {
        setState(() {
          _accounts = response.data!.data.map((account) => {
            'id': account.id,
            'account_name': account.accountName,
          }).toList();
        });
      }
    } catch (e) {
      CustomToaster.toastError(context, 'Error', 'Failed to load accounts: $e');
    }
  }

  Future<void> _fetchExpenditureData() async {
    if (_db.isEmpty) return;
    setState(() => _isDataLoading = true);
    try {
      final payload = {
        'report_type': _reportType,
        '_db': _db,
        if (_groupBy != null) 'group_by': _groupBy,
        if (_customType != null) 'custom_type': _customType,
        if (_startDate != null) 'start_date': _startDate,
        if (_endDate != null) 'end_date': _endDate,
        if (_filters.isNotEmpty) 'filters': _filters,
      };
      final response = await _expenditureService.generateReport(payload);
      if (response.success && response.data != null) {
        setState(() {
          _expenditureData = response.data;
        });
      } else {
        CustomToaster.toastError(context, 'Error', response.message ?? 'Failed to load data');
      }
    } catch (e) {
      CustomToaster.toastError(context, 'Error', 'Failed to load expenditure data: $e');
    } finally {
      setState(() => _isDataLoading = false);
    }
  }

  void _onFromDateChanged(DateTime date) {
    setState(() {
      _fromDate = date;
      _startDate = date.toIso8601String().split('T')[0];
      _fetchExpenditureData();
    });
  }

  void _onToDateChanged(DateTime date) {
    setState(() {
      _toDate = date;
      _endDate = date.toIso8601String().split('T')[0];
      _fetchExpenditureData();
    });
  }

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
                      // Add more months dynamically if needed
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

  Widget _buildMonthYearItem(String text) {
    return ListTile(
      title: Text(text),
      onTap: () {
        // Update selected month/year
        setState(() {
          // Parse text to update state (customize as needed)
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSessionTermItem(String text) {
    return ListTile(
      title: Text(text),
      onTap: () {
        // Update selected session/term
        setState(() {
          // Parse text to update state (customize as needed)
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    final summary = _expenditureData?['summary'] ?? {};
    final chartDataList = _expenditureData?['chart_data'] as List<dynamic>? ?? [];
    final transactionsList = _expenditureData?['transactions'] as List<dynamic>? ?? [];

    // Convert chartDataList to List<FlSpot>
    final List<FlSpot> chartSpots = chartDataList.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value as Map<String, dynamic>;
      final yValue = (data['y'] is int) ? (data['y'] as int).toDouble() : (data['y'] as double?) ?? 0.0;
      // Use index as x-value since date strings can't be used directly
      return FlSpot(index.toDouble(), yValue);
    }).toList();

    // Create labels for bottom axis based on dates
    final List<String> dateLabels = chartDataList.map((data) {
      final dateStr = (data as Map<String, dynamic>)['x']?.toString() ?? '';
      try {
        final date = DateFormat('yyyy-MM-dd').parse(dateStr);
        return DateFormat('MMM d').format(date); // Format as "Sep 11"
      } catch (e) {
        return dateStr;
      }
    }).toList();

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
            onPressed: _isDataLoading
                ? null
                : () {
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
              color: _isDataLoading
                  ? Colors.grey
                  : const Color.fromRGBO(47, 85, 221, 1),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
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
                                Text(_isDataLoading ? 'Loading...' : 'February 2023'),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _showSessionTermPicker,
                            child: Row(
                              children: [
                                Text(_isDataLoading ? 'Loading...' : '2023/2024 3rd Term'),
                                const Icon(Icons.arrow_drop_down),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Total Expenses',
                                        style: AppTextStyles.normal600(
                                            fontSize: 14, color: AppColors.backgroundLight),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _isAmountHidden ? Icons.visibility : Icons.visibility_off,
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
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(198, 210, 255, 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _isDataLoading
                                          ? 'Loading...'
                                          : '${summary['total_transactions'] ?? 0} payments',
                                      style: AppTextStyles.normal500(
                                          fontSize: 12, color: AppColors.paymentTxtColor1),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                _isAmountHidden
                                    ? '********'
                                    : _isDataLoading
                                        ? 'Loading...'
                                        : '₦${summary['total_amount']?.toStringAsFixed(2) ?? '0.00'}',
                                style: AppTextStyles.normal700(
                                    fontSize: 24, color: AppColors.backgroundLight),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _isDataLoading
                            ? const Center(child: CircularProgressIndicator())
                            : chartSpots.isEmpty
                                ? const Center(child: Text('No chart data available'))
                                : LineChart(
                                    LineChartData(
                                      gridData: const FlGridData(show: false),
                                      titlesData: FlTitlesData(
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              final index = value.toInt();
                                              if (index < 0 || index >= dateLabels.length) {
                                                return const Text('');
                                              }
                                              return Text(
                                                dateLabels[index],
                                                style: const TextStyle(fontSize: 10),
                                              );
                                            },
                                            reservedSize: 30,
                                          ),
                                        ),
                                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      minX: 0,
                                      maxX: chartSpots.isNotEmpty ? (chartSpots.length - 1).toDouble() : 2,
                                      minY: 0,
                                      maxY: chartSpots.isNotEmpty
                                          ? chartSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.1
                                          : 6000,
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: chartSpots,
                                          isCurved: true,
                                          color: AppColors.videoColor4,
                                          barWidth: 3,
                                          dotData: const FlDotData(show: false),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            color: const Color.fromRGBO(47, 85, 221, 0.102),
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
                          Text(
                            'Expense History',
                            style: AppTextStyles.normal600(
                                fontSize: 18, color: AppColors.backgroundDark),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExpenditureReportPaymentScreen(
                                    initialParams: {
                                      'report_type': _reportType,
                                      'group_by': _groupBy,
                                      'custom_type': _customType,
                                      'start_date': _startDate,
                                      'end_date': _endDate,
                                      'filters': _filters,
                                      '_db': _db,
                                    },
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'See all',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Color.fromRGBO(47, 85, 221, 1),
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _isDataLoading
                          ? const Center(child: CircularProgressIndicator())
                          : transactionsList.isEmpty
                              ? const Center(child: Text('No transactions available'))
                              : Column(
                                  children: transactionsList.take(5).map((transaction) {
                                    return _buildExpenseHistoryItem(
                                      transaction['name'] ?? 'Unknown',
                                      (transaction['amount'] is int)
                                          ? (transaction['amount'] as int).toDouble()
                                          : (transaction['amount'] as double?) ?? 0.0,
                                      transaction['account_name'] ?? 'Unknown Account',
                                      transaction,
                                    );
                                  }).toList(),
                                ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
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
          }),
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

  Widget _buildExpenseHistoryItem(String name, double amount, String accountName, Map<String, dynamic> transaction) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseHistoryScreen(
              grade: accountName,
              amount: amount,
              name: name,
              transaction: transaction,
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
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          leading: SvgPicture.asset('assets/icons/profile/payment_icon.svg'),
          title: Text(
            name,
            style: AppTextStyles.normal600(fontSize: 18, color: AppColors.backgroundDark),
          ),
          subtitle: Text(
            transaction['date'] ?? '07-03-2018  17:23',
            style: AppTextStyles.normal500(fontSize: 12, color: AppColors.text10Light),
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '-₦${amount.toStringAsFixed(2)}',
                style: AppTextStyles.normal700(fontSize: 18, color: Colors.red),
              ),
              const SizedBox(height: 4),
              Text(
                accountName,
                style: AppTextStyles.normal500(fontSize: 12, color: AppColors.text10Light),
              ),
            ],
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
                _reportType = typeIndex == 0
                    ? 'termly'
                    : typeIndex == 1
                        ? 'session'
                        : typeIndex == 2
                            ? 'monthly'
                            : typeIndex == 3
                                ? 'class'
                                : 'level';
                _fetchExpenditureData();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      : const Color.fromRGBO(65, 65, 65, 1),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
                  _customType = _mapDateRangeToCustomType(option);
                  _fetchExpenditureData();
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

  String? _mapDateRangeToCustomType(String option) {
    switch (option) {
      case 'Today':
        return 'today';
      case 'Yesterday':
        return 'yesterday';
      case 'This Week':
        return 'this_week';
      case 'Last 7 days':
        return 'last_week';
      case 'Last 30 days':
        return 'last_30_days';
      default:
        return null;
    }
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

  Widget _buildDateInput(String label, DateTime selectedDate, Function(DateTime) onDateSelected) {
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
    final groupingOptions = ['Vendor', 'Account', 'Month'];
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
          Wrap(
            spacing: 8,
            children: groupingOptions.map((option) {
              bool isSelected = _groupBy == option.toLowerCase();
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _groupBy = isSelected ? null : option.toLowerCase();
                    _fetchExpenditureData();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color.fromRGBO(47, 85, 221, 1)
                        : const Color.fromRGBO(229, 229, 229, 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
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
          _buildFilterButton('Vendors'),
          const SizedBox(height: 12),
          _buildFilterButton('Accounts'),
          const SizedBox(height: 12),
          _buildFilterButton('Sessions'),
          const SizedBox(height: 12),
          _buildFilterButton('Terms'),
          const SizedBox(height: 12),
          _buildFilterOption('Level', ['JSS1', 'JSS2', 'JSS3'], _selectedLevel, (value) {
            setState(() {
              _selectedLevel = value;
            });
          }),
          const SizedBox(height: 10),
          _buildFilterOption('Class', ['JSS1A', 'JSS1B', 'JSS1C'], _selectedClass, (value) {
            setState(() {
              _selectedClass = value;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text) {
    return GestureDetector(
      onTap: () {
        _showFilterBottomSheet(text.toLowerCase());
      },
      child: Container(
        width: double.infinity,
        height: 42,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(229, 229, 229, 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text('$text: ${_filters[text.toLowerCase()]?.length ?? 0} selected'),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(String filterType) {
    List<dynamic> items = [];
    String title = '';
    switch (filterType) {
      case 'vendors':
        title = 'Select Vendors';
        items = _vendors;
        break;
      case 'accounts':
        title = 'Select Accounts';
        items = _accounts;
        break;
      case 'sessions':
        title = 'Select Sessions';
        final userBox = Hive.box('userData');
        final currentYear = userBox.get('current_year') ?? 2025;
        items = List.generate(currentYear - 1999 + 1, (index) {
          final year = currentYear - index;
          return {'id': year, 'name': '${year - 1}/$year'};
        });
        break;
      case 'terms':
        title = 'Select Terms';
        items = [
          {'id': 1, 'name': 'First Term'},
          {'id': 2, 'name': 'Second Term'},
          {'id': 3, 'name': 'Third Term'},
        ];
        break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => MultiSelectBottomSheet(
        title: title,
        items: items,
        selectedItems: _filters[filterType]?.map((e) => e.toString())?.toList() ?? [],
        onSave: (selected) {
          setState(() {
            _filters[filterType] = selected;
            _fetchExpenditureData();
          });
        },
      ),
    );
  }

  Widget _buildFilterOption(String label, List<String> options, String selectedValue, Function(String) onChanged) {
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
        child: GestureDetector(
          onTap: () {},
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
                Container(
                  height: 120,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        _buildReportTypeTabRow(reportTypes.sublist(0, 3)),
                        const SizedBox(height: 8),
                        _buildReportTypeTabRow(reportTypes.sublist(3, 5)),
                      ],
                    ),
                  ),
                ),
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
                              _buildFilterTab(),
                            ],
                          ),
                        ),
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
                              _fetchExpenditureData();
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportPaymentScreen(
                                    initialParams: {
                                      'report_type': _reportType,
                                      'group_by': _groupBy,
                                      'custom_type': _customType,
                                      'start_date': _startDate,
                                      'end_date': _endDate,
                                      'filters': _filters,
                                      '_db': _db,
                                    },
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
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
}

class MultiSelectBottomSheet extends StatefulWidget {
  final String title;
  final List<dynamic> items;
  final List<String> selectedItems;
  final Function(List<String>) onSave;

  const MultiSelectBottomSheet({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.onSave,
  });

  @override
  State<MultiSelectBottomSheet> createState() => _MultiSelectBottomSheetState();
}

class _MultiSelectBottomSheetState extends State<MultiSelectBottomSheet> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List<String>.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final id = item['id'].toString();
                  final name = item['name'] ?? item['vendor_name'] ?? item['account_name'] ?? '';
                  final isSelected = _selectedItems.contains(id);
                  return CheckboxListTile(
                    title: Text(name),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedItems.add(id);
                        } else {
                          _selectedItems.remove(id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onSave(_selectedItems);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:linkschool/modules/admin/payment/expenditure/add_expenditure_screen.dart';
// import 'package:linkschool/modules/admin/payment/expenditure/expense_history.dart';
// import 'package:linkschool/modules/admin/payment/receipt/generate_report/report_payment.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/custom_toaster.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/model/admin/vendor/vendor_model.dart';
// import 'package:linkschool/modules/services/admin/payment/vendor_service.dart';
// import 'package:linkschool/modules/services/api/service_locator.dart';

// class ExpenditureScreen extends StatefulWidget {
//   const ExpenditureScreen({super.key});

//   @override
//   State<ExpenditureScreen> createState() => _ExpenditureScreenState();
// }

// class _ExpenditureScreenState extends State<ExpenditureScreen> with TickerProviderStateMixin {
//   late double opacity;
//   final bool _isOverlayVisible = false;
//   late TabController _tabController;
//   int _currentTabIndex = 0;
//   DateTime _fromDate = DateTime.now();
//   DateTime _toDate = DateTime.now();
//   int _selectedReportType = 0;
//   String _selectedDateRange = 'Custom';
//   final String _selectedGrouping = 'Month';
//   String _selectedLevel = 'JSS1';
//   String _selectedClass = 'JSS1A';
//   bool _isAmountHidden = false;
//   final VendorService _vendorService = locator<VendorService>();

//   final List<String> reportTypes = [
//     'Termly report',
//     'Session report',
//     'Monthly report',
//     'Class report',
//     'Level report'
//   ];
//   final List<String> dateRangeOptions = [
//     'Custom',
//     'Today',
//     'Yesterday',
//     'This Week',
//     'Last 7 days',
//     'Last 30 days'
//   ];

//   bool _isExpanded = false;
//   late AnimationController _animationController;
//   late Animation<double> _buttonAnimation;
//   late Animation<double> _animation;

//   final List<Map<String, dynamic>> _fabButtons = [
//     {
//       'title': 'Setup report',
//       'icon': 'assets/icons/profile/setup_report.svg',
//       'onPressed': null,
//     },
//     {
//       'title': 'Add expenditure',
//       'icon': 'assets/icons/profile/add_receipt.svg',
//       'onPressed': null,
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _animation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//     _buttonAnimation = Tween<double>(begin: 0, end: 1).animate(_animation);

//     // Initialize FAB button actions
//     _fabButtons[0]['onPressed'] = () {
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent,
//         builder: (BuildContext context) {
//           return _buildCustomOverlay();
//         },
//       );
//     };

//     _fabButtons[1]['onPressed'] = () async {
//       final response = await _vendorService.fetchVendors();
//       if (response.success && response.data != null && response.data!.isNotEmpty) {
//         final selectedVendor = response.data![0]; // Use first vendor or implement selection
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => AddExpenditureScreen(vendor: selectedVendor),
//           ),
//         );
//       } else {
//         CustomToaster.toastError(context, 'Error', 'No vendors available');
//       }
//     };
//   }

//   void _onFromDateChanged(DateTime date) {
//     setState(() {
//       _fromDate = date;
//     });
//   }

//   void _onToDateChanged(DateTime date) {
//     setState(() {
//       _toDate = date;
//     });
//   }

//   void _showMonthYearPicker() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: AppColors.backgroundLight,
//       builder: (BuildContext context) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//           ),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.4,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text(
//                     'Select Month and Year',
//                     style: AppTextStyles.normal600(
//                       fontSize: 20,
//                       color: const Color.fromRGBO(47, 85, 221, 1),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView(
//                     children: [
//                       _buildMonthYearItem('January 2023'),
//                       _buildMonthYearItem('February 2023'),
//                       _buildMonthYearItem('March 2023'),
//                       // Add more months
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showSessionTermPicker() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: AppColors.backgroundLight,
//       builder: (BuildContext context) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//           ),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.4,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text(
//                     'Select Session and Term',
//                     style: AppTextStyles.normal600(
//                       fontSize: 20,
//                       color: const Color.fromRGBO(47, 85, 221, 1),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView(
//                     children: [
//                       _buildSessionTermItem('2023/2024 1st Term'),
//                       _buildSessionTermItem('2023/2024 2nd Term'),
//                       _buildSessionTermItem('2023/2024 3rd Term'),
//                       _buildSessionTermItem('2022/2023 3rd Term'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildMonthYearItem(String text) {
//     return ListTile(
//       title: Text(text),
//       onTap: () {
//         // Update selected month/year
//         setState(() {
//           // Example: Parse text to update state (customize as needed)
//         });
//         Navigator.pop(context);
//       },
//     );
//   }

//   Widget _buildSessionTermItem(String text) {
//     return ListTile(
//       title: Text(text),
//       onTap: () {
//         // Update selected session/term
//         setState(() {
//           // Example: Parse text to update state (customize as needed)
//         });
//         Navigator.pop(context);
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.paymentTxtColor1,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: Text(
//           'Expenditures',
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.paymentTxtColor1,
//           ),
//         ),
//         backgroundColor: AppColors.backgroundLight,
//         centerTitle: true,
//         actions: [
//           IconButton(
//             onPressed: () {
//               showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 backgroundColor: Colors.transparent,
//                 builder: (BuildContext context) {
//                   return _buildCustomOverlay();
//                 },
//               );
//             },
//             icon: SvgPicture.asset(
//               'assets/icons/profile/filter_icon.svg',
//               color: Color.fromRGBO(47, 85, 221, 1),
//             ),
//           ),
//         ],
//         flexibleSpace: FlexibleSpaceBar(
//           background: Stack(
//             children: [
//               Positioned.fill(
//                 child: Opacity(
//                   opacity: opacity,
//                   child: Image.asset(
//                     'assets/images/background.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: Constants.customBoxDecoration(context),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           GestureDetector(
//                             onTap: _showMonthYearPicker,
//                             child: Row(
//                               children: [
//                                 const Text('February 2023'),
//                                 Icon(Icons.arrow_drop_down),
//                               ],
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: _showSessionTermPicker,
//                             child: Row(
//                               children: [
//                                 const Text('2023/2024 3rd Term'),
//                                 Icon(Icons.arrow_drop_down),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Container(
//                         width: double.infinity,
//                         height: 118,
//                         decoration: BoxDecoration(
//                           color: const Color.fromRGBO(47, 85, 221, 1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Text(
//                                         'Total Expenses',
//                                         style: AppTextStyles.normal600(
//                                             fontSize: 14, color: AppColors.backgroundLight),
//                                       ),
//                                       IconButton(
//                                         icon: Icon(
//                                           _isAmountHidden ? Icons.visibility : Icons.visibility_off,
//                                           color: Colors.white,
//                                           size: 20,
//                                         ),
//                                         onPressed: () {
//                                           setState(() {
//                                             _isAmountHidden = !_isAmountHidden;
//                                           });
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                     decoration: BoxDecoration(
//                                       color: const Color.fromRGBO(198, 210, 255, 1),
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: Text(
//                                       '7 payments',
//                                       style: AppTextStyles.normal500(
//                                           fontSize: 12, color: AppColors.paymentTxtColor1),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 _isAmountHidden ? '********' : '234,790.00',
//                                 style: AppTextStyles.normal700(
//                                     fontSize: 24, color: AppColors.backgroundLight),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       SizedBox(
//                         height: 200,
//                         child: LineChart(
//                           LineChartData(
//                             gridData: const FlGridData(show: false),
//                             titlesData: FlTitlesData(
//                               bottomTitles: AxisTitles(
//                                 sideTitles: SideTitles(
//                                   showTitles: true,
//                                   getTitlesWidget: (value, meta) {
//                                     switch (value.toInt()) {
//                                       case 0:
//                                         return const Text('Basic');
//                                       case 1:
//                                         return const Text('JSS');
//                                       case 2:
//                                         return const Text('SSS');
//                                       default:
//                                         return const Text('');
//                                     }
//                                   },
//                                 ),
//                               ),
//                               leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                               topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                               rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                             ),
//                             borderData: FlBorderData(show: false),
//                             minX: 0,
//                             maxX: 2,
//                             minY: 0,
//                             maxY: 6,
//                             lineBarsData: [
//                               LineChartBarData(
//                                 spots: [
//                                   const FlSpot(0, 3),
//                                   const FlSpot(1, 1),
//                                   const FlSpot(2, 4),
//                                 ],
//                                 isCurved: true,
//                                 color: AppColors.videoColor4,
//                                 barWidth: 3,
//                                 dotData: const FlDotData(show: false),
//                                 belowBarData: BarAreaData(
//                                   show: true,
//                                   color: const Color.fromRGBO(47, 85, 221, 0.102),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Expense History',
//                             style: AppTextStyles.normal600(
//                                 fontSize: 18, color: AppColors.backgroundDark),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => const ReportPaymentScreen()),
//                               );
//                             },
//                             child: const Text(
//                               'See all',
//                               style: TextStyle(
//                                 decoration: TextDecoration.underline,
//                                 color: Color.fromRGBO(47, 85, 221, 1),
//                                 fontSize: 16.0,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       _buildExpenseHistoryItem('JSS', 234700.00, 'Joseph Raphael'),
//                       _buildExpenseHistoryItem('SS', 189500.00, 'Maria Johnson'),
//                       _buildExpenseHistoryItem('JSS', 276300.00, 'John Smith'),
//                       _buildExpenseHistoryItem('SS', 205800.00, 'Emma Davis'),
//                       _buildExpenseHistoryItem('JSS', 298100.00, 'Michael Brown'),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: AnimatedBuilder(
//         animation: _buttonAnimation,
//         builder: (context, child) => _buildAnimatedFAB(),
//       ),
//     );
//   }

//   Widget _buildAnimatedFAB() {
//     final bool showLabels = _buttonAnimation.value == 1;
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         if (_isExpanded) ...[
//           ..._fabButtons.map((button) {
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 16.0),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (showLabels)
//                     Padding(
//                       padding: const EdgeInsets.only(right: 8.0),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
//                         decoration: BoxDecoration(
//                           color: const Color.fromRGBO(47, 85, 221, 1),
//                           borderRadius: BorderRadius.circular(4.0),
//                         ),
//                         child: Text(
//                           button['title'],
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 14.0,
//                           ),
//                         ),
//                       ),
//                     ),
//                   FloatingActionButton(
//                     heroTag: button['title'],
//                     mini: true,
//                     onPressed: button['onPressed'],
//                     backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
//                     child: SvgPicture.asset(button['icon']),
//                   ),
//                 ],
//               ),
//             );
//           }),
//         ],
//         FloatingActionButton(
//           backgroundColor: AppColors.videoColor4,
//           onPressed: () {
//             setState(() {
//               _isExpanded = !_isExpanded;
//               if (_isExpanded) {
//                 _animationController.forward();
//               } else {
//                 _animationController.reverse();
//               }
//             });
//           },
//           child: AnimatedRotation(
//             duration: const Duration(milliseconds: 300),
//             turns: _isExpanded ? 0.125 : 0,
//             child: SvgPicture.asset(
//               _isExpanded
//                   ? 'assets/icons/profile/inverted_add_icon.svg'
//                   : 'assets/icons/profile/add_icon.svg',
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildExpenseHistoryItem(String grade, double amount, String name) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ExpenseHistoryScreen(
//               grade: grade,
//               amount: amount,
//               name: name,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8.0),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: ListTile(
//           contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//           leading: SvgPicture.asset('assets/icons/profile/payment_icon.svg'),
//           title: Text(
//             name,
//             style: AppTextStyles.normal600(fontSize: 18, color: AppColors.backgroundDark),
//           ),
//           subtitle: Text(
//             '07-03-2018  17:23',
//             style: AppTextStyles.normal500(fontSize: 12, color: AppColors.text10Light),
//           ),
//           trailing: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 '-$amount',
//                 style: AppTextStyles.normal700(fontSize: 18, color: Colors.red),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Clinic medication',
//                 style: AppTextStyles.normal500(fontSize: 12, color: AppColors.text10Light),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildReportTypeTab(String text, int index) {
//     return SizedBox(
//       height: 50,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         child: Row(
//           children: reportTypes.map((type) {
//             int typeIndex = reportTypes.indexOf(type);
//             bool isSelected = _selectedReportType == typeIndex;
//             return Padding(
//               padding: const EdgeInsets.only(right: 12.0),
//               child: GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _selectedReportType = typeIndex;
//                   });
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? const Color.fromRGBO(228, 234, 255, 1)
//                         : const Color.fromRGBO(247, 247, 247, 1),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     type,
//                     style: TextStyle(
//                       color: isSelected
//                           ? const Color.fromRGBO(47, 85, 221, 1)
//                           : const Color(0xFF414141),
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterByTab() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildFilterButton('Session'),
//           const SizedBox(height: 12),
//           _buildFilterButton('Term'),
//           const SizedBox(height: 12),
//           _buildFilterButton('Class'),
//           const SizedBox(height: 12),
//           _buildFilterButton('Level'),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterButton(String text) {
//     return Container(
//       width: double.infinity,
//       height: 42,
//       decoration: BoxDecoration(
//         color: const Color.fromRGBO(229, 229, 229, 1),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Center(
//         child: Text(text),
//       ),
//     );
//   }

//   Widget _buildDateRangeTab() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildDateRangeOptions(),
//           const SizedBox(height: 20),
//           if (_selectedDateRange == 'Custom') _buildCustomDateRange(),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateRangeOptions() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: dateRangeOptions.map((option) {
//           return Padding(
//             padding: const EdgeInsets.only(right: 8.0),
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _selectedDateRange = option;
//                 });
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: _selectedDateRange == option
//                       ? const Color.fromRGBO(47, 85, 221, 1)
//                       : const Color.fromRGBO(212, 222, 255, 1),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Text(
//                   option,
//                   style: TextStyle(
//                     color: _selectedDateRange == option
//                         ? Colors.white
//                         : AppColors.paymentTxtColor1,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildCustomDateRange() {
//     return Column(
//       children: [
//         _buildDateInput('From:', _fromDate, _onFromDateChanged),
//         const SizedBox(height: 10),
//         _buildDateInput('To:', _toDate, _onToDateChanged),
//         const SizedBox(height: 20),
//       ],
//     );
//   }

//   Widget _buildDateInput(String label, DateTime selectedDate, Function(DateTime) onDateSelected) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label),
//         const SizedBox(height: 5),
//         GestureDetector(
//           onTap: () async {
//             final DateTime? picked = await showDatePicker(
//               context: context,
//               initialDate: selectedDate,
//               firstDate: DateTime(2000),
//               lastDate: DateTime(2025),
//             );
//             if (picked != null) {
//               onDateSelected(picked);
//               if (mounted) {
//                 setState(() {});
//               }
//             }
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '${selectedDate.day}-${selectedDate.month}-${selectedDate.year}',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const Icon(
//                   Icons.calendar_today,
//                   color: AppColors.paymentTxtColor1,
//                   size: 24,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildGroupingTab() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Group by:',
//             style: TextStyle(color: Colors.grey),
//           ),
//           const SizedBox(height: 10),
//           _buildGroupingOption('Vendor'),
//           _buildGroupingOption('Account'),
//           _buildGroupingOption('Month'),
//         ],
//       ),
//     );
//   }

//   Widget _buildGroupingOption(String option) {
//     return Container(
//       width: double.infinity,
//       height: 42,
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: const Color.fromRGBO(229, 229, 229, 1),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Center(
//         child: Text(option),
//       ),
//     );
//   }

//   Widget _buildFilterTab() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Filter by:',
//             style: TextStyle(color: Colors.grey),
//           ),
//           const SizedBox(height: 10),
//           _buildFilterOption('Level', ['JSS1', 'JSS2', 'JSS3'], _selectedLevel, (value) {
//             setState(() {
//               _selectedLevel = value;
//             });
//           }),
//           const SizedBox(height: 10),
//           _buildFilterOption('Class', ['JSS1A', 'JSS1B', 'JSS1C'], _selectedClass, (value) {
//             setState(() {
//               _selectedClass = value;
//             });
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterOption(String label, List<String> options, String selectedValue, Function(String) onChanged) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label),
//         const SizedBox(height: 5),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: const Color.fromRGBO(229, 229, 229, 1),
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: DropdownButton<String>(
//             value: selectedValue,
//             isExpanded: true,
//             underline: const SizedBox(),
//             onChanged: (String? newValue) {
//               if (newValue != null) {
//                 onChanged(newValue);
//               }
//             },
//             items: options.map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCustomOverlay() {
//     return GestureDetector(
//       onTap: () => Navigator.pop(context),
//       child: Container(
//         child: GestureDetector(
//           onTap: () {}, // Prevents taps from propagating
//           child: Container(
//             height: MediaQuery.of(context).size.height * 0.60,
//             margin: EdgeInsets.only(
//               top: MediaQuery.of(context).size.height * 0.2,
//             ),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: Column(
//               children: [
//                 Container(
//                   height: 120,
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Column(
//                       children: [
//                         _buildReportTypeTabRow(reportTypes.sublist(0, 5)),
//                         SizedBox(height: 8),
//                         _buildReportTypeTabRow(reportTypes.sublist(0, 5)),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: DefaultTabController(
//                     length: 3,
//                     child: Column(
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                           ),
//                           child: TabBar(
//                             onTap: (index) {
//                               setState(() {
//                                 _currentTabIndex = index;
//                               });
//                             },
//                             tabs: const [
//                               Tab(text: 'Date Range'),
//                               Tab(text: 'Grouping'),
//                               Tab(text: 'Filter by'),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           child: TabBarView(
//                             children: [
//                               _buildDateRangeTab(),
//                               _buildGroupingTab(),
//                               _buildFilterByTab(),
//                             ],
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.2),
//                                 spreadRadius: 1,
//                                 blurRadius: 4,
//                                 offset: const Offset(0, -2),
//                               ),
//                             ],
//                           ),
//                           child: ElevatedButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const ReportPaymentScreen(),
//                                 ),
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
//                               minimumSize: const Size(double.infinity, 50),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                               ),
//                             ),
//                             child: const Text(
//                               'Generate Report',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildReportTypeTabRow(List<String> types) {
//     return Row(
//       children: types.map((type) {
//         int typeIndex = reportTypes.indexOf(type);
//         bool isSelected = _selectedReportType == typeIndex;
//         return Padding(
//           padding: const EdgeInsets.only(right: 12.0),
//           child: GestureDetector(
//             onTap: () {
//               setState(() {
//                 _selectedReportType = typeIndex;
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: isSelected
//                     ? Color.fromRGBO(228, 234, 255, 1)
//                     : Color.fromRGBO(247, 247, 247, 1),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(
//                 type,
//                 style: TextStyle(
//                   color: isSelected
//                       ? const Color.fromRGBO(47, 85, 221, 1)
//                       : Color.fromRGBO(65, 65, 65, 1),
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }