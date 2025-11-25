import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/services/cbt_subscription_service.dart';
import 'package:linkschool/modules/services/firebase_auth_service.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:linkschool/modules/explore/e_library/widgets/paystack_cbt_webview.dart';

/// Dialog to show subscription plans and handle Paystack payment
class PaystackPaymentDialog extends StatefulWidget {
  final VoidCallback onPaymentSuccess;
  final VoidCallback? onCancel;
  final bool canDismiss;

  const PaystackPaymentDialog({
    super.key,
    required this.onPaymentSuccess,
    this.onCancel,
    this.canDismiss = true,
  });

  @override
  State<PaystackPaymentDialog> createState() => _PaystackPaymentDialogState();
}

class _PaystackPaymentDialogState extends State<PaystackPaymentDialog> {
  final _subscriptionService = CbtSubscriptionService();
  final _authService = FirebaseAuthService();
  bool _isProcessing = false;
  
  // Paystack secret key
  static const String _paystackSecretKey = 'sk_test_96d9c3448796ac0b090dfc18a818c67a292faeea';
  
  // Single subscription price
  static const int _subscriptionPrice = 400; // ₦400 to continue using service

  @override
  void initState() {
    super.initState();
    _setupPaymentReferenceListener();
  }

  void _setupPaymentReferenceListener() {
    // Listen to payment reference changes from the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
      userProvider.paymentReferenceNotifier.addListener(() {
        final reference = userProvider.paymentReferenceNotifier.value;
        if (reference != null && reference.isNotEmpty && mounted) {
          print('💳 Payment reference detected: $reference');
          print('✅ Auto-dismissing payment dialog...');
          // Dismiss the dialog automatically when reference is saved
          Navigator.of(context).pop();
        }
      });
    });
  }

  @override
  void dispose() {
    // Clean up listener if needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => widget.canDismiss,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.canDismiss)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      if (widget.onCancel != null) {
                        widget.onCancel!();
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              const SizedBox(height: 8),
              _buildHeader(),
              const SizedBox(height: 24),
             // _buildFeaturesList(),
              const SizedBox(height: 24),
              _buildPayButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.eLearningBtnColor1.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.workspace_premium,
            size: 48,
            color: AppColors.eLearningBtnColor1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Continue Learning',
          style: AppTextStyles.normal700(
            fontSize: 24,
            color: AppColors.text4Light,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Pay ₦400 to unlock unlimited CBT access',
          style: AppTextStyles.normal400(
            fontSize: 14,
            color: AppColors.text7Light,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      'Unlimited CBT tests',
      'All subjects & years access',
      'Detailed performance analytics',
      'Complete test history',
      'No ads',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.eLearningBtnColor1.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Price display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '₦',
                style: AppTextStyles.normal600(
                  fontSize: 20,
                  color: AppColors.eLearningBtnColor1,
                ),
              ),
              Text(
                '$_subscriptionPrice',
                style: AppTextStyles.normal700(
                  fontSize: 48,
                  color: AppColors.eLearningBtnColor1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'One-time payment',
            style: AppTextStyles.normal500(
              fontSize: 14,
              color: AppColors.text7Light,
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 16),
          // Features list
          ...features.map((feature) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 20,
                    color: AppColors.attCheckColor2,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTextStyles.normal500(
                        fontSize: 14,
                        color: AppColors.text4Light,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return ElevatedButton(
      onPressed: _isProcessing ? null : _handlePayment,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.eLearningBtnColor1,
        disabledBackgroundColor: Colors.grey,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: _isProcessing
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              'Pay ₦$_subscriptionPrice',
              style: AppTextStyles.normal600(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
    );
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Check if user is signed in
      final isSignedIn = await _authService.isUserSignedUp();
      if (!isSignedIn) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in first to continue with payment'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Get user email for Paystack
      final userEmail = await _authService.getCurrentUserEmail();
      if (userEmail == null || userEmail.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to retrieve user email'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      final amountInKobo = _subscriptionPrice * 100; // Convert to kobo
      final reference = _generateReference();

      print('\n💳 Initializing Paystack Payment:');
      print('   Amount: ₦$_subscriptionPrice');
      print('   Email: $userEmail');
      print('   Reference: $reference');

      // Initialize Paystack transaction
      final response = await http.post(
        Uri.parse('https://api.paystack.co/transaction/initialize'),
        headers: {
          'Authorization': 'Bearer $_paystackSecretKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': userEmail,
          'amount': amountInKobo,
          'reference': reference,
          'metadata': {
            'subscription_type': 'CBT Premium Access',
            'amount_naira': _subscriptionPrice,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == true) {
          final String authorizationUrl = data['data']['authorization_url'];
          final String paystackReference = data['data']['reference'];

          print('✅ Payment initialization successful');
          print('   Authorization URL: $authorizationUrl');
          print('   Reference: $paystackReference');

          if (!mounted) return;

          // Navigate to Paystack webview
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PaystackCbtWebView(
                checkoutUrl: authorizationUrl,
                reference: paystackReference,
                onPaymentSuccess: () {
                  // Payment success callback
                  // Dialog will be dismissed automatically by the notifier
                  print('✅ Payment successful - waiting for reference notification');
                  widget.onPaymentSuccess();
                },
                onPaymentFailed: () {
                  // Handle payment failure
                  print('❌ Payment failed in webview');
                },
              ),
            ),
          );
          // Note: Dialog dismissal is now handled by the paymentReferenceNotifier
        } else {
          throw Exception(data['message'] ?? 'Payment initialization failed');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Payment initialization failed');
      }
    } catch (e) {
      print('❌ Payment error: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String _generateReference() {
    // Generate unique payment reference
    return 'CBT_${DateTime.now().millisecondsSinceEpoch}';
  }
}
