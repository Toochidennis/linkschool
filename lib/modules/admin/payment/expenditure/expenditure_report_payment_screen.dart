// import 'package:hive/hive.dart';
// import 'package:linkschool/modules/admin/payment/receipt/generate_report/statistics_view.dart';
// import 'package:linkschool/modules/admin/payment/receipt/generate_report/transaction_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/admin/payment/receipt/generate_report/expense_statistics_view.dart';
import 'package:linkschool/modules/admin/payment/receipt/generate_report/expense_transaction_view.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/services/admin/payment/expenditure_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class ExpenditureReportPaymentScreen extends StatefulWidget {
  final Map<String, dynamic>? initialParams;

  const ExpenditureReportPaymentScreen({super.key, this.initialParams});

  @override
  State<ExpenditureReportPaymentScreen> createState() =>
      _ExpenditureReportPaymentScreenState();
}

class _ExpenditureReportPaymentScreenState
    extends State<ExpenditureReportPaymentScreen> {
  int _selectedIndex = 0;
  late double opacity;

  final List<Widget> _screens = const [
    ExpenseTransactionView(),
    ExpenseStatisticsView(),
  ];

  // Filter state
  String _reportType = 'monthly';
  String? _groupBy;
  String? _customType;
  String? _startDate;
  String? _endDate;
  final List<int> _selectedVendors = [];
  final List<int> _selectedSessions = [];
  final List<int> _selectedTerms = [];
  final List<int> _selectedAccounts = [];
  final ExpenditureService _expenditureService = locator<ExpenditureService>();

  @override
  void initState() {
    super.initState();
    if (widget.initialParams != null) {
      _reportType = widget.initialParams!['report_type'] ?? 'monthly';
      // Initialize other filters if provided
    }
  }

  void _showFilterOverlay(BuildContext context) {
    // Reuse the same filter overlay logic from expenditure_screen
    // For brevity, implement or import the FilterBottomSheet here
    // This would update the filter state and notify child views
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
          'Payments',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.paymentTxtColor1,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
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
        actions: [
          // IconButton(
          //   icon: SvgPicture.asset(
          //     'assets/icons/profile/filter_icon.svg',
          //     color: AppColors.paymentTxtColor1,
          //   ),
          //   onPressed: () => _showFilterOverlay(context),
          // ),
          TextButton(
            onPressed: () {
              // Handle download action with current filter params
            },
            child: Text(
              'Download',
              style: AppTextStyles.normal600(
                  fontSize: 14, color: AppColors.paymentTxtColor1),
            ),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/profile/nav_transaction_icon.svg',
              color: _selectedIndex == 0
                  ? const Color.fromRGBO(47, 85, 221, 1)
                  : Colors.grey,
            ),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/profile/nav_statistics_icon.svg',
              color: _selectedIndex == 1
                  ? const Color.fromRGBO(47, 85, 221, 1)
                  : Colors.grey,
            ),
            label: 'Statistics',
          ),
        ],
        selectedItemColor: const Color.fromRGBO(47, 85, 221, 1),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
