import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/services/firebase_auth_service.dart';
import 'package:linkschool/modules/explore/e_library/widgets/paystack_cbt_webview.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
import 'package:paystack_for_flutter/paystack_for_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:linkschool/modules/common/cbt_settings_helper.dart';

/// Dialog to enforce subscription after free trial ends
class SubscriptionEnforcementDialog extends StatefulWidget {
  final VoidCallback onSubscribed;
  final int remainingTests;
  final bool isHardBlock;
  final int amount;
  final double discountRate;

  const SubscriptionEnforcementDialog({
    super.key,
    required this.onSubscribed,
    this.remainingTests = 0,
    this.isHardBlock = false,
    required this.amount,
    this.discountRate = 0.0,
  });

  @override
  State<SubscriptionEnforcementDialog> createState() =>
      _SubscriptionEnforcementDialogState();
}

class _SubscriptionEnforcementDialogState
    extends State<SubscriptionEnforcementDialog>
    with SingleTickerProviderStateMixin {
  final _authService = FirebaseAuthService();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isUserSignedIn = false;
  bool _isCheckingSignin = true;
  bool _isProcessing = false; // ⚡ Single processing flag

  @override
  void initState() {
    super.initState();
    _checkSigninStatus();

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

    // Listen for paymentReferenceNotifier to dismiss dialog if paid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
      userProvider.paymentReferenceNotifier.addListener(() {
        if (userProvider.hasPaid == true && mounted) {
          widget.onSubscribed();
          Navigator.of(context).pop();
        }
      });
    });
  }

  Future<void> _checkSigninStatus() async {
    try {
      final isSignedIn = await _authService.isUserSignedUp();
      final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
      final hasPaid = userProvider.hasPaid;
      if (mounted) {
        setState(() {
          _isUserSignedIn = isSignedIn;
          _isCheckingSignin = false;
        });
        // If user is signed in and has paid, immediately pop dialog
        if (isSignedIn && hasPaid) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingSignin = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isProcessing, // ⚡ Prevent dismissal during processing
      child: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;
          final screenWidth = MediaQuery.of(context).size.width;
          final dialogWidth = isLandscape
              ? screenWidth * 0.60 // 60% width in landscape
              : screenWidth * 0.92; // 92% width in portrait

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isLandscape ? 600 : 450,
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Close button at top
                            if (!_isProcessing)
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            // Scrollable content
                            Flexible(
                              child: SingleChildScrollView(
                                child: _buildContent(),
                              ),
                            ),
                          ],
                        ),
                        // ⏳ Processing overlay
                        if (_isProcessing)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Processing...',
                                      style: AppTextStyles.normal600(
                                        fontSize: 16,
                                        color: AppColors.text4Light,
                                      ),
                                    ),
                                  ],
                                ),
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
        },
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isHardBlock) {
      return _buildHardBlockContent();
    } else {
      return _buildSoftPromptContent();
    }
  }

  Widget _buildHardBlockContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.eLearningRedBtnColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline,
              size: 64,
              color: AppColors.eLearningRedBtnColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Free Trial Ended',
            style: AppTextStyles.normal700(
              fontSize: 26,
              color: AppColors.text4Light,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FutureBuilder<int>(
            future: CbtSettingsHelper.getFreeTrialDays(),
            builder: (context, snapshot) {
              final freeTrialDays = snapshot.data ?? 3;
              final hasDiscount = widget.discountRate > 0;
              final discountedAmount = hasDiscount
                  ? (widget.amount * (1 - widget.discountRate)).round()
                  : widget.amount;

              return Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: "Your ",
                    ),
                    TextSpan(
                      text: '$freeTrialDays-day',
                      style: AppTextStyles.normal700(
                        fontSize: 15,
                        color: AppColors.text4Light,
                      ),
                    ),
                    const TextSpan(
                      text: ' free trial has ended. Pay ',
                    ),
                    if (hasDiscount) ...[
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: NairaSvgIcon(
                          color: Colors.grey,
                          width: 12,
                          height: 12,
                        ),
                      ),
                      TextSpan(
                        text: '${widget.amount}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const TextSpan(text: ' '),
                    ],
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: NairaSvgIcon(
                        color: Colors.black,
                        width: 15,
                        height: 15,
                      ),
                    ),
                    TextSpan(
                      text: '$discountedAmount',
                      style: AppTextStyles.normal700(
                          fontSize: 15, color: Colors.black),
                    ),
                    if (hasDiscount)
                      TextSpan(
                        text: ' (${(widget.discountRate * 100).toInt()}% off)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const TextSpan(
                      text:
                          ' to continue your learning journey with unlimited access.',
                    ),
                  ],
                ),
                style: AppTextStyles.normal400(
                  fontSize: 15,
                  color: AppColors.text7Light,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
          const SizedBox(height: 10),
          _buildPriceDisplay(36),
          const SizedBox(height: 10),
          _buildFeaturesList(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isCheckingSignin || _isProcessing)
                  ? null
                  : _handleSubscribe,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.eLearningBtnColor1,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isCheckingSignin || _isProcessing
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
                        Icon(
                          _isUserSignedIn ? Icons.payment : Icons.person_add,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isUserSignedIn
                              ? 'Subscribe Now'
                              : 'Sign Up & Subscribe',
                          style: AppTextStyles.normal600(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoftPromptContent() {
    return Padding(
      padding: const EdgeInsets.all(32),
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
              Icons.workspace_premium,
              size: 56,
              color: AppColors.eLearningBtnColor1,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Upgrade to Premium',
            style: AppTextStyles.normal700(
              fontSize: 24,
              color: AppColors.text4Light,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'You have ${widget.remainingTests} day${widget.remainingTests == 1 ? '' : 's'} remaining in your free trial. Pay ₦${widget.amount} now for unlimited access!',
            style: AppTextStyles.normal400(
              fontSize: 14,
              color: AppColors.text7Light,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildPriceDisplay(32),
          const SizedBox(height: 10),
          _buildFeaturesList(),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isCheckingSignin || _isProcessing)
                  ? null
                  : _handleSubscribe,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.eLearningBtnColor1,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isCheckingSignin || _isProcessing
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
                        NairaSvgIcon(
                          color: Colors.white,
                          width: 14,
                          height: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isUserSignedIn
                              ? 'Pay ${widget.amount}'
                              : 'Sign Up & Pay ${widget.amount}',
                          style: AppTextStyles.normal600(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
            child: Text(
              'Maybe Later',
              style: AppTextStyles.normal500(
                fontSize: 14,
                color: AppColors.text7Light,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDisplay(double fontSize) {
    final hasDiscount = widget.discountRate > 0;
    final originalPrice = widget.amount;
    final discountedPrice = hasDiscount
        ? (originalPrice * (1 - widget.discountRate)).round()
        : originalPrice;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.eLearningBtnColor1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (hasDiscount)
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 4),
            //   child: Text(
            //     '${(widget.discountRate * 100).toInt()}% discount applied!',
            //     style: TextStyle(
            //       color: Colors.green,
            //       fontSize: fontSize * 0.65,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NairaSvgIcon(
                  color: AppColors.eLearningBtnColor1,
                  width: fontSize,
                  height: fontSize,
                ),
                Text(
                  '${discountedPrice}',
                  style: AppTextStyles.normal400(
                    fontSize: fontSize,
                    color: AppColors.eLearningBtnColor1,
                  ),
                ),
                if (hasDiscount)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      children: [
                        NairaSvgIcon(
                          color: Colors.grey,
                          width: fontSize * 0.7,
                          height: fontSize * 0.7,
                        ),
                        Text(
                          originalPrice.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      'Unlimited CBT tests',
      'Detailed performance analytics',
      'Complete test history',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
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
      ),
    );
  }

  // =========================================================================
  // ⚡ OPTIMIZED SUBSCRIPTION HANDLER - NO NESTED DIALOGS
  // =========================================================================
  // =========================================================================
// ⚡ OPTIMIZED SUBSCRIPTION HANDLER - NO NESTED DIALOGS
// =========================================================================
  Future<void> _handleSubscribe() async {
    if (!mounted || _isProcessing) return;

    setState(() => _isProcessing = true);

    final userProvider = Provider.of<CbtUserProvider>(context, listen: false);

    try {
      // Step 1: Ensure user is signed in
      if (!_isUserSignedIn) {
        final userCredential = await _authService.signInWithGoogle();
        if (userCredential == null || userCredential.user == null) {
          _showError('Sign-in was cancelled or failed');
          return;
        }
        final user = userCredential.user!;
        await userProvider.handleFirebaseSignUp(
          email: user.email ?? '',
          name: user.displayName ?? '',
          profilePicture: user.photoURL ?? '',
        );
        setState(() => _isUserSignedIn = true);

        // Check if user has already paid after sign-in
        if (userProvider.hasPaid) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ You already have an active subscription!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            widget.onSubscribed();
            //Navigator.of(context).pop(); // Dismiss dialog if already paid
          }
          return;
        }
      }

      // Step 2: Get email & generate reference
      final email = await _authService.getCurrentUserEmail();
      if (email == null || email.isEmpty) {
        throw Exception('Unable to retrieve user email');
      }
      final reference = 'CBT_${DateTime.now().millisecondsSinceEpoch}';

      // Calculate discounted amount
      final hasDiscount = widget.discountRate > 0;
      final finalAmount = hasDiscount
          ? (widget.amount * (1 - widget.discountRate)).round()
          : widget.amount;
      final amountInKobo = finalAmount * 100;

      print('💳 Initiating PaystackFlutter payment...');
      print(' Original Amount: ₦${widget.amount}');
      print(' Discount Rate: ${widget.discountRate}');
      print(' Final Amount: ₦$finalAmount');
      print(' Email: $email');
      print(' Reference: $reference');
      final paystackSecretKey = dotenv.env['PAYSTACK_SECRET_KEY'] ?? '';
      // Step 3: Call PaystackFlutter payment
      PaystackFlutter().pay(
        context: context,
        secretKey: paystackSecretKey,
        // secretKey: 'sk_test_96d9c3448796ac0b090dfc18a818c67a292faeea', // Your secret key
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
          'subscription_type': 'CBT Premium Access',
          'original_price': widget.amount,
          'discount_rate': widget.discountRate,
          'final_price': finalAmount,
        },
        onSuccess: (callback) async {
          print('✅ Payment successful: ${callback.reference}');

          // Update user after payment
          await userProvider.updateUserAfterPayment(
              reference: callback.reference);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Payment Successful! Subscription activated.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            widget.onSubscribed();
            Navigator.of(context)
                .pop(); // Dismiss dialog after successful payment
          }
        },
        onCancelled: (callback) {
          print('❌ Payment cancelled or failed: ${callback.reference}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment cancelled'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      print('❌ Subscription payment error: $e');
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // =========================================================================
  // 💳 PAYMENT INITIALIZATION (NON-BLOCKING)
  // =========================================================================
  Future<Map<String, String>> _initializePayment(String userEmail) async {
    final amountInKobo = widget.amount * 100;
    final reference = 'CBT_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final response = await http
          .post(
            Uri.parse('https://api.paystack.co/transaction/initialize'),
            headers: {
              'Authorization':
                  'Bearer sk_test_96d9c3448796ac0b090dfc18a818c67a292faeea',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'email': userEmail,
              'amount': amountInKobo,
              'reference': reference,
              'metadata': {
                'subscription_type': 'CBT Premium Access',
                'amount_naira': widget.amount,
              },
            }),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw Exception('Payment initialization timed out'),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true) {
          return {
            'authorizationUrl': data['data']['authorization_url'],
            'reference': data['data']['reference'],
          };
        } else {
          throw Exception(data['message'] ?? 'Payment initialization failed');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Payment initialization failed: $e');
    }
  }

  // =========================================================================
  // 🚨 ERROR HANDLER
  // =========================================================================
  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );

    if (!widget.isHardBlock) {
      Navigator.of(context).pop();
    }
  }
}
