import 'package:flutter/material.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/services/firebase_auth_service.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
import 'package:provider/provider.dart';
import 'package:paystack_for_flutter/paystack_for_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:linkschool/modules/common/cbt_settings_helper.dart';

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
  final _authService = FirebaseAuthService();
  
  bool _isProcessing = false;
  int _subscriptionPrice = 400; // Default, will be updated from API
  double _discountRate = 0.0;
  
  static const String _paystackPublicKey = 'pk_test_YOUR_PUBLIC_KEY_HERE'; // Replace with your public key

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _setupPaymentReferenceListener();
  }
  
  Future<void> _loadSettings() async {
    try {
      final settings = await CbtSettingsHelper.getSettings();
      if (mounted) {
        setState(() {
          _subscriptionPrice = settings.discountRate > 0 
              ? (settings.amount * (1 - settings.discountRate)).round()
              : settings.amount;
          _discountRate = settings.discountRate;
        });
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  void _setupPaymentReferenceListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
      userProvider.paymentReferenceNotifier.addListener(() {
        final reference = userProvider.paymentReferenceNotifier.value;
        if (reference != null && reference.isNotEmpty && mounted) {
          print('💳 Payment reference detected: $reference');
          print('✅ Auto-dismissing payment dialog...');
          Navigator.of(context).pop();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => widget.canDismiss && !_isProcessing,
      child: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;
          final maxWidth = isLandscape
              ? MediaQuery.of(context).size.width * 0.7
              : MediaQuery.of(context).size.width * 0.85;

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.canDismiss && !_isProcessing)
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
                    _buildFeaturesList(),
                    const SizedBox(height: 24),
                    _buildPayButton(),
                  ],
                ),
              ),
            ),
          );
        },
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
          'Pay ₦$_subscriptionPrice to unlock unlimited CBT access',
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
              NairaSvgIcon(
                color: AppColors.eLearningBtnColor1,
                width: 20,
                height: 20,
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
          }),
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
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pay ',
                  style: AppTextStyles.normal600(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                NairaSvgIcon(
                  color: Colors.white,
                  width: 16,
                  height: 16,
                ),
                Text(
                  '$_subscriptionPrice',
                  style: AppTextStyles.normal600(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
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

      // Get user email
      final userEmail = _authService.getCurrentUserEmail();
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

      print('\n💳 Initiating Paystack Payment:');
      print(' Amount: ₦$_subscriptionPrice');
      print(' Email: $userEmail');

      // Charge with Paystack
      await _chargeWithPaystack(userEmail);

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

 Future<void> _chargeWithPaystack(String email) async {
  try {
    final amountInKobo = _subscriptionPrice * 100;
    final reference = _generateReference();
   final  paystackSecretKey = EnvConfig.paystackSecretKey;

    print('💳 Charging with Paystack using PaystackFlutter...');
    print(' Reference: $reference');

    PaystackFlutter().pay(
      context: context,
      secretKey: paystackSecretKey, // ❗ Not safe, but required by the package
      amount: amountInKobo.toDouble(),
      email: email,
   
      callbackUrl: "https://callback.com",
      showProgressBar: true,
      paymentOptions: [
        PaymentOption.card,
        PaymentOption.bankTransfer,
        PaymentOption.mobileMoney,
      ],
      currency: Currency.NGN,
      metaData: {
        "subscription": "CBT Access",
        "price": _subscriptionPrice,
      },
      onSuccess: (paystackCallback) async {
        print('✅ Payment successful: ${paystackCallback.reference}');
        await _verifyAndUpdatePayment(reference);
      },
      onCancelled: (paystackCallback) {
        print('❌ Payment cancelled or failed: ${paystackCallback.reference}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment cancelled'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  } catch (e) {
    print('❌ Paystack error: $e');
    throw Exception("Payment failed: $e");
  }
}


  Future<void> _verifyAndUpdatePayment(String reference) async {
    try {
      final paystackSecretKey = EnvConfig.paystackSecretKey;
      print('🔍 Verifying payment with Paystack...');
      
      final response = await http.get(
        Uri.parse('https://api.paystack.co/transaction/verify/$reference'),
        headers: {
          'Authorization': 'Bearer $paystackSecretKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == true && data['data']['status'] == 'success') {
          print('✅ Payment verified successfully');
          
          // Update user with payment reference via PUT request
          final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
          await userProvider.updateUserAfterPayment(reference: reference);
          
          print('✅ User updated with payment reference');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Payment Successful! Subscription activated.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            
            widget.onPaymentSuccess();
            // Dialog will be dismissed automatically by the notifier
          }
        } else {
          throw Exception('Payment verification failed');
        }
      } else {
        throw Exception('Verification request failed');
      }
    } catch (e) {
      print('❌ Verification error: $e');
      throw Exception('Payment verification failed: $e');
    }
  }

  String _generateReference() {
    return 'CBT_${DateTime.now().millisecondsSinceEpoch}';
  }
}