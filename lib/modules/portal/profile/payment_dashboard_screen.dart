// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/portal/profile/payment_setting_screen.dart';

class PaymentDashboardScreen extends StatefulWidget {
  @override
  State<PaymentDashboardScreen> createState() => _PaymentDashboardScreenState();
}

class _PaymentDashboardScreenState extends State<PaymentDashboardScreen> {
  late double opacity;
  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    PreferredSize customAppBar = PreferredSize(
      preferredSize:
          const Size.fromHeight(kToolbarHeight + 16), // Increased height
      child: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle
            .light, // This ensures status bar icons are visible
        toolbarHeight: kToolbarHeight + 16, // Increased toolbar height
        title: Padding(
          padding: const EdgeInsets.only(top: 42.0),
          child: Text(
            'Revenue',
            style: AppTextStyles.normal600(
              fontSize: 24.0,
              color: AppColors.primaryLight,
            ),
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
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 42.0),
            child: IconButton(
              icon: const Icon(Icons.settings),
              color: AppColors.textGray,
              onPressed: () {
                // Navigator.pushNamed(context, '/payment-settings');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PaymentSettingScreen()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 42.0),
            child: IconButton(
              icon: const Icon(Icons.notifications),
              color: AppColors.textGray,
              onPressed: () {
                // Handle notification icon press
              },
            ),
          ),
        ],
      ),
    );

    return Theme(
      data: Theme.of(context),
      child: Scaffold(
        appBar: customAppBar,
        body: SafeArea(
          child: Container(
            decoration: Constants.customBoxDecoration(context),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(58, 49, 145, 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.remove_red_eye,
                                      color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Hide all',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            const Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Expected Revenue',
                                        style: TextStyle(color: Colors.white)),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        NairaSvgIcon(),
                                        Text('234,790.00',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween, // Changed to space between
                              children: [
                                _buildInfoContainer('Paid', '234,790.00'),
                                _buildInfoContainer('Pending', '4,000.00'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Second section
                    const Text('Records',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRecordContainer(
                            'Generate Receipt',
                            'assets/icons/e_learning/receipt_icon.svg',
                            Color.fromRGBO(45, 99, 255, 1)),
                        _buildRecordContainer(
                            'Expenditure',
                            'assets/icons/e_learning/expenditure_icon.svg',
                            Color.fromRGBO(30, 136, 229, 1)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Transaction History',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          'See all',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTransactionItem('Dennis John', '17:30 AM, Yesterday',
                        23790.00, 'grade 2'),
                    _buildTransactionItem(
                        'Jane Smith', '10:45 AM, Today', -15000.00, 'grade 3'),
                    _buildTransactionItem('Alex Johnson', '14:20 PM, Yesterday',
                        40000.00, 'grade 1'),
                    _buildTransactionItem('Sarah Williams',
                        '09:00 AM, 2 days ago', -5000.00, 'grade 2'),
                    _buildTransactionItem('Sarah Williams',
                        '09:00 AM, 2 days ago', -3500.00, 'grade 2'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoContainer(String title, String value) {
    return Container(
      width: 131,
      height: 55,
      decoration: BoxDecoration(
        color: AppColors.paymentCtnColor1,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: AppTextStyles.normal600(
                  fontSize: 12, color: AppColors.assessmentColor1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const NairaSvgIcon(),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordContainer(
      String title, String iconPath, Color backgroundColor) {
    return Container(
      width: 158,
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(iconPath,
              width: 24, height: 24, color: Colors.white),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
      String name, String time, double amount, String grade) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.paymentBtnColor1,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                      'assets/icons/e_learning/receipt_list_icon.svg',
                      width: 24,
                      height: 24,
                      color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(time,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${amount >= 0 ? '+' : '-'} ₦${amount.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      color: amount >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(grade,
                      style: const TextStyle(color: Colors.blue, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class NairaSvgIcon extends StatelessWidget {
  const NairaSvgIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/e_learning/naira_icon.svg', // Make sure to add this SVG to your assets
      width: 16,
      height: 16,
      color: Colors.white,
    );
  }
}
