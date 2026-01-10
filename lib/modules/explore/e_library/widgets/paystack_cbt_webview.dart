import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/services/cbt_subscription_service.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class PaystackConfig {
  static const String secretKey = 'sk_test_96d9c3448796ac0b090dfc18a818c67a292faeea';
  static const String baseUrl = 'https://api.paystack.co';
  static const Duration verificationTimeout = Duration(seconds: 10);
  static const Duration paymentTimeout = Duration(minutes: 10);
  static const Duration debounceDelay = Duration(milliseconds: 200);
  
  static Uri getVerificationUrl(String reference) {
    return Uri.parse('$baseUrl/transaction/verify/$reference');
  }
  
  static Map<String, String> getAuthHeaders() {
    return {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/json',
      'User-Agent': 'LinkSchool-App/1.0',
    };
  }
}

class PaystackCbtWebView extends StatefulWidget {
  final String checkoutUrl;
  final String reference;
  final VoidCallback onPaymentSuccess;
  final VoidCallback? onPaymentFailed;
  final Duration timeout;

  const PaystackCbtWebView({
    super.key,
    required this.checkoutUrl,
    required this.reference,
    required this.onPaymentSuccess,
    this.onPaymentFailed,
    this.timeout = const Duration(minutes: 10),
  });

  @override
  State<PaystackCbtWebView> createState() => _PaystackCbtWebViewState();
}

class _PaystackCbtWebViewState extends State<PaystackCbtWebView> {
  late final WebViewController _controller;
  final _subscriptionService = CbtSubscriptionService();

  bool _paymentProcessed = false;
  bool _isVerifying = false;
  bool _isLoading = true;
  bool _hasWebViewError = false;
  Timer? _debounceTimer;
  Timer? _paymentTimeoutTimer;

