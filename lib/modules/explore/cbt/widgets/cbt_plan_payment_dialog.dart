import 'dart:async';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/cbt_plan_model.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/services/cbt_billing_service.dart';
import 'package:linkschool/modules/services/cbt_license_service.dart';
import 'package:linkschool/modules/widgets/network_dialog.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

enum PaymentDialogState { success, pending, failed }

class CbtPlanPaymentDialog extends StatefulWidget {
  final CbtPlanModel plan;

  const CbtPlanPaymentDialog({super.key, required this.plan});

  @override
  State<CbtPlanPaymentDialog> createState() => _CbtPlanPaymentDialogState();
}

class _CbtPlanPaymentDialogState extends State<CbtPlanPaymentDialog>
    with SingleTickerProviderStateMixin {
  static final Uri _whatsappHelpUri = Uri.parse(
    'https://wa.me/2349047697293',
  );

  late TabController _tabController;
  final TextEditingController _voucherController = TextEditingController();
  bool _isProcessing = false;
  String? _statusMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _voucherController.dispose();
    super.dispose();
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: keyboardHeight > 0 ? 8 : 24,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              _buildTabSwitcher(),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _tabController.index == 0
                    ? _buildPayOnlineTab()
                    : _buildVoucherTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFF2F4F7),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.credit_card, color: Color(0xFF0D1426)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: AppTextStyles.normal500(
                fontSize: 12,
                color: AppColors.text7Light,
              ),
            ),
            Text(
              _tabController.index == 0 ? 'Pay Online' : 'Voucher',
              style: AppTextStyles.normal700(
                fontSize: 20,
                color: AppColors.text4Light,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── TAB SWITCHER ────────────────────────────────────────────────────────

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTab(label: 'Pay Online', index: 0),
          _buildTab(label: 'Voucher', index: 1),
        ],
      ),
    );
  }

  Widget _buildTab({required String label, required int index}) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() {});
        },
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.eLearningBtnColor1
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            style: AppTextStyles.normal600(
              fontSize: 14,
              color: isSelected ? Colors.white : AppColors.text7Light,
            ),
          ),
        ),
      ),
    );
  }

  // ─── TABS ────────────────────────────────────────────────────────────────

  Widget _buildPayOnlineTab() {
    return _buildContent(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorMessage != null) ...[
            _buildErrorBanner(_errorMessage!),
            const SizedBox(height: 12),
          ],
          Text(
            'Complete payment securely online.',
            style: AppTextStyles.normal400(
              fontSize: 13,
              color: AppColors.text7Light,
            ),
          ),
          const SizedBox(height: 14),
          _buildSelectedPlan(),
          const SizedBox(height: 16),
          _buildPrimaryButton(
            label: 'Pay Now',
            onPressed: _isProcessing ? null : _handlePayOnline,
          ),
          const SizedBox(height: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
             
              _buildFootnote(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherTab() {
    return _buildContent(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorMessage != null) ...[
            _buildErrorBanner(_errorMessage!),
            const SizedBox(height: 12),
          ],
          Text(
            'Enter your voucher code to unlock your selected plan.',
            style: AppTextStyles.normal400(
              fontSize: 13,
              color: AppColors.text7Light,
            ),
          ),
          const SizedBox(height: 14),
          _buildVoucherField(),
          const SizedBox(height: 14),
          _buildSelectedPlan(),
          const SizedBox(height: 16),
          _buildPrimaryButton(
            label: 'Verify Voucher',
            onPressed: _isProcessing ? null : _handleVoucherVerify,
          ),
          const SizedBox(height: 16),
          Column(
            children: [
            
              _buildFootnote(),
            ],
          ),
        ],
      ),
    );
  }

  // ─── WIDGETS ─────────────────────────────────────────────────────────────

  Widget _buildContent({required Widget body}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: body,
    );
  }

  Widget _buildSelectedPlan() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Selected Plan',
              style: AppTextStyles.normal400(
                fontSize: 12,
                color: AppColors.text7Light,
              ),
            ),
          ),
          Text(
            '${widget.plan.name} • ${_formatPrice(widget.plan)}',
            style: AppTextStyles.normal600(
              fontSize: 13,
              color: AppColors.text4Light,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherField() {
    return TextField(
      controller: _voucherController,
      textCapitalization: TextCapitalization.characters,
      style: AppTextStyles.normal600(
        fontSize: 14,
        color: AppColors.text4Light,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Voucher code',
        hintStyle: AppTextStyles.normal400(
          fontSize: 13,
          color: AppColors.text8Light,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.eLearningBtnColor1,
            width: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.eLearningBtnColor1,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          elevation: 4,
        ),
        child: _isProcessing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _statusMessage ?? label,
                      style: AppTextStyles.normal600(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Text(
                label,
                style: AppTextStyles.normal600(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFC7C7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFE02424), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.normal500(
                fontSize: 12,
                color: const Color(0xFFE02424),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFootnote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Need help?',
          style: AppTextStyles.normal400(
            fontSize: 13,
            color: AppColors.text4Light,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _openWhatsAppHelp,
          icon: Image.asset(
            'assets/images/whatsapp-logo.png',
            width: 20,
            height: 20,
          
          
          ),
          label: const Text('Chat us on WhatsApp'),
          style: ElevatedButton.styleFrom(
             backgroundColor: Colors.white,
            
            elevation: 0,
            
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color:  Color(0xFF25D366), width: 1.5),
              borderRadius: BorderRadius.circular(999),
            ),
            textStyle: AppTextStyles.normal600(fontSize: 13, color: Colors.black),
          ),
        ),
      ],
    );
  }
  // ─── RESULT DIALOG ───────────────────────────────────────────────────────

  Future<void> _showResultDialog({
    required PaymentDialogState state,
    required String message,
  }) async {
    final isSuccess = state == PaymentDialogState.success;
    final isPending = state == PaymentDialogState.pending;
    final displayMessage = _resultMessageForState(
      state: state,
      backendMessage: message,
    );
    final title = switch (state) {
      PaymentDialogState.success => 'Payment Successful!',
      PaymentDialogState.pending => 'Payment Pending',
      PaymentDialogState.failed => 'Payment Failed',
    };
    final buttonLabel = isSuccess ? 'OK' : 'Close';
    final backgroundColor = isSuccess
        ? const Color(0xFFE6F4EA)
        : isPending
            ? const Color(0xFFFFF8E6)
            : const Color(0xFFFFF2F2);
    final iconColor = isSuccess
        ? const Color(0xFF2E7D32)
        : isPending
            ? const Color(0xFFB26A00)
            : const Color(0xFFE02424);
    final buttonColor = isSuccess
        ? const Color(0xFF2E7D32)
        : isPending
            ? const Color(0xFFF4A000)
            : AppColors.eLearningBtnColor1;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
                child: Icon(
                  isSuccess ? Icons.check_circle : (isPending ? Icons.hourglass_bottom : Icons.error_outline),
                  color: iconColor,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTextStyles.normal700(
                  fontSize: 18,
                  color: AppColors.text4Light,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                displayMessage,
                style: AppTextStyles.normal400(
                  fontSize: 13,
                  color: AppColors.text7Light,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(); // close result dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    buttonLabel,
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
      ),
    );
  }

  // ─── HANDLERS ────────────────────────────────────────────────────────────

  Future<void> _handlePayOnline() async {
    final canUseNetwork = await NetworkDialog.ensureOnline(
      context,
      message: 'Please connect to the internet to continue payment.',
    );
    if (!canUseNetwork || !mounted) return;

    final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    if (user?.id == null) {
      setState(() => _errorMessage = 'Please sign in to continue.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {

      final email = user?.email;
      if (email == null || email.trim().isEmpty) {
        throw Exception('User email is required to initialize payment.');
      }

      final init = await CbtBillingService().initializePayment(
        userId: user!.id!,
        planId: widget.plan.id,
        method: 'online',
        platform: 'mobile',
        email: email.trim(),
        firstName: _firstName(user),
        lastName: _lastName(user),
        voucherCode: '',
      );

      if (!init.success || init.reference.isEmpty) {
        throw Exception(init.message);
      }

      final reference = init.reference;
      final paymentUrl = init.paymentUrl;
      final callbackUrl =
          init.callbackUrl.isNotEmpty ? init.callbackUrl : 'https://callback.com';
      print('[DEBUG] Initialized reference=$reference callbackUrl=$callbackUrl paymentUrl=$paymentUrl');

      if (paymentUrl.isEmpty) {
        throw Exception('Payment URL missing from initialization response.');
      }

      await _openPaymentWebView(
        paymentUrl: paymentUrl,
        reference: reference,
        callbackUrl: callbackUrl,
      );

      if (!mounted) return;

      print('[DEBUG] Checking payment status for reference=$reference');
      final statusResult = await _verifyPaymentStatus(
        reference: reference,
      );

      if (statusResult.status == BillingVerifyStatus.success) {
        await _activateAndFinish(userId: user.id!);
      } else {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _statusMessage = null;
          });
          _showResultDialog(
            state: statusResult.status == BillingVerifyStatus.pending
                ? PaymentDialogState.pending
                : PaymentDialogState.failed,
            message: statusResult.message,
          );
        }
      }
    } catch (e) {
      print('[DEBUG] _handlePayOnline error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = _cleanError(e.toString());
          _isProcessing = false;
          _statusMessage = null;
        });
      }
    }
  }

  Future<void> _handleVoucherVerify() async {
    final canUseNetwork = await NetworkDialog.ensureOnline(
      context,
      message: 'Please connect to the internet to verify your voucher.',
    );
    if (!canUseNetwork || !mounted) return;

    final code = _voucherController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter a voucher code');
      return;
    }

    final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    if (user?.id == null) {
      setState(() => _errorMessage = 'Please sign in to continue.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      print('[CBT_FLOW] Voucher verify userId=${user?.id} planId=${widget.plan.id}');

      final result = await CbtBillingService().verifyPayment(
        userId: user?.id ?? 0,
        planId: widget.plan.id,
        method: 'voucher',
        platform: 'mobile',
        firstName: _firstName(user),
        lastName: _lastName(user),
        voucherCode: code,
        reference: '',
      );

      print('[DEBUG] Voucher result=${result.status} message=${result.message}');

      if (result.status == BillingVerifyStatus.success) {
        await _activateAndFinish(userId: user?.id ?? 0);
      } else {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _statusMessage = null;
          });
          _showResultDialog(
            state: result.status == BillingVerifyStatus.pending
                ? PaymentDialogState.pending
                : PaymentDialogState.failed,
            message: result.message,
          );
        }
      }
    } catch (e) {
      print('[DEBUG] _handleVoucherVerify error: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
        _showResultDialog(
          state: PaymentDialogState.failed,
          message: _cleanError(e.toString()),
        );
      }
    }
  }

  // ─── VERIFY WITH RETRY ───────────────────────────────────────────────────
  Future<void> _openPaymentWebView({
    required String paymentUrl,
    required String reference,
    required String callbackUrl,
  }) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => _CbtPaymentWebViewScreen(
          paymentUrl: paymentUrl,
          reference: reference,
          callbackUrl: callbackUrl,
        ),
      ),
    );
  }

  Future<BillingVerifyResult> _verifyPaymentStatus({
    required String reference,
  }) async {
    if (mounted) {
      setState(() => _statusMessage = 'Checking payment status...');
    }

    return CbtBillingService().checkPaymentStatus(
      reference: reference,
    );
  }

  // ACTIVATE AND FINISH ─────────────────────────────────────────────────

