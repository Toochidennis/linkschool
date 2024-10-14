import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/portal/profile/expenditure/expense_history.dart';
import 'package:linkschool/modules/portal/profile/expenditure/vendor/expense_select_vendor.dart';
import 'package:linkschool/modules/portal/profile/receipt/reciept_payment_detail.dart';

class ExpenditureScreen extends StatefulWidget {
  const ExpenditureScreen({super.key});

  @override
  State<ExpenditureScreen> createState() => _ExpenditureScreenState();
}

class _ExpenditureScreenState extends State<ExpenditureScreen> with TickerProviderStateMixin{
  late double opacity;

    bool _isOverlayVisible = false;
  late TabController _tabController;
  int _currentTabIndex = 0;
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
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
          'Expenditures',
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('February 2023'),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                          Row(
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Expenses',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(198, 210, 255, 1),
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
                      // const SizedBox(height: 16),
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
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                            style: AppTextStyles.normal600(fontSize: 18, color: AppColors.backgroundDark)
                          ),
                          const Text(
                            'See all',
                            style: TextStyle(decoration: TextDecoration.underline, color: Color.fromRGBO(47, 85, 221, 1), fontSize: 16.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildExpenseHistoryItem('JSS', '234,700.00', 'Joseph Raphael'),
                      _buildExpenseHistoryItem('SS', '189,500.00', 'Maria Johnson'),
                      _buildExpenseHistoryItem('JSS', '276,300.00', 'John Smith'),
                      _buildExpenseHistoryItem('SS', '205,800.00', 'Emma Davis'),
                      _buildExpenseHistoryItem('JSS', '298,100.00', 'Michael Brown'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isExpanded) _buildSmallFloatingButtons(),
        ],
      ),
      floatingActionButton: _buildAnimatedFAB(),
    );
  }

  Widget _buildExpenseHistoryItem(String grade, String amount, String name) {
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
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          leading: SvgPicture.asset('assets/icons/profile/payment_icon.svg'),
          title: Text(
            name,
            style: AppTextStyles.normal600(fontSize: 18, color: AppColors.backgroundDark),
          ),
          subtitle: Text(
            '07-03-2018  17:23',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildAnimatedFAB() {
    return FloatingActionButton(
      backgroundColor: AppColors.videoColor4,
      onPressed: _toggleExpanded,
      child: AnimatedCrossFade(
        firstChild: SvgPicture.asset('assets/icons/profile/add_icon.svg'),
        secondChild: SvgPicture.asset('assets/icons/profile/inverted_add_icon.svg'),
        crossFadeState:
            _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildSmallFloatingButtons() {
    return Positioned(
      bottom: 80,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'Setup report',
            preferBelow: false,
            verticalOffset: 20,
            child: FloatingActionButton(
              mini: true,
              onPressed: () {},
              // onPressed: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => DummyScreen(title: 'Setup Report')),
              //   );
              // },
              backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
              child: SvgPicture.asset('assets/icons/profile/setup_report.svg'),
            ),
          ),
          const SizedBox(height: 16),
          Tooltip(
            message: 'Add Vendor',
            preferBelow: false,
            verticalOffset: 20,
            child: FloatingActionButton(
              mini: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExpenseSelectVendor( name: 'Joe Raphael',)),
                );
              },
              backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
              child: SvgPicture.asset('assets/icons/profile/add_receipt.svg'),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSmallFloatingButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return FloatingActionButton(
      mini: true,
      backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
      onPressed: onPressed,
      child: Icon(icon, color: AppColors.backgroundLight),
    );
  }
}