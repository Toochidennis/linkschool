import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/admin_portal/payment/receipt/generate_report/statistics_view.dart';
import 'package:linkschool/modules/admin_portal/payment/receipt/generate_report/transaction_view.dart';
// import 'package:linkschool/modules/common/constants.dart';

class ReportPaymentScreen extends StatefulWidget {
  const ReportPaymentScreen({super.key});

  @override
  State<ReportPaymentScreen> createState() => _ReportPaymentScreenState();
}

class _ReportPaymentScreenState extends State<ReportPaymentScreen> {
  int _selectedIndex = 0;
  late double opacity;

  // List of widgets to display for each navigation item
  final List<Widget> _screens = [
    const TransactionsView(),
    const StatisticsView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
          TextButton(
            onPressed: () {
              // Handle download action
            },
            child: Text(
              'Download',
              style: AppTextStyles.normal600(fontSize: 14, color: AppColors.paymentTxtColor1),
            ),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/profile/nav_transaction_icon.svg',
              color: _selectedIndex == 0 ? Color.fromRGBO(47, 85, 221, 1) : Colors.grey,
            ),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/profile/nav_statistics_icon.svg',
              color: _selectedIndex == 1 ? Color.fromRGBO(47, 85, 221, 1) : Colors.grey,
            ),
            label: 'Statistics',
          ),
        ],
        selectedItemColor: Color.fromRGBO(47, 85, 221, 1),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}