Future<void> _activateAndFinish({required int userId}) async {
  print('[DEBUG] _activateAndFinish userId=$userId');

  if (mounted) setState(() => _statusMessage = 'Activating license...');

  final activation =
      await CbtLicenseService().activateLicense(userId: userId);
  print('[DEBUG] Activation status=${activation.status} license=${activation.license.status}');

  var isActive = activation.status.toLowerCase() == 'activated' ||
      activation.license.status.toLowerCase() == 'active';

  if (!isActive) {
    for (var i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      isActive = await CbtLicenseService()
          .isLicenseActive(userId: userId, forceRefresh: true);
      print('[DEBUG] License poll ${i + 1} isActive=$isActive');
      if (isActive) break;
    }
  }

  if (!mounted) return;

  setState(() {
    _isProcessing = false;
    _statusMessage = null;
  });

  if (!isActive) {
    _showResultDialog(
      state: PaymentDialogState.failed,
      message:
          'Payment received but license activation failed. Please contact support.',
    );
    return;
  }

  final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
  await userProvider.refreshCurrentUser();

  if (!mounted) return;

  final message = 'Your ${widget.plan.name} plan is now active. Enjoy full access!';
  await _showResultDialog(
    state: PaymentDialogState.success,
    message: message,
  );

  if (!mounted) return;

  Navigator.of(context).pop({
    'success': true,
    'message': message,
  });
}

  String _formatPrice(CbtPlanModel plan) {
    final currency = plan.currency.toUpperCase();
    final prefix = currency == 'NGN' ? '₦' : '$currency ';
    return '$prefix${plan.finalPrice}';
  }

  String _firstName(dynamic user) {
    final first = user.first_name?.toString().trim();
    if (first != null && first.isNotEmpty) return first;
    final name = (user.name ?? '').toString().trim();
    return name
        .split(' ')
        .firstWhere((String e) => e.isNotEmpty, orElse: () => 'User');
  }

  String _lastName(dynamic user) {
    final last = user.last_name?.toString().trim();
    if (last != null && last.isNotEmpty) return last;
    final name = (user.name ?? '').toString().trim();
    final parts =
        name.split(' ').where((String e) => e.isNotEmpty).toList();
    return parts.length > 1 ? parts.last : '';
  }

  String _cleanError(String error) {
    final trimmed = error.replaceFirst('Exception: ', '').trim();
    final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(trimmed);
    if (match != null) return match.group(1) ?? trimmed;
    return trimmed;
  }

  Future<void> _openWhatsAppHelp() async {
    final uri = _whatsappHelpUri;
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _resultMessageForState({
    required PaymentDialogState state,
    required String backendMessage,
  }) {
    final message = backendMessage.trim();

    switch (state) {
      case PaymentDialogState.success:
        return message.isNotEmpty
            ? message
            : 'Your ${widget.plan.name} plan is now active. Enjoy full access!';
      case PaymentDialogState.pending:
        return 'Your payment is still being processed. Please check back shortly.';
      case PaymentDialogState.failed:
        return 'Payment could not be confirmed. Please contact support.';
    }
  }
}

