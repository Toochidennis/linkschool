import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/student/payment/student_payment_home_screen.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:linkschool/modules/providers/student/payment_submission_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';

class PaystackWebView extends StatefulWidget {
  final String checkoutUrl;
  final String reference;
  final String dbName;
  final String invoiceId;
  final String regNo;
  final String name;
  final int amount;
  final List<Map<String, dynamic>> invoiceDetails;
  final int classId;
  final int levelId;
  final int year;
  final int term;
  final String email;
  final String studentId;

  const PaystackWebView({
    Key? key,
    required this.checkoutUrl,
    required this.reference,
    required this.dbName,
    required this.invoiceId,
    required this.regNo,
    required this.name,
    required this.amount,
    required this.invoiceDetails,
    required this.classId,
    required this.levelId,
    required this.year,
    required this.term,
    required this.email,
    required this.studentId,
  }) : super(key: key);

  @override
  State<PaystackWebView> createState() => _PaystackWebViewState();
}

class _PaystackWebViewState extends State<PaystackWebView> {
  late final WebViewController _controller;
  // debug: track last url if needed
  bool _posted = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (change) {
            if (change.url != null) {
              print('📡 URL changed: ${change.url}');
            }
          },
          onNavigationRequest: (navigation) => NavigationDecision.navigate,
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  Future<void> _postPaymentData() async {
  if (_posted) return;
  _posted = true;

  try {
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    await paymentProvider.initializePayment(
      invoiceId: widget.invoiceId,
      reference: widget.reference,
      regNo: widget.regNo,
      name: widget.name,
      amount: widget.amount.toDouble(),
      invoiceDetails: widget.invoiceDetails,
      classId: widget.classId,
      levelId: widget.levelId,
      year: widget.year,
      term: widget.term,
      email: widget.email,
      studentId: widget.studentId,
    );

    print("✅ Payment data posted before closing Paystack WebView");

    if (!mounted) return;

   Navigator.popUntil(
      context,
      (route) => route.settings.name == StudentPaymentHomeScreen.routeName ||
          route.isFirst, // Fallback to first route if StudentPaymentHomeScreen not found
    );
  } catch (e) {
    print("❌ Error posting payment data: $e");
  }
}


  void _navigateBackToHomeScreen() async {
    await _postPaymentData();
    Navigator.popUntil(
      context,
      (route) => route.settings.name == StudentPaymentHomeScreen.routeName ||
          route.isFirst, // Fallback to first route if StudentPaymentHomeScreen not found
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateBackToHomeScreen();
        return false; // Prevent default pop
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryLight,
          title: const Text('Complete Payment'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _postPaymentData,
          ),
        ),
  body: WebViewWidget(controller: _controller),
      ),
    );
  }
}