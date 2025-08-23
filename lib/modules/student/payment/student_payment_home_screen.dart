import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:linkschool/modules/model/student/payment_model.dart';
import 'package:linkschool/modules/providers/student/payment_provider.dart';
import 'package:linkschool/modules/student/payment/see_all_payments.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
import 'package:linkschool/modules/student/payment/student_reciept_dialog.dart';
import 'package:linkschool/modules/student/payment/student_setting_dialog.dart';
import 'package:linkschool/modules/student/payment/student_view_detail_payment.dart';

class StudentPaymentHomeScreen extends StatefulWidget {
  final VoidCallback logout;

  const StudentPaymentHomeScreen({
    super.key,
    required this.logout,
  });

  @override
  _StudentPaymentHomeScreenState createState() => _StudentPaymentHomeScreenState();
}

class _StudentPaymentHomeScreenState extends State<StudentPaymentHomeScreen> {
  int _currentCardIndex = 0;
  late double opacity;

  String _formatAmount(double amount) {
    return '${amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]},'
    )}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvoiceProvider>(context, listen: false).fetchInvoiceData('277');
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StudentSettingDialog(logout: widget.logout);
      },
    );
  }

  void _navigateToViewDetailDialog(Invoice invoice) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentViewDetailPaymentDialog(invoice: invoice),
      ),
    );
  }

  void _showReceiptDialog(Payment payment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StudentRecieptDialog(payment: payment);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentId = '277';
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    if (invoiceProvider.invoiceData == null) {
      invoiceProvider.fetchInvoiceData(studentId);
    }
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomStudentAppBar(
        title: 'Welcome',
        subtitle: 'Tochukwu',
        showNotification: true,
        showSettings: true,
        onNotificationTap: () {},
        onSettingsTap: _showSettingsDialog,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (invoiceProvider.isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (invoiceProvider.error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${invoiceProvider.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (invoiceProvider.invoices == null || invoiceProvider.invoices!.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No current invoices available'),
              )
            else ...[
              CarouselSlider(
                options: CarouselOptions(
                  height: 150,
                  viewportFraction: 0.93,
                  enableInfiniteScroll: invoiceProvider.invoices!.length > 1,
                  autoPlay: invoiceProvider.invoices!.length > 1,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentCardIndex = index;
                    });
                  },
                ),
                items: invoiceProvider.invoices!.map((invoice) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.eLearningBtnColor1,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 8.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        ' ${invoice.year} ${invoice.termName} Fees',
                                        style: const TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                      const SizedBox(height: 25),
                                      Row(
                                        children: [
                                          const NairaSvgIcon(
                                                color: Colors.white,
                                               size: 25,
                                              ),
                                          Text(
                                            _formatAmount(invoice.amount),
                                            style: AppTextStyles.normal710(
                                              fontSize: 27,
                                              color: AppColors.backgroundLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(198, 210, 255, 1),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        _navigateToViewDetailDialog(invoice);
                                      },
                                      child: Text(
                                        'Pay Now',
                                        style: AppTextStyles.normal500(
                                          fontSize: 14,
                                          color: AppColors.paymentTxtColor1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              if (invoiceProvider.invoices!.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: invoiceProvider.invoices!.asMap().entries.map((entry) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentCardIndex == entry.key
                            ? const Color.fromRGBO(33, 150, 243, 1)
                            : const Color.fromRGBO(224, 224, 224, 1),
                      ),
                    );
                  }).toList(),
                ),
            ],
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Payment History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
               TextButton(
                    onPressed: () {
                      final payments = invoiceProvider.payments ?? [];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentHistorySeeAllScreen(payments: payments),
                        ),
                      );
                    },
                    child: const Text('See all'),
                  ),
                ],
              ),
            ),
            if (invoiceProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (invoiceProvider.error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${invoiceProvider.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (invoiceProvider.payments == null || invoiceProvider.payments!.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No payment history available'),
              )
            else
              Column(
                children: invoiceProvider.payments!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final payment = entry.value;

                  return Column(
                    children: [
                      PaymentHistoryItem(
                        payment: payment,
                        onTap: () => _showReceiptDialog(payment),
                      ),
                      if (index != invoiceProvider.payments!.length - 1)
                        const Divider(color: Colors.grey, thickness: 0.5, height: 1),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class PaymentHistoryItem extends StatelessWidget {
  final Payment payment;
  final VoidCallback onTap;

  const PaymentHistoryItem({
    Key? key,
    required this.payment,
    required this.onTap,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatAmount(double amount) {
    return '${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: Container(
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
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          '${payment.year} ${payment.termName} Fees',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          _formatDate(payment.date),
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const NairaSvgIcon(color: AppColors.paymentTxtColor5, size:16,),
                const SizedBox(width: 2),
                Text(
                  _formatAmount(payment.amount),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Text(
              'Paid',
              style: TextStyle(color: Colors.green, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}