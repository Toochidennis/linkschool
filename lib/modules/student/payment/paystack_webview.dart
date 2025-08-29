



import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/student/payment/student_payment_home_screen.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:linkschool/modules/providers/student/payment_submission_provider.dart';

class PaystackWebView extends StatefulWidget {
  final String checkoutUrl;
  final String reference;
  final String dbName;

  // Extra fields from your button
  final String invoiceId;
  final String regNo;
  final String name;
  final int amount;
  final List<Map<String, dynamic>> fees;
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
    required this.fees,
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
  String? _currentUrl;
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
              _currentUrl = change.url;
              print('📡 URL changed: ${change.url}');
              print('🔑 Reference: ${widget.reference}');
              print('🗄️ DB Name: ${widget.dbName}');
            }
          },
          onNavigationRequest: (navigation) => NavigationDecision.navigate,
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  Future<void> _postPaymentData() async {
    if (_posted) return; // prevent multiple posts
    _posted = true;

    try {
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

      await paymentProvider.initializePayment(
        invoiceId: widget.invoiceId,
        reference: widget.reference,
        regNo: widget.regNo,
        name: widget.name,
        amount: widget.amount.toDouble(),
        fees: widget.fees,
        classId: widget.classId,
        levelId: widget.levelId,
        year: widget.year,
        term: widget.term,
        email: widget.email,
        studentId: widget.studentId,
      );

      print("✅ Payment data posted before closing Paystack WebView");
    } catch (e) {
      print("❌ Error posting payment data: $e");
    }
  }
Future<bool> _onWillPop() async {
  await _postPaymentData();
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => StudentPaymentHomeScreen(
        logout: () {}, // pass your logout callback here
      ),
    ),
    (route) => false, // removes all previous routes
  );
  return false; // prevent default pop
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
          onPressed: () async {
            await _postPaymentData();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => StudentPaymentHomeScreen(
                  logout: () {}, // pass the same logout callback
                ),
              ),
              (route) => false,
            );
          },
        ),
      ),
        body: WebViewWidget(controller: _controller),
        floatingActionButton: kDebugMode
            ? FloatingActionButton(
                mini: true,
                onPressed: () {
                  print('Current URL: $_currentUrl');
                  print('Reference: ${widget.reference}');
                  print('DB Name: ${widget.dbName}');
                  _controller.reload();
                },
                child: const Icon(Icons.refresh),
              )
            : null,
      ),
    );
  }
}
 