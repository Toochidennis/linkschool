import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CourseCheckoutWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String callbackUrl;

  const CourseCheckoutWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.callbackUrl,
  });

  @override
  State<CourseCheckoutWebViewScreen> createState() =>
      _CourseCheckoutWebViewScreenState();
}

class _CourseCheckoutWebViewScreenState
    extends State<CourseCheckoutWebViewScreen> {
  late final WebViewController _controller;
  bool _hasClosed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (change) {
            final url = change.url;
            if (url != null) {
              final result = _resultForUrl(url);
              if (result != null) {
                _close(result);
              }
            }
          },
          onNavigationRequest: (request) {
            final result = _resultForUrl(request.url);
            if (result != null) {
              _close(result);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool? _resultForUrl(String url) {
    final current = url.toLowerCase();
    final callback = widget.callbackUrl.toLowerCase();
    final normalizedCallback = callback.startsWith('http')
        ? callback
        : 'https://$callback';

    if (callback.isNotEmpty &&
        (current.startsWith(callback) ||
            current.startsWith(normalizedCallback) ||
            current.contains(callback))) {
      return true;
    }

    if (current.startsWith('https://standard.paystack.co/close')) {
      return false;
    }

    if (current.contains('cancel') ||
        current.contains('cancelled') ||
        current.contains('canceled') ||
        current.contains('abandoned') ||
        current.contains('abandon') ||
        current.contains('close') ||
        current.contains('closed') ||
        current.contains('exit') ||
        current.contains('failed') ||
        current.contains('failure') ||
        current.contains('error')) {
      return false;
    }

    return null;
  }

  void _close([bool result = false]) {
    if (_hasClosed || !mounted) return;
    _hasClosed = true;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _close(false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete Payment'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _close(false),
          ),
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
