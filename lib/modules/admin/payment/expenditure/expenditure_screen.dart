import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/admin/payment/expenditure/add_expenditure_screen.dart';
import 'package:linkschool/modules/admin/payment/expenditure/expenditure_report_payment_screen.dart';
import 'package:linkschool/modules/admin/payment/expenditure/expense_history.dart';
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
  bool _isAmountHidden = false;
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _buttonAnimation;

  // Server data state
  Map<String, dynamic>? _expenditureData;
  bool _isDataLoading = false;
  String _db = '';

  // Filter state
  Map<String, dynamic> _filterParams = {
    'report_type': 'monthly',
    'group_by': 'month',
  };

  List<String> xLabels = [];
  Map<String, double> xIndexMap = {};
  bool isDateFormat = false;

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

  final VendorService _vendorService = locator<VendorService>();
  final ExpenditureService _expenditureService = locator<ExpenditureService>();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _fetchVendors();
    _fetchAccounts();
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
          return FilterOverlay(
            initialParams: _filterParams,
            onGenerate: (params) {
              setState(() {
                _filterParams = params;
              });
              _fetchExpenditureData();
            },
            vendors: _filterParams['vendors']?.cast<Map<String, dynamic>>() ?? [],
            accounts: _filterParams['accounts']?.cast<Map<String, dynamic>>() ?? [],
          );
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
          _filterParams['vendors'] = response.data!.map((vendor) => {
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
          _filterParams['accounts'] = response.data!.data.map((account) => {
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
        'report_type': _filterParams['report_type'],
        '_db': _db,
        if (_filterParams['group_by'] != null) 'group_by': _filterParams['group_by'],
        if (_filterParams['custom_type'] != null) 'custom_type': _filterParams['custom_type'],
        if (_filterParams['start_date'] != null) 'start_date': _filterParams['start_date'],
        if (_filterParams['end_date'] != null) 'end_date': _filterParams['end_date'],
        if (_filterParams['filters']?.isNotEmpty == true) 'filters': _filterParams['filters'],
      };
      print('Expenditure Payload: $payload');
      final response = await _expenditureService.generateReport(payload);
      print('Expenditure Response: ${response.data}');
      if (response.success && response.data != null) {
        setState(() {
          _expenditureData = response.data;
          _prepareChartData();
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

  void _prepareChartData() {
    if (_expenditureData == null || _expenditureData!['chart_data'] == null) {
      xLabels = [];
      xIndexMap = {};
      return;
    }

    final chartDataList = _expenditureData!['chart_data'] as List<dynamic>? ?? [];
    xLabels = chartDataList.map((e) => (e as Map<String, dynamic>)['x']?.toString() ?? '').toSet().toList();

    try {
      xLabels.sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));
      isDateFormat = true;
    } catch (e) {
      xLabels.sort();
      isDateFormat = false;
    }

    xIndexMap = {for (int i = 0; i < xLabels.length; i++) xLabels[i]: i.toDouble()};
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      return FlSpot(xIndexMap[data['x']] ?? index.toDouble(), yValue);
    }).toList();

    // Create labels for bottom axis based on dates
    final List<String> dateLabels = chartDataList.map((data) {
      final dateStr = (data as Map<String, dynamic>)['x']?.toString() ?? '';
      if (isDateFormat) {
        try {
          final date = DateFormat('yyyy-MM-dd').parse(dateStr);
          return DateFormat('MMM d').format(date);
        } catch (e) {
          return dateStr;
        }
      }
      return dateStr;
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
                        return FilterOverlay(
                          initialParams: _filterParams,
                          onGenerate: (params) {
                            setState(() {
                              _filterParams = params;
                            });
                            _fetchExpenditureData();
                          },
                          vendors: _filterParams['vendors']?.cast<Map<String, dynamic>>() ?? [],
                          accounts: _filterParams['accounts']?.cast<Map<String, dynamic>>() ?? [],
                        );
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
            child: _isDataLoading
                ? const Center(child: CircularProgressIndicator())
                : _expenditureData == null
                    ? const Center(child: Text('No data available'))
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: _filterParams['report_type'] == 'monthly' ? _showMonthYearPicker : null,
                                    child: Row(
                                      children: [
                                        Text(_isDataLoading
                                            ? 'Loading...'
                                            : _filterParams['start_date'] != null
                                                ? DateFormat('MMMM yyyy').format(DateTime.parse(_filterParams['start_date']))
                                                : 'September 2025'),
                                        if (_filterParams['report_type'] == 'monthly') const Icon(Icons.arrow_drop_down),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _filterParams['report_type'] == 'termly' || _filterParams['report_type'] == 'session' ? _showSessionTermPicker : null,
                                    child: Row(
                                      children: [
                                        Text(_isDataLoading
                                            ? 'Loading...'
                                            : '${_filterParams['filters']?['sessions']?.isNotEmpty == true ? _filterParams['filters']['sessions'][0] : '2023'}/${(_filterParams['filters']?['sessions']?.isNotEmpty == true ? _filterParams['filters']['sessions'][0] + 1 : 2024)} ${_filterParams['filters']?['terms']?.isNotEmpty == true ? '${_filterParams['filters']['terms'][0]}rd Term' : '3rd Term'}'),
                                        if (_filterParams['report_type'] == 'termly' || _filterParams['report_type'] == 'session') const Icon(Icons.arrow_drop_down),
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
                                                style: AppTextStyles.normal600(fontSize: 14, color: AppColors.backgroundLight),
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
                                              _isDataLoading ? 'Loading...' : '${summary['total_transactions'] ?? 0} payments',
                                              style: AppTextStyles.normal500(fontSize: 12, color: AppColors.paymentTxtColor1),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        _isAmountHidden
                                            ? '********'
                                            : _isDataLoading
                                                ? 'Loading...'
                                                : '₦${(summary['total_amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                        style: AppTextStyles.normal700(fontSize: 24, color: AppColors.backgroundLight),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: chartSpots.isEmpty
                                    ? const Center(child: Text('No chart data available'))
                                    : LineChart(
                                        LineChartData(
                                          gridData: const FlGridData(show: false),
                                          titlesData: FlTitlesData(
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 30,
                                                getTitlesWidget: (value, meta) {
                                                  final idx = value.toInt();
                                                  if (idx < 0 || idx >= dateLabels.length) {
                                                    return const Text('');
                                                  }
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 4),
                                                    child: Text(dateLabels[idx], style: const TextStyle(fontSize: 10)),
                                                  );
                                                },
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
                                    style: AppTextStyles.normal600(fontSize: 18, color: AppColors.backgroundDark),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push( 
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ExpenditureReportPaymentScreen()
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
                                              transaction['name']?.toString() ?? 'Unknown',
                                              (transaction['amount'] is int)
                                                  ? (transaction['amount'] as int).toDouble()
                                                  : (transaction['amount'] as double?) ?? 0.0,
                                              transaction['account_name']?.toString() ?? 'Unknown Account',
                                              transaction,
                                            );
                                          }).toList(),
                                        ),
                            ],
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
                    children: List.generate(12, (index) {
                      final date = DateTime.now().subtract(Duration(days: 30 * index));
                      return ListTile(
                        title: Text(DateFormat('MMMM yyyy').format(date)),
                        onTap: () {
                          setState(() {
                            _filterParams['start_date'] = DateFormat('yyyy-MM-dd').format(DateTime(date.year, date.month, 1));
                            _filterParams['end_date'] = DateFormat('yyyy-MM-dd').format(DateTime(date.year, date.month + 1, 0));
                            _filterParams['custom_type'] = 'this_month';
                            _fetchExpenditureData();
                          });
                          Navigator.pop(context);
                        },
                      );
                    }),
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
                      ListTile(
                        title: const Text('2023/2024 1st Term'),
                        onTap: () {
                          setState(() {
                            _filterParams['filters'] = {
                              ...?_filterParams['filters'],
                              'sessions': [2023],
                              'terms': [1],
                            };
                            _fetchExpenditureData();
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('2023/2024 2nd Term'),
                        onTap: () {
                          setState(() {
                            _filterParams['filters'] = {
                              ...?_filterParams['filters'],
                              'sessions': [2023],
                              'terms': [2],
                            };
                            _fetchExpenditureData();
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('2023/2024 3rd Term'),
                        onTap: () {
                          setState(() {
                            _filterParams['filters'] = {
                              ...?_filterParams['filters'],
                              'sessions': [2023],
                              'terms': [3],
                            };
                            _fetchExpenditureData();
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('2022/2023 3rd Term'),
                        onTap: () {
                          setState(() {
                            _filterParams['filters'] = {
                              ...?_filterParams['filters'],
                              'sessions': [2022],
                              'terms': [3],
                            };
                            _fetchExpenditureData();
                          });
                          Navigator.pop(context);
                        },
                      ),
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
            transaction['date']?.toString() ?? '07-03-2018  17:23',
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
}

class FilterOverlay extends StatefulWidget {
  final Map<String, dynamic>? initialParams;
  final Function(Map<String, dynamic>) onGenerate;
  final List<Map<String, dynamic>> vendors;
  final List<Map<String, dynamic>> accounts;

  const FilterOverlay({
    super.key,
    this.initialParams,
    required this.onGenerate,
    required this.vendors,
    required this.accounts,
  });

  @override
  State<FilterOverlay> createState() => _FilterOverlayState();
}

class _FilterOverlayState extends State<FilterOverlay> {
  String selectedReport = 'Monthly';
  String selectedCustomType = 'This Month';
  String selectedGrouping = 'Month';
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime toDate = DateTime.now();
  Map<String, List<dynamic>> selectedFilters = {};

  final List<String> reportTypes = ['Termly', 'Session', 'Monthly', 'Custom'];
  final List<String> customTypes = [
    'Range',
    'Today',
    'Yesterday',
    'This Week',
    'Last Week',
    'Last 30 Days',
    'This Month',
    'Last Month'
  ];
  final List<String> groupingOptions = ['Vendor', 'Account', 'Month'];
  final List<String> filterByOptions = ['Vendors', 'Accounts', 'Sessions', 'Terms'];

  bool get isCustom => selectedReport == 'Custom';

  @override
  void initState() {
    super.initState();
    if (widget.initialParams != null) {
      selectedReport = (widget.initialParams!['report_type'] as String).capitalize();
      if (widget.initialParams!.containsKey('group_by')) {
        selectedGrouping = (widget.initialParams!['group_by'] as String).capitalize();
      }
      if (isCustom) {
        if (widget.initialParams!.containsKey('custom_type')) {
          String ctype = widget.initialParams!['custom_type'];
          selectedCustomType = ctype.split('_').map((e) => e.capitalize()).join(' ');
        }
        if (widget.initialParams!.containsKey('start_date')) {
          fromDate = DateTime.parse(widget.initialParams!['start_date']);
        }
        if (widget.initialParams!.containsKey('end_date')) {
          toDate = DateTime.parse(widget.initialParams!['end_date']);
        }
        if (widget.initialParams!.containsKey('filters')) {
          selectedFilters = Map.from(widget.initialParams!['filters']).map(
            (key, value) => MapEntry(key, List<dynamic>.from(value)),
          );
        }
      }
    }
    print('Initial selectedFilters: $selectedFilters');
  }

  @override
  Widget build(BuildContext context) {
    print('Building FilterOverlay, selectedCustomType: $selectedCustomType');
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.black54.withOpacity(0.5),
        child: GestureDetector(
          onTap: () {},
          child: Container(
            height: MediaQuery.of(context).size.height * 0.60,
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.4),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: reportTypes.map((type) {
                        bool isSelected = selectedReport == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedReport = type;
                                selectedGrouping = '';
                                selectedFilters = {};
                                if (type != 'Custom') {
                                  selectedCustomType = 'This Month';
                                  fromDate = DateTime.now().subtract(const Duration(days: 30));
                                  toDate = DateTime.now();
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color.fromRGBO(228, 234, 255, 1) : const Color.fromRGBO(247, 247, 247, 1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  color: isSelected ? const Color.fromRGBO(47, 85, 221, 1) : const Color.fromRGBO(65, 65, 65, 1),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: DefaultTabController(
                    length: isCustom ? 3 : 1,
                    child: Column(
                      children: [
                        TabBar(
                          tabs: isCustom
                              ? const [
                                  Tab(text: 'Date Range'),
                                  Tab(text: 'Grouping'),
                                  Tab(text: 'Filter by'),
                                ]
                              : const [
                                  Tab(text: 'Grouping'),
                                ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: isCustom
                                ? [
                                    _buildDateRangeTab(),
                                    _buildGroupingTab(),
                                    _buildFilterByTab(),
                                  ]
                                : [
                                    _buildGroupingTab(),
                                  ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: ElevatedButton(
                            onPressed: _generateReport,
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

  Widget _buildDateRangeTab() {
    print('Building DateRangeTab, selectedCustomType: $selectedCustomType');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: customTypes.map((option) {
                  bool isSelected = selectedCustomType == option;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCustomType = option;
                          print('Selected custom type: $selectedCustomType');
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color.fromRGBO(47, 85, 221, 1)
                              : const Color.fromRGBO(212, 222, 255, 1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.paymentTxtColor1,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (selectedCustomType == 'Range') ...[
              const SizedBox(height: 20),
              _buildDatePicker('From', fromDate, (date) {
                setState(() {
                  fromDate = date;
                  print('From date updated: $fromDate');
                });
              }),
              const SizedBox(height: 10),
              _buildDatePicker('To', toDate, (date) {
                setState(() {
                  toDate = date;
                  print('To date updated: $toDate');
                });
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.normal600(fontSize: 16)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2000),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color.fromRGBO(47, 85, 221, 1),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                    dialogBackgroundColor: Colors.white,
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('yyyy-MM-dd').format(date),
                  style: AppTextStyles.normal500(fontSize: 14, color: Colors.black),
                ),
                const Icon(Icons.calendar_today, color: Color.fromRGBO(47, 85, 221, 1)),
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
        children: groupingOptions.map((option) {
          bool isSelected = selectedGrouping == option;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedGrouping = isSelected ? '' : option;
                print('Selected grouping: $selectedGrouping');
              });
            },
            child: Container(
              width: double.infinity,
              height: 42,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color.fromRGBO(47, 85, 221, 1) : const Color.fromRGBO(229, 229, 229, 1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterByTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: filterByOptions.map((option) {
          final count = selectedFilters[option.toLowerCase()]?.length ?? 0;
          return GestureDetector(
            onTap: () => _showFilterBottomSheet(option),
            child: Container(
              width: double.infinity,
              height: 42,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(229, 229, 229, 1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '$option: $count selected',
                  style: AppTextStyles.normal500(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showFilterBottomSheet(String option) {
    List<Map<String, dynamic>> items = [];
    switch (option.toLowerCase()) {
      case 'vendors':
        items = widget.vendors;
        break;
      case 'accounts':
        items = widget.accounts;
        break;
      case 'sessions':
        final userBox = Hive.box('userData');
        final currentYear = userBox.get('current_year') ?? 2025;
        items = List.generate(currentYear - 1999 + 1, (index) {
          final year = currentYear - index;
          return {'name': '${year - 1}/$year', 'value': year};
        });
        break;
      case 'terms':
        items = [
          {'name': 'First Term', 'value': 1},
          {'name': 'Second Term', 'value': 2},
          {'name': 'Third Term', 'value': 3},
        ];
        break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundLight,
      builder: (context) {
        return _buildSelectionBottomSheet(
          title: 'Select $option',
          items: items,
          onItemSelected: (selectedValues) {
            setState(() {
              final key = option.toLowerCase();
              selectedFilters[key] = selectedValues;
              print('Updated selectedFilters for $key: $selectedValues');
            });
          },
        );
      },
    );
  }

  Widget _buildSelectionBottomSheet({
    required String title,
    required List<Map<String, dynamic>> items,
    required Function(List<dynamic>) onItemSelected,
  }) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        final key = title.toLowerCase().contains('vendor')
            ? 'vendors'
            : title.toLowerCase().contains('account')
                ? 'accounts'
                : title.toLowerCase().contains('session')
                    ? 'sessions'
                    : 'terms';
        final selectedValues = selectedFilters[key] != null
            ? List<dynamic>.from(selectedFilters[key]!)
            : <dynamic>[];

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    title,
                    style: AppTextStyles.normal600(fontSize: 20, color: const Color.fromRGBO(47, 85, 221, 1)),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final value = item['value'] ?? item['id'];
                      final name = item['name'] ?? item['vendor_name'] ?? item['account_name'] ?? 'Unknown';
                      final isSelected = selectedValues.contains(value);
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            if (isSelected) {
                              selectedValues.remove(value);
                            } else {
                              selectedValues.add(value);
                            }
                            print('Selected values in bottom sheet: $selectedValues');
                          });
                          setState(() {
                            selectedFilters[key] = List<dynamic>.from(selectedValues);
                            print('Updated selectedFilters in parent: $selectedFilters');
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: AppTextStyles.normal500(fontSize: 16, color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check, color: Color.fromRGBO(47, 85, 221, 1)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      onItemSelected(selectedValues);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                      shadowColor: Colors.grey.withOpacity(0.5),
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _generateReport() {
    if (isCustom && selectedCustomType == 'Range' && fromDate.isAfter(toDate)) {
      CustomToaster.toastError(context, 'Error', 'Start date cannot be after end date');
      return;
    }

    Map<String, dynamic> params = {
      'report_type': selectedReport.toLowerCase(),
    };

    if (selectedGrouping.isNotEmpty) {
      params['group_by'] = selectedGrouping.toLowerCase();
    }

    if (isCustom) {
      String ctype = selectedCustomType.toLowerCase().replaceAll(' ', '_');
      params['custom_type'] = ctype;
      if (ctype == 'range') {
        params['start_date'] = DateFormat('yyyy-MM-dd').format(fromDate);
        params['end_date'] = DateFormat('yyyy-MM-dd').format(toDate);
      }
      if (selectedFilters.isNotEmpty) {
        params['filters'] = selectedFilters;
      }
    }

    print('Generating report with params: $params');
    widget.onGenerate(params);
    Navigator.pop(context);
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
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