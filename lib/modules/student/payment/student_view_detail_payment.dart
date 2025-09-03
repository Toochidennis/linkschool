

// StudentViewDetailPaymentDialog.dart

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:dotted_line/dotted_line.dart';

import 'package:linkschool/modules/model/student/payment_model.dart';
import 'package:linkschool/modules/providers/student/payment_submission_provider.dart';
import 'package:linkschool/modules/student/payment/paystack_webview.dart';
import 'package:provider/provider.dart';

class StudentViewDetailPaymentDialog extends StatefulWidget {
  final Invoice invoice;

  const StudentViewDetailPaymentDialog({
    super.key,
    required this.invoice,
  });

  @override
  State<StudentViewDetailPaymentDialog> createState() =>
      _StudentViewDetailPaymentDialogState();
}

class _StudentViewDetailPaymentDialogState
    extends State<StudentViewDetailPaymentDialog> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController =
      TextEditingController();
  late List<bool> _selectedFees;

  @override
  void initState() {
    super.initState();
    _selectedFees = List.generate(widget.invoice.details.length, (_) => false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentProvider>(context, listen: false);
    });
  }

  String _formatAmount(double amount) {
   
    return '${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  double _calculateSelectedTotal() {
    double total = 0;
    for (int i = 0; i < widget.invoice.details.length; i++) {
      if (_selectedFees[i]) {
        total += widget.invoice.details[i].feeAmount;
      }
    }
    return total;
  }

  getuserdata() {
    final userBox = Hive.box('userData');
    final storedUserData =
        userBox.get('userData') ?? userBox.get('loginResponse');
    final processedData =
        storedUserData is String ? json.decode(storedUserData) : storedUserData;
    final response = processedData['response'] ?? processedData;
    final data = response['data'] ?? response;
    final user = data['profile'] ?? data;
    return user;
  }

  getuserSettings() {
    final userBox = Hive.box('userData');
    final storedUserData =
        userBox.get('userData') ?? userBox.get('loginResponse');
    final processedData =
        storedUserData is String ? json.decode(storedUserData) : storedUserData;
    final response = processedData['response'] ?? processedData;
    final data = response['data'] ?? response;
    final settings = data['settings'] ?? data;
    return settings;
  }

  bool get _hasSelection => _selectedFees.contains(true);

  void _showIdentityConfirmation() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Confirm Identity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add email address'),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your email',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Confirm email address'),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmEmailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Confirm your email',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        if (_emailController.text.isNotEmpty &&
                            _emailController.text ==
                                _confirmEmailController.text) {
                          if (_calculateSelectedTotal() == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Please select at least one fee.')),
                            );
                            return;
                          }
                          await initializePayment(
                            _emailController.text,
                            _calculateSelectedTotal().toInt(),
                            '${widget.invoice.year} Term ${widget.invoice.termName} Fees',
                          );
                        }
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $error')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F55DD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Proceed',
                        style: AppTextStyles.normal500(
                          fontSize: 16.0,
                          color: AppColors.backgroundLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> initializePayment(
      String email, int amount, String description) async {
    const String paystackSecretKey =
        'sk_test_b4681ae0b21bc31924009cefa8a3ee8fee0da634';
    const url = 'https://api.paystack.co/transaction/initialize';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $paystackSecretKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'amount': amount * 100,
        'metadata': {'description': description}
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final String paymentUrl = data['data']['authorization_url'];
      final String paystackReference = data['data']['reference'];

      print("✅ Payment URL: $paymentUrl");
      print("✅ Paystack Reference: $paystackReference");

      final user = getuserdata();
      final settings = getuserSettings();

      // Calculate unpaid fees total
      double unpaidFeesTotal = 0.0;
      for (int i = 0; i < widget.invoice.details.length; i++) {
        if (!_selectedFees[i]) {
          unpaidFeesTotal += widget.invoice.details[i].feeAmount;
        }
      }
      Navigator.pop(context); // close bottom sheet
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaystackWebView(
              checkoutUrl: paymentUrl,
              reference: paystackReference, // ✅ fixed
              dbName: 'aalmgzmy_linkskoo_practice',
              invoiceId: widget.invoice.id.toString(),
              regNo: user['registration_no'] ?? '',
              name: user['name'] ?? '',
              amount: _calculateSelectedTotal().toInt(),
              fees: widget.invoice.details
                  .asMap()
                  .entries
                  .where((entry) => _selectedFees[entry.key])
                  .map((entry) => {
                        "fee_id": entry.value.feeId,
                        'fee_name': entry.value.feeName, // ✅ fixed
                        'amount': entry.value.feeAmount.toString(),
                      })
                  .toList(),
              classId: int.parse(user['class_id'].toString()),
              levelId: int.parse(user['level_id'].toString()),
              year: int.parse(settings['year'].toString()),
              term: int.parse(settings['term'].toString()),
              email: _emailController.text,
              studentId: user['student_id'].toString(),
            ),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(1, 248, 248, 248),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: const Color(0xFF1565C0),
            width: 28,
            height: 28,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFE6F4EA),
                        radius: 26,
                        child: Image.asset(
                          'assets/icons/invoice.png',
                          height: 26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.invoice.termName} Fee Charges for \n${widget.invoice.year} Session',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.normal600(
                          fontSize: 20,
                          color: AppColors.backgroundDark,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const DottedLine(
                        dashLength: 4,
                        dashColor: Colors.grey,
                      ),
                      Text(
                        'Select fees to pay',
                        style: AppTextStyles.normal400(
                          fontSize: 14,
                          color: AppColors.backgroundDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.invoice.details.length,
                        itemBuilder: (context, index) {
                          final fee = widget.invoice.details[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _selectedFees[index],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedFees[index] = value!;
                                          });
                                        },
                                      ),
                                      Flexible(
                                        child: Text(
                                          fee.feeName,
                                          style: AppTextStyles.normal400(
                                            fontSize: 13,
                                            color: AppColors.backgroundDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    const NairaSvgIcon(
                                      color: AppColors.backgroundDark,
                                      width: 13,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatAmount(fee.feeAmount),
                                      style: AppTextStyles.normal600(
                                        fontSize: 18,
                                        color: AppColors.backgroundDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const DottedLine(
                        dashLength: 4,
                        dashColor: Colors.grey,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total amount to pay :',
                            style: AppTextStyles.normal400(
                              fontSize: 15,
                              color: AppColors.backgroundDark,
                            ),
                          ),
                          Row(
                            children: [
                              const NairaSvgIcon(
                                color: AppColors.backgroundDark,
                                width: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatAmount(_calculateSelectedTotal()),
                                style: AppTextStyles.normal600(
                                  fontSize: 22,
                                  color: AppColors.backgroundDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            if (!_hasSelection) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select at least one fee to continue.'),
                ),
              );
              return;
            }
            _showIdentityConfirmation();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _hasSelection
                ? const Color(0xFF2F55DD)
                : Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Proceed to pay',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