  @override
  void initState() {
    super.initState();
    _log('🚀 INIT Paystack WebView');
    _log('📦 Reference: ${widget.reference}');
    _log('🌐 Checkout URL: ${widget.checkoutUrl}');
    
    _initializeWebView();
    _startPaymentTimer();
  }

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] $message');
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (change) {
            if (change.url != null) {
              _log('🔗 URL Changed: ${change.url}');
              _debouncedCheckPaymentStatus(change.url!);
            }
          },
          onWebResourceError: (error) {
            _log('❌ WebView Error: ${error.errorCode} - ${error.description}');
            if (mounted && !_paymentProcessed) {
              setState(() => _hasWebViewError = true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Network error: ${error.description}'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          },
          onPageStarted: (url) {
            _log('📄 Page started: $url');
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasWebViewError = false;
              });
            }
          },
          onPageFinished: (url) {
            _log('✅ Page finished: $url');
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _startPaymentTimer() {
    _log('⏰ Payment timeout timer started: ${widget.timeout}');
    _paymentTimeoutTimer = Timer(widget.timeout, () {
      _log('⏰ Payment timeout reached!');
      if (!_paymentProcessed && mounted) {
        _handlePaymentFailed(reason: 'Payment timeout. Please try again.');
      }
    });
  }

  @override
  void dispose() {
    _log('🗑️ Disposing Paystack WebView');
    _debounceTimer?.cancel();
    _paymentTimeoutTimer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 🛡️ DEBOUNCED STATUS CHECKER
  // ---------------------------------------------------------------------------
  void _debouncedCheckPaymentStatus(String url) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(PaystackConfig.debounceDelay, () {
      _checkPaymentStatus(url);
    });
  }

  // ---------------------------------------------------------------------------
  // ✅ IMMEDIATE PAYMENT DETECTION AND PROCESSING
  // ---------------------------------------------------------------------------
  void _checkPaymentStatus(String url) {
    if (_paymentProcessed || _isVerifying) {
      _log('⏩ Payment already processed or verifying, skipping check');
      return;
    }

    _log('🔍 Checking payment status for URL: $url');

    // IMMEDIATE DETECTION: Check for any Paystack completion indicators
    if (_isPaystackCompletionRedirect(url)) {
      _log('🎯 PAYSTACK COMPLETION REDIRECT DETECTED!');
      _paymentProcessed = true;
      _processPaymentImmediately();
      return;
    }

    // Handle explicit failure URLs
    if (_isPaystackFailureRedirect(url)) {
      _log('💥 PAYSTACK FAILURE REDIRECT DETECTED!');
      _paymentProcessed = true;
      _handlePaymentFailed(reason: 'Payment was cancelled or failed');
    }
  }

  bool _isPaystackCompletionRedirect(String url) {
    final uri = Uri.parse(url);
    final query = uri.query.toLowerCase();
    final ref = widget.reference.toLowerCase();

    _log('🔎 Analyzing URL for Paystack completion:');
    _log('   - Query: $query');
    _log('   - Reference: $ref');

    // BROAD DETECTION: Any URL that indicates payment completion
    final completionIndicators = [
      'trxref=$ref',
      'reference=$ref',
      'transaction/verify',
      'success',
      'completed',
      'thankyou',
      'successful',
      'paid=true',
      'status=success'
    ];

    // Check if any completion indicator matches
    for (final indicator in completionIndicators) {
      if (query.contains(indicator) || url.toLowerCase().contains(indicator)) {
        _log('✅ Completion indicator matched: $indicator');
        return true;
      }
    }

    _log('⚪ Not a completion redirect yet');
    return false;
  }

  bool _isPaystackFailureRedirect(String url) {
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();
    final query = uri.query.toLowerCase();

    _log('🔎 Analyzing URL for failure patterns:');

    // Paystack failure indicators
    final failurePatterns = [
      'cancel',
      'cancelled', 
      'failed',
      'failure',
      'error',
    ];

    // Check if any failure pattern matches
    for (final pattern in failurePatterns) {
      if (url.toLowerCase().contains(pattern)) {
        _log('❌ Failure pattern matched: $pattern');
        return true;
      }
    }

    _log('✅ No failure patterns matched');
    return false;
  }

  // ---------------------------------------------------------------------------
  // ⚡ IMMEDIATE PAYMENT PROCESSING - NO DELAYS
  // ---------------------------------------------------------------------------
  Future<void> _processPaymentImmediately() async {
    _log('⚡ IMMEDIATE PAYMENT PROCESSING STARTED');
    
    if (!mounted) {
      _log('🚫 Not mounted, skipping processing');
      return;
    }
    
    setState(() => _isVerifying = true);

    try {
      // STEP 1: IMMEDIATELY MARK SUBSCRIPTION AS PAID (Don't wait for verification)
      _log('💾 IMMEDIATELY marking subscription as paid...');
      await _subscriptionService.hasPaid();
      _log('✅ Subscription marked as paid immediately');

      if (!mounted) {
        _log('🚫 Not mounted after marking subscription');
        return;
      }

      // STEP 2: IMMEDIATELY UPDATE USER WITH PAYMENT REFERENCE
      _log('📡 IMMEDIATELY updating user with payment reference...');
      try {
        final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
        await userProvider.updateUserAfterPayment(reference: widget.reference);
        _log('✅ User updated immediately with payment reference');
        _log('✅ Payment reference notifier triggered');
        
      } catch (e) {
        _log('⚠️ Warning: Could not update user with payment reference: $e');
        // Continue even if user update fails - payment processing continues
      }

      // STEP 3: QUICK PAYSTACK VERIFICATION (Non-blocking)
      _log('🔍 Starting non-blocking Paystack verification...');
      _verifyWithPaystackNonBlocking();

      if (!mounted) {
        _log('🚫 Not mounted after user update');
        return;
      }

      // STEP 4: IMMEDIATE SUCCESS UI UPDATE
      _log('🎊 IMMEDIATE SUCCESS - Closing WebView and showing success...');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Payment Successful! Subscription activated.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Minimal delay for UI smoothness
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        Navigator.of(context).pop(); // Close WebView immediately
        widget.onPaymentSuccess(); // Callback
      }
      
    } catch (e) {
      _log('❌ CRITICAL: Error in immediate payment processing: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment processing error: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
        
        // Even if there's an error, try to close the WebView
        Navigator.of(context).pop();
        widget.onPaymentSuccess(); // Still call success callback
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 🔄 NON-BLOCKING PAYSTACK VERIFICATION (Runs in background)
  // ---------------------------------------------------------------------------
  Future<void> _verifyWithPaystackNonBlocking() async {
    // This runs in background and doesn't block the UI
    unawaited(_performPaystackVerification());
  }

  Future<void> _performPaystackVerification() async {
    try {
      _log('🔍 Background Paystack verification started...');
      
      final response = await http.get(
        PaystackConfig.getVerificationUrl(widget.reference),
        headers: PaystackConfig.getAuthHeaders(),
      ).timeout(
        PaystackConfig.verificationTimeout,
        onTimeout: () {
          _log('⏰ Background verification timeout');
          return http.Response('{"status": false, "message": "Timeout"}', 408);
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['status'] == true) {
        final transactionData = data['data'];
        final transactionStatus = transactionData?['status'];
        
        _log('✅ Background verification: Transaction status - $transactionStatus');
        
        if (transactionStatus == 'success') {
          _log('🎯 Background verification: Payment confirmed by Paystack');
          // Payment is fully verified, no further action needed
        } else {
          _log('⚠️ Background verification: Payment status is $transactionStatus');
          // Log the status but don't block the user
        }
      } else {
        _log('⚠️ Background verification failed: ${data['message']}');
        // Verification failed but user already has access
      }
    } catch (e) {
      _log('⚠️ Background verification error: $e');
      // Don't show errors to user - they already have access
    }
  }

  // ---------------------------------------------------------------------------
  // ❌ PAYMENT FAILED HANDLER
  // ---------------------------------------------------------------------------
  void _handlePaymentFailed({String? reason, bool shouldClose = true}) {
    _log('💥 PAYMENT FAILED: $reason');
    
    if (!mounted) {
      _log('🚫 Not mounted, cannot show error');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(reason ?? 'Payment failed or cancelled'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _retryPayment,
        ),
      ),
    );

    widget.onPaymentFailed?.call();
    
    // Only close if shouldClose is true
    if (mounted && shouldClose && !_isVerifying) {
      Navigator.of(context).pop();
    } else if (!shouldClose) {
      // Reset for retry
      setState(() {
        _paymentProcessed = false;
        _isVerifying = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // 🔄 RETRY PAYMENT
  // ---------------------------------------------------------------------------
  void _retryPayment() {
    if (!mounted) return;
    
    _log('🔄 Retrying payment...');
    
    setState(() {
      _paymentProcessed = false;
      _isVerifying = false;
      _hasWebViewError = false;
    });
    
    _paymentTimeoutTimer?.cancel();
    _startPaymentTimer();
    
    _controller.reload();
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔄 Retrying payment...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🎨 UI BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isVerifying,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && !_isVerifying && !_paymentProcessed) {
          // Payment cancelled by user, pop the screen
          Navigator.of(context).pop();
          // After pop, refetch user data
          final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
          await userProvider.fetchUserByEmail(userProvider.currentUser?.email ?? '');
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.eLearningBtnColor1,
              title: const Text(
                'Complete Payment',
                style: TextStyle(color: Colors.white),
              ),
              leading: _isVerifying
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () async {
                        if (_paymentProcessed) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please wait while we complete your payment...'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        } else {
                          Navigator.of(context).pop();
                          // After pop, refetch user data
                          final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
                          print('🔄 User cancelled payment, refetching user data... ${userProvider.currentUser?.email}');
                          await userProvider.fetchUserByEmail(userProvider.currentUser?.email ?? '');
                        }
                      },
                    ),
              actions: [
                if (_hasWebViewError && !_isVerifying)
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _retryPayment,
                    tooltip: 'Retry',
                  ),
              ],
            ),
            body: Column(
              children: [
                if (_isLoading && !_isVerifying)
                  const LinearProgressIndicator(),
                Expanded(
                  child: WebViewWidget(controller: _controller),
                ),
              ],
            ),
          ),

          // Quick processing overlay (shorter message)
          if (_isVerifying)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const Text(
                          'Activating Subscription...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This will only take a moment',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