class _CbtPaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String reference;
  final String callbackUrl;

  const _CbtPaymentWebViewScreen({
    required this.paymentUrl,
    required this.reference,
    required this.callbackUrl,
  });

  @override
  State<_CbtPaymentWebViewScreen> createState() =>
      _CbtPaymentWebViewScreenState();
}

class _CbtPaymentWebViewScreenState extends State<_CbtPaymentWebViewScreen> {
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
            if (url != null && _shouldCloseForUrl(url)) {
              _close();
            }
          },
          onNavigationRequest: (request) {
            if (_shouldCloseForUrl(request.url)) {
              _close();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool _shouldCloseForUrl(String url) {
    final current = url.toLowerCase();
    final callback = widget.callbackUrl.toLowerCase();
    final reference = widget.reference.toLowerCase();

    if (callback.isNotEmpty && current.startsWith(callback)) {
      return true;
    }

    if (current.startsWith('https://standard.paystack.co/close')) {
      return true;
    }

    return current.contains('success') ||
        current.contains('completed') ||
        current.contains('cancel') ||
        current.contains('cancelled') ||
        current.contains('canceled') ||
        current.contains('abandoned') ||
        current.contains('abandon') ||
        current.contains('close') ||
        current.contains('closed') ||
        current.contains('exit') ||
        current.contains('failed') ||
        current.contains('failure') ||
        current.contains('error') ||
        current.contains('paid=true') ||
        current.contains(reference);
  }

  void _close() {
    if (_hasClosed || !mounted) return;
    _hasClosed = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _close();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.eLearningBtnColor1,
          title: const Text(
            'Complete Payment',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _close,
          ),
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}






