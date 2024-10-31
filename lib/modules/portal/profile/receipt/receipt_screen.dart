// ignore_for_file: prefer_const_literals_to_create_immutables, unused_element, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
import 'package:linkschool/modules/portal/profile/receipt/student_list_screen.dart';
import 'package:linkschool/modules/portal/profile/receipt/generate_report/report_payment.dart';


class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen>
    with TickerProviderStateMixin {
  late double opacity;
  bool _isOverlayVisible = false;
  int _currentTabIndex = 0;
  String _selectedDateRange = 'Custom';
  String _selectedGrouping = 'Month';
  String _selectedLevel = 'JSS1';
  String _selectedClass = 'JSS1A';
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  bool _isAmountHidden = false;

  late TabController _tabController;
  final List<String> reportTypes = [
    'Termly report',
    'Session report',
    'Monthly report',
    'Class report',
    'Level report',
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

  // new state variables for level and class selection
  String? selectedLevel;
  String? selectedClass;
  List<String> students = []; // Will hold students for selected class

  int _selectedReportType = 0;

  // Define level and class data
  final Map<String, List<String>> levelClassMap = {
    'JSS': ['JSS 1', 'JSS 2', 'JSS 3'],
    'SS': ['SS 1', 'SS 2', 'SS 3'],
    'BASIC': ['Basic 1', 'Basic 2', 'Basic 3', 'Basic 4', 'Basic 5'],
  };

  final List<Map<String, dynamic>> _fabButtons = [
    {
      'title': 'Setup report',
      'icon': 'assets/icons/profile/setup_report.svg',
      'onPressed': null,
    },
    {
      'title': 'Add receipt',
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

    // _fabButtons[1]['onPressed'] = _showAddReceiptBottomSheet;

    // Update the Add Receipt FAB action
    _fabButtons[1]['onPressed'] = _showLevelSelectionOverlay;
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

  void _showMonthYearFilterOverlay() {
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

  void _showSessionTermFilterOverlay() {
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

  void _showLevelSelectionOverlay() {
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
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Level',
                    style: AppTextStyles.normal600(
                      fontSize: 20,
                      color: const Color.fromRGBO(47, 85, 221, 1),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Flexible(
                    child: ListView.builder(
                      itemCount: levelClassMap.keys.length,
                      itemBuilder: (context, index) {
                        String level = levelClassMap.keys.elementAt(index);
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: _buildSubjectButton(level),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showClassSelectionOverlay(String level) {
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
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Select Class',
                      style: AppTextStyles.normal600(
                        fontSize: 20,
                        color: const Color.fromRGBO(47, 85, 221, 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Flexible(
                    child: ListView.builder(
                      itemCount: levelClassMap[level]?.length ?? 0,
                      itemBuilder: (context, index) {
                        String className = levelClassMap[level]![index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: _buildSubjectButton(className, isClass: true),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStudentList(String className) {
    // Simulated student data - replace with actual data fetch
    List<String> students = [
      'John ifeanyi',
      'Amaka Smith',
      'Mike Okoro',
      'Sarah Uche',
      'David Ugonna',
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentListScreen(
          className: className,
          students: students,
        ),
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
          'Receipts',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.paymentTxtColor1,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
        actions: [
          TextButton(
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
            child: SvgPicture.asset(
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
                            onTap: _showMonthYearFilterOverlay,
                            child: Row(
                              children: [
                                Text('February 2023'),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _showSessionTermFilterOverlay,
                            child: Row(
                              children: [
                                Text('2023/2024 3rd Term'),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 115,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(47, 85, 221, 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Total Amount Received',
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
                                    padding:  const EdgeInsets.symmetric(
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
                              Row(
                                children: [
                                  const NairaSvgIcon(color: AppColors.backgroundLight),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isAmountHidden ? '********' : '234,790.00',
                                    style: AppTextStyles.normal700(fontSize: 24, color: AppColors.backgroundLight),
                                  ),
                                ],
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
                      const SizedBox(height: 16.0),
                      _buildPaymentHistoryItem(
                        'JSS 2',
                        '234,700.00',
                      ),
                      _buildPaymentHistoryItem(
                        'SS 2',
                        '189,500.00',
                      ),
                      _buildPaymentHistoryItem(
                        'JSS 3',
                        '276,300.00',
                      ),
                      _buildPaymentHistoryItem(
                        'SS 1',
                        '205,800.00',
                      ),
                      _buildPaymentHistoryItem('JSS 1', '298,100.00'),
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

  void _showAddReceiptBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Receipt',
                    style: AppTextStyles.normal600(
                        fontSize: 20,
                        color: const Color.fromRGBO(47, 85, 221, 1)),
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                        'assets/icons/profile/cancel_receipt.svg'),
                    color: AppColors.bgGray,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInputField('Student name', 'Student name'),
              const SizedBox(height: 16),
              _buildInputField('Amount', 'Amount'),
              const SizedBox(height: 16),
              _buildInputField('Reference', 'Reference'),
              const SizedBox(height: 16),
              _buildDateInputField('Date'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  child: Text(
                    'Record payment',
                    style: AppTextStyles.normal500(
                        fontSize: 18, color: AppColors.backgroundLight),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubjectButton(String text, {bool isClass = false}) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context); // Close current overlay
        if (isClass) {
          _showStudentList(
              text); // Navigate to StudentListScreen for class selection
        } else {
          _showClassSelectionOverlay(
              text); // Show class selection for level selection
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.normal500(
                fontSize: 16.0, color: AppColors.backgroundDark)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateInputField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.normal500(
                fontSize: 16, color: AppColors.backgroundDark)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2025),
            );
            if (picked != null) {
              // Handle date selection
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select date'),
                SvgPicture.asset('assets/icons/profile/calendar_icon.svg'),
              ],
            ),
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
            height: MediaQuery.of(context).size.height * 0.58,
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
                        ? Color.fromRGBO(228, 234, 255, 1)
                        : Color.fromRGBO(247, 247, 247, 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: isSelected
                          ? Color.fromRGBO(47, 85, 221, 1)
                          : Color.fromRGBO(65, 65, 65, 1),
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

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Date Range'),
        Tab(text: 'Grouping'),
        Tab(text: 'Filter'),
      ],
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

  Widget _buildPaymentHistoryItem(
    String grade,
    String amount,
  ) {
    return GestureDetector(
      onTap: () {},
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
                    grade,
                    style: AppTextStyles.normal600(
                        fontSize: 18, color: AppColors.backgroundDark),
                  ),
                ],
              ),
              Row(
                children: [
                  NairaSvgIcon(color: AppColors.paymentTxtColor1,),
                  const SizedBox(width: 4),
                  Text(amount,
                      style: AppTextStyles.normal700(
                          fontSize: 18,
                          color: AppColors.paymentTxtColor1)),
                ],
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
