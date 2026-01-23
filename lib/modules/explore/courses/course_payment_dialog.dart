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
  final Function(String reference, int amountPaid) onPaymentCompleted;

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
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isProcessing = false;

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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isProcessing,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.eLearningBtnColor1.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.payment,
                      size: 48,
                      color: AppColors.eLearningBtnColor1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Complete Payment',
                    style: AppTextStyles.normal700(
                      fontSize: 24,
                      color: AppColors.text4Light,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pay ₦${widget.amount} to enroll in this course',
                    style: AppTextStyles.normal400(
                      fontSize: 16,
                      color: AppColors.text7Light,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.eLearningBtnColor1.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₦${widget.amount}',
                      style: AppTextStyles.normal700(
                        fontSize: 28,
                        color: AppColors.eLearningBtnColor1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handlePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.eLearningBtnColor1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Pay Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.text7Light,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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

      print('💳 Initiating Paystack payment...');
      print('Amount: ₦${widget.amount}');
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
          print('✅ Payment successful: ${callback.reference}');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment successful!'),
                backgroundColor: Colors.green,
              ),
            );

            // Call the completion callback with reference and amount
            widget.onPaymentCompleted(callback.reference, widget.amount);

            Navigator.of(context).pop(); // Close dialog
            widget.onPaymentSuccess();
          }
        },
        onCancelled: (callback) {
          print('❌ Payment cancelled');
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