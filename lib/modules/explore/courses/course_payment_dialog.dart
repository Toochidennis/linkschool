import 'package:flutter/material.dart';
import 'package:linkschool/config/env_config.dart' show EnvConfig;
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/services/firebase_auth_service.dart';
import 'package:paystack_for_flutter/paystack_for_flutter.dart';
import 'package:provider/provider.dart';

/// Dialog to handle course payment
class CoursePaymentDialog extends StatefulWidget {
  final int amount;
  final VoidCallback onPaymentSuccess;
  final Future<bool> Function(String reference, int amountPaid) onPaymentCompleted;

  const CoursePaymentDialog({
    super.key,
    required this.amount,
    required this.onPaymentSuccess,
    required this.onPaymentCompleted,
  });

  @override
  State<CoursePaymentDialog> createState() => _CoursePaymentDialogState();
}

class _CoursePaymentDialogState extends State<CoursePaymentDialog>
    with SingleTickerProviderStateMixin {
  final _authService = FirebaseAuthService();
  final TextEditingController _voucherController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isProcessing = false;
  bool _showVoucher = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _voucherController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isProcessing,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Section
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.eLearningBtnColor1.withOpacity(0.1),
                            AppColors.eLearningBtnColor1.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.eLearningBtnColor1.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.credit_card_rounded,
                              size: 40,
                              color: AppColors.eLearningBtnColor1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Enroll Now',
                            style: AppTextStyles.normal700(
                              fontSize: 26,
                              color: AppColors.text4Light,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete your payment to start learning',
                            style: AppTextStyles.normal400(
                              fontSize: 14,
                              color: AppColors.text7Light,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Content Section
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Amount Display - Improved
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.eLearningBtnColor1,
                                  AppColors.eLearningBtnColor1.withOpacity(0.85),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.eLearningBtnColor1.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Course Fee',
                                  style: AppTextStyles.normal500(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '₦',
                                        style: AppTextStyles.normal700(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatAmount(widget.amount),
                                      style: AppTextStyles.normal700(
                                        fontSize: 36,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Payment/Voucher Section
                          if (!_showVoucher) ...[
                            // Pay Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isProcessing ? null : _handlePayment,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.eLearningBtnColor1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                  shadowColor: AppColors.eLearningBtnColor1.withOpacity(0.4),
                                ),
                                child: _isProcessing
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.lock_rounded,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Secure Payment',
                                            style: AppTextStyles.normal600(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Divider with "OR"
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.shade300,
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: AppTextStyles.normal500(
                                      fontSize: 12,
                                      color: AppColors.text7Light,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.shade300,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Voucher Button
                            InkWell(
                              onTap: _isProcessing
                                  ? null
                                  : () {
                                      setState(() => _showVoucher = true);
                                    },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.confirmation_number_outlined,
                                      size: 20,
                                      color: AppColors.text7Light,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'I have a voucher code',
                                      style: AppTextStyles.normal600(
                                        fontSize: 15,
                                        color: AppColors.text7Light,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            // Voucher Input Section
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.confirmation_number_rounded,
                                        size: 20,
                                        color: AppColors.eLearningBtnColor1,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Enter Voucher Code',
                                        style: AppTextStyles.normal600(
                                          fontSize: 15,
                                          color: AppColors.text4Light,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _voucherController,
                                    textCapitalization: TextCapitalization.characters,
                                    style: AppTextStyles.normal600(
                                      fontSize: 16,
                                      color: AppColors.text4Light,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'e.g., SAVE50',
                                      hintStyle: AppTextStyles.normal400(
                                        fontSize: 15,
                                        color: AppColors.text7Light,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppColors.eLearningBtnColor1,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: _isProcessing
                                          ? null
                                          : () {
                                              final code = _voucherController.text.trim();
                                              if (code.isEmpty) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Please enter a voucher code'),
                                                    backgroundColor: Colors.orange,
                                                  ),
                                                );
                                                return;
                                              }
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Voucher validation coming soon'),
                                                  backgroundColor: Colors.blue,
                                                ),
                                              );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.eLearningBtnColor1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        'Apply Voucher',
                                        style: AppTextStyles.normal600(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Back to payment
                            InkWell(
                              onTap: _isProcessing
                                  ? null
                                  : () {
                                      setState(() => _showVoucher = false);
                                    },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_back_rounded,
                                      size: 16,
                                      color: AppColors.text7Light,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Back to payment options',
                                      style: AppTextStyles.normal500(
                                        fontSize: 14,
                                        color: AppColors.text7Light,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Cancel Button
                          TextButton(
                            onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: AppTextStyles.normal600(
                                fontSize: 15,
                                color: AppColors.text7Light,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Future<void> _handlePayment() async {
    if (!mounted || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // Get user email
      final email = _authService.getCurrentUserEmail();
      if (email == null || email.isEmpty) {
        throw Exception('Unable to retrieve user email. Please sign in.');
      }

      final reference = 'COURSE_${DateTime.now().millisecondsSinceEpoch}';
      final amountInKobo = widget.amount * 100;

      print('Initiating Paystack payment...');
      print('Amount: NGN ${widget.amount}');
      print('Email: $email');
      print('Reference: $reference');

      PaystackFlutter().pay(
        context: context,
        secretKey: EnvConfig.paystackSecretKey,
        amount: amountInKobo.toDouble(),
        email: email,
        callbackUrl: 'https://callback.com',
        showProgressBar: true,
        paymentOptions: [
          PaymentOption.card,
          PaymentOption.bankTransfer,
          PaymentOption.mobileMoney,
        ],
        currency: Currency.NGN,
        metaData: {
          'payment_type': 'Course Enrollment',
          'amount_naira': widget.amount,
        },
        onSuccess: (callback) async {
          print('Payment successful: ${callback.reference}');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment successful!'),
                backgroundColor: Colors.green,
              ),
            );

            final paymentConfirmed = await widget.onPaymentCompleted(
              callback.reference,
              widget.amount,
            );

            if (!paymentConfirmed) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment not confirmed yet. Please try again.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
              return;
            }

            Navigator.of(context).pop(); // Close dialog
            widget.onPaymentSuccess();
          }
        },
        onCancelled: (callback) {
          print('Payment cancelled');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment cancelled'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
      );
    } catch (e) {
      print('❌ Payment error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}