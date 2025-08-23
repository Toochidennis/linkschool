import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/providers/student/payment_submission_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';

class PaystackWebView extends StatefulWidget {
  final String checkoutUrl;
  final String reference;
  final String dbName;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentFailure;
  final VoidCallback? onPaymentCancelled;

  const PaystackWebView({
    Key? key,
    required this.checkoutUrl,
    required this.reference,
    required this.dbName,
    this.onPaymentSuccess,
    this.onPaymentFailure,
    this.onPaymentCancelled,
  }) : super(key: key);

  @override
  State<PaystackWebView> createState() => _PaystackWebViewState();
}

class _PaystackWebViewState extends State<PaystackWebView> {
  late final WebViewController _controller;
  bool _paymentHandled = false;
  bool _isLoading = true;
  bool _isVerifying = false;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onUrlChange: (change) {
            if (change.url != null) {
              print('📡 URL changed: ${change.url}');
              _currentUrl = change.url;
              _handleUrlChange(change.url!);
            }
          },
          onNavigationRequest: (navigation) {
            // Allow all navigation requests
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

void _handleUrlChange(String url) {
  if (_paymentHandled) return;

  final uri = Uri.parse(url);
  final status = uri.queryParameters['status'];
  final reference = uri.queryParameters['reference'] ?? uri.queryParameters['trxref'] ?? widget.reference;

  // Updated Paystack URL patterns for detection
  final isSuccessUrl = url.contains('callback') || 
                      url.contains('paystack.com/close') ||
                      url.contains('status=success') ||
                      url.contains('transaction/success') ||
                      url.contains('/success') ||
                      (status != null && status.toLowerCase() == 'success');

  final isFailureUrl = url.contains('status=failed') ||
                      url.contains('transaction/failure') ||
                      url.contains('/failed') ||
                      (status != null && status.toLowerCase() == 'failed');

  final isCancelledUrl = url.contains('cancelled') ||
                        url.contains('cancel') ||
                        url.contains('close');

  if (isSuccessUrl || isFailureUrl || isCancelledUrl) {
    _paymentHandled = true;

    String message = '';
    Icon icon;

    if (isSuccessUrl) {
      message = 'Payment was successful!';
      icon = const Icon(Icons.check_circle, color: Colors.green, size: 64);
    } else if (isFailureUrl) {
      message = 'Payment failed. Please try again.';
      icon = const Icon(Icons.error, color: Colors.red, size: 64);
    } else {
      message = 'Payment process was cancelled or interrupted.';
      icon = const Icon(Icons.warning, color: Colors.orange, size: 64);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: icon,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text('Reference: $reference', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

  void _showPaymentResult({
    required bool success,
    required String message,
    required String reference,
    bool isCancelled = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Icon(
          success ? Icons.check_circle : 
                  isCancelled ? Icons.warning : Icons.error,
          color: success ? Colors.green : 
                 isCancelled ? Colors.orange : Colors.red,
          size: 64,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Reference: $reference',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close webview
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_paymentHandled) {
      // Show confirmation if user tries to close without completing payment
      final shouldClose = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancel Payment?'),
          content: const Text('Are you sure you want to cancel this payment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Continue Payment'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancel Payment'),
            ),
          ],
        ),
      ) ?? false;

      if (shouldClose) {
        widget.onPaymentCancelled?.call();
      }

      return shouldClose;
    }
    return true;
  }

  Widget _buildLoadingOverlay() {
    if (_isVerifying) {
      return Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Verifying payment...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete Payment'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _onWillPop().then((shouldPop) {
              if (shouldPop) {
                Navigator.pop(context);
              }
            }),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            _buildLoadingOverlay(),
          ],
        ),
        // Add a refresh button for debugging
        floatingActionButton: kDebugMode ? FloatingActionButton(
          mini: true,
          onPressed: () {
            print('Current URL: $_currentUrl');
            print('Reference: ${widget.reference}');
            _controller.reload();
          },
          child: const Icon(Icons.refresh),
        ) : null,
      ),
    );
  }
}