// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
import 'package:linkschool/modules/admin_portal/payment/expenditure/expenditure_screen.dart';
import 'package:linkschool/modules/admin_portal/payment/receipt/generate_report/report_payment.dart';
import 'package:linkschool/modules/admin_portal/payment/receipt/payment_outstanding_screen.dart';
import 'package:linkschool/modules/admin_portal/payment/receipt/payment_received_screen.dart';
import 'package:linkschool/modules/admin_portal/payment/settings/payment_setting_screen.dart';
import 'package:linkschool/modules/admin_portal/payment/receipt/receipt_screen.dart';
import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';

class PaymentDashboardScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const PaymentDashboardScreen({super.key, required this.onLogout});

  @override
  State<PaymentDashboardScreen> createState() => _PaymentDashboardScreenState();
}

class _PaymentDashboardScreenState extends State<PaymentDashboardScreen> {
  late double opacity;
  bool _hideAmounts = false;
  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    CustomStudentAppBar customAppBar = CustomStudentAppBar(
      title: 'Revenue',
      showNotification: true,
      showSettings: true,
      centerTitle: true,
      onNotificationTap: () {
        // Handle notification icon press
      },
      onSettingsTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  PaymentSettingScreen(onLogout: widget.onLogout)),
        );
      },
    );


    return Scaffold(
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
                      color: const Color.fromRGBO(58, 49, 145, 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _hideAmounts =
                                      !_hideAmounts; // Toggle amount visibility
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _hideAmounts
                                        ? Icons.visibility_off
                                        : Icons.remove_red_eye,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _hideAmounts ? 'Show all' : 'Hide all',
                                    style:
                                        const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Expected Revenue',
                                    style: TextStyle(color: Colors.white)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    if (!_hideAmounts) ...[
                                      const NairaSvgIcon(
                                        color: AppColors.backgroundLight,
                                      ),
                                      const SizedBox(width: 4),
                                      const Text('234,790.00',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold)),
                                    ] else ...[
                                      const Text(
                                          '****', // Show asterisks if hidden
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoContainer('Received', '234,790.00',
                                  () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PaymentReceivedScreen(),
                                  ),
                                );
                              }),
                              _buildInfoContainer('Outstanding', '4,000.00',
                                  () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PaymentOutstandingScreen(),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Second section
                  Text('Records',
                      style: AppTextStyles.normal600(fontSize: 18, color: AppColors.backgroundDark)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRecordContainer(
                        'Receipt',
                        'assets/icons/e_learning/receipt_icon.svg',
                        const Color.fromRGBO(45, 99, 255, 1),
                        () {
                          // Navigate to Generate Receipt Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ReceiptScreen()),
                          );
                        },
                      ),
                      _buildRecordContainer(
                        'Expenditure',
                        'assets/icons/e_learning/expenditure_icon.svg',
                        const Color.fromRGBO(30, 136, 229, 1),
                        () {
                          // Navigate to Expenditure Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ExpenditureScreen()),
                          );
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transaction History',
                          style: AppTextStyles.normal600(fontSize: 18, color: AppColors.backgroundDark)),
                      GestureDetector(
                        onTap: () {
                          // Navigate to the report_payment screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ReportPaymentScreen()),
                          );
                        },
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            color: AppColors.paymentTxtColor1,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
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
    );
  }

  Widget _buildInfoContainer(String title, String value, VoidCallback onTap) {
    bool isOutstanding = title == 'Outstanding';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.paymentCtnColor1,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              isOutstanding ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(title,
                  style: AppTextStyles.normal600(
                      fontSize: 12, color: AppColors.assessmentColor1)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: title == 'Received'
                    ? MainAxisAlignment.start // Left align for 'Received'
                    : MainAxisAlignment.end, // Right align for 'Outstanding'
                children: [
                  if (!_hideAmounts) ...[
                    const NairaSvgIcon(color: AppColors.backgroundLight),
                    const SizedBox(width: 4),
                    Text(value,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ] else ...[
                    const Text('****', // Show asterisks if hidden
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordContainer(String title, String iconPath,
      Color backgroundColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        height: 75,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center content vertically
          children: [
            SvgPicture.asset(iconPath,
                width: 36, height: 36, color: Colors.white),
            const SizedBox(height: 4),
            Text(title, style: AppTextStyles.normal600(fontSize: 14, color: AppColors.backgroundLight)),
          ],
        ),
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
                        style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundDark)),
                    Text(time,
                        style: AppTextStyles.normal500(fontSize: 12, color: AppColors.text10Light)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      // Display plus/minus sign first
                      Text(
                        amount >= 0 ? '+' : '-',
                        style: AppTextStyles.normal700(fontSize: 16, color: amount >= 0 ? AppColors.paymentTxtColor4 : AppColors.paymentTxtColor3),
                      ),
                      const SizedBox(
                          width: 4), // Add spacing between sign and Naira icon
                      // Naira icon
                      NairaSvgIcon(
                          color: amount >= 0 ? Colors.green : Colors.red),
                      const SizedBox(
                          width:
                              4), // Add spacing between Naira icon and amount
                      // Amount text
                      Text(
                        amount.abs().toStringAsFixed(2),
                        style: TextStyle(
                          color: amount >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Text(grade, style: AppTextStyles.normal500(fontSize: 12, color: AppColors.paymentTxtColor1),),
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
