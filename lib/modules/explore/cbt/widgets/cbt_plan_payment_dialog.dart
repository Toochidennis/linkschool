import 'dart:async';
import 'package:flutter/material.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/cbt_plan_model.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/services/cbt_billing_service.dart';
import 'package:linkschool/modules/services/cbt_license_service.dart';
import 'package:linkschool/modules/widgets/network_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
      Future.microtask(() => _recoverPendingPayment());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _voucherController.dispose();
    super.dispose();
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────
  Future<void> _recoverPendingPayment() async {
  final prefs = await SharedPreferences.getInstance();
  final ref = prefs.getString('pending_payment_ref');
  final planId = prefs.getInt('pending_payment_plan_id');
  final userId = prefs.getInt('pending_payment_user_id');

  // Nothing pending
  if (ref == null || planId == null || userId == null) return;

  // ✅ Only recover if it matches the current plan
  if (planId != widget.plan.id) return;

  if (!mounted) return;

  // Show spinner on button immediately
  setState(() {
    _isProcessing = true;
    _statusMessage = 'Checking previous payment...';
  });
final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
final user = userProvider.currentUser;
  // Run full verify from attempt 1
  await _verifyWithRetry(
    reference: ref,
    userId: userId,
    planId: planId,
   firstName: _firstName(user),
    lastName: _lastName(user),
  );
}


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
          const SizedBox(height: 8),
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
          const SizedBox(height: 8),
          Column(
            children: [
              Text(
                ' Contact support.',
                style: AppTextStyles.normal400(
                  fontSize: 13,
                  color: AppColors.text7Light,
                ),
              ),
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
          
            color: Colors.white,
          ),
          label: const Text('Chat us on WhatsApp'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            textStyle: AppTextStyles.normal600(fontSize: 13),
          ),
        ),
      ],
    );
  }
  // ─── RESULT DIALOG ───────────────────────────────────────────────────────

  Future<void> _showResultDialog({
    required bool success,
    required String message,
    String? reference,
  }) async {
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
                decoration: BoxDecoration(
                  color: success
                      ? const Color(0xFFE6F4EA)
                      : const Color(0xFFFFF2F2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  success ? Icons.check_circle : Icons.error_outline,
                  color: success
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFE02424),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                success ? 'Payment Successful!' : 'Payment Failed',
                style: AppTextStyles.normal700(
                  fontSize: 18,
                  color: AppColors.text4Light,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: AppTextStyles.normal400(
                  fontSize: 13,
                  color: AppColors.text7Light,
                ),
                textAlign: TextAlign.center,
              ),
              if (!success && reference != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Ref: $reference',
                          style: AppTextStyles.normal500(
                            fontSize: 12,
                            color: AppColors.text7Light,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          // Clipboard.setData(ClipboardData(text: reference));
                        },
                        child: const Icon(
                          Icons.copy,
                          size: 14,
                          color: AppColors.eLearningBtnColor1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(); // close result dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: success
                        ? const Color(0xFF2E7D32)
                        : AppColors.eLearningBtnColor1,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    success ? 'OK' : 'Try Again',
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
      await _clearPendingPaymentState();

      final amount = (widget.plan.finalPrice is num)
          ? (widget.plan.finalPrice).toInt()
          : int.tryParse(widget.plan.finalPrice.toString()) ?? 0;
      final email = user?.email;

      final init = await CbtBillingService().initializePayment(
        userId: user!.id!,
        planId: widget.plan.id,
        method: 'online',
        platform: 'mobile',
        email: email!,
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

      // await _openPaymentWebView(
      //   paymentUrl: paymentUrl,
      //   reference: reference,
      //   callbackUrl: callbackUrl,
      // );

      if (!mounted) return;

      // Save the latest initialized payment only after the webview closes.
      await _savePendingPaymentState(
        reference: reference,
        userId: user.id!,
        planId: widget.plan.id,
      );

      print('[DEBUG] Checking payment status for reference=$reference');
      // final statusResult = await _verifyPaymentStatusWithRetry(
      //   reference: reference,
      // );

      // if (statusResult.status == BillingVerifyStatus.success) {
      //   await _activateAndFinish(userId: user.id!);
      // } else {
      //   if (mounted) {
      //     setState(() {
      //       _isProcessing = false;
      //       _statusMessage = null;
      //     });
      //     _showResultDialog(
      //       success: false,
      //       message: statusResult.message,
      //       reference: reference,
      //     );
      //   }
      // }
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
            success: false,
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
          success: false,
          message: _cleanError(e.toString()),
        );
      }
    }
  }

  // ─── VERIFY WITH RETRY ───────────────────────────────────────────────────
Future<void> _verifyWithRetry({
  required String reference,
  required int userId,
  required int planId,
  required String firstName,
  required String lastName,
}) async {
  const maxRetries = 5;
  const retryDelay = Duration(seconds: 5);

  print('[DEBUG] _verifyWithRetry starting reference=$reference');

  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    print('[DEBUG] Attempt $attempt/$maxRetries');

    if (mounted) {
      setState(() =>
          _statusMessage = 'Verifying payment..');
    }

    try {
      final result = await CbtBillingService().verifyPayment(
        userId: userId,
        planId: planId,
        method: 'online',
        platform: 'mobile',
        firstName: firstName,
        lastName: lastName,
        voucherCode: '',
        reference: reference,
      );

      print('[DEBUG] Attempt $attempt → status=${result.status} message=${result.message}');

      if (result.status == BillingVerifyStatus.success) {
        await _activateAndFinish(userId: userId);
        return;
      }

      if (result.status == BillingVerifyStatus.failed) {
  final isAbandoned = result.message.toLowerCase().contains('abandoned');
  
  if (isAbandoned && attempt < maxRetries) {
    // Don't stop — keep retrying, payment might still process
    await Future.delayed(retryDelay);
    continue;
  }

  // Genuine failure or last attempt — show dialog
  if (mounted) {
    setState(() {
      _isProcessing = false;
      _statusMessage = null;
    });
    _showResultDialog(
      success: false,
      message: result.message,
      reference: reference,
    );
  }
  return;
}

      // notFoundYet — wait and retry
      if (attempt < maxRetries) {
        await Future.delayed(retryDelay);
      }

    } catch (e) {
      print('[DEBUG] Exception on attempt $attempt: $e');
      if (attempt == maxRetries) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _statusMessage = null;
          });
          // Only show dialog on exception if it looks like a real error
          _showResultDialog(
            success: false,
            message: _cleanError(e.toString()),
            reference: reference,
          );
        }
        return;
      }
      if (attempt < maxRetries) {
        await Future.delayed(retryDelay);
      }
    }
  }

  // All retries exhausted — backend never found a transaction
  // This means user closed webview without actually paying — silent dismiss
  print('[DEBUG] All $maxRetries retries exhausted — no transaction found, dismissing silently');
  if (mounted) {
    setState(() {
      _isProcessing = false;
      _statusMessage = null;
    });
    // ✅ No dialog shown — nothing was charged
  }
}

  // ─── ACTIVATE AND FINISH ─────────────────────────────────────────────────

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
      success: false,
      message:
          'Payment received but license activation failed. Please contact support.',
    );
    return;
  }

  final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
  await userProvider.refreshCurrentUser();

  await _clearPendingPaymentState();

  if (!mounted) return;

  final message = 'Your ${widget.plan.name} plan is now active. Enjoy full access!';
  await _showResultDialog(
    success: true,
    message: message,
  );

  if (!mounted) return;

  Navigator.of(context).pop({
    'success': true,
    'message': message,
  });
}

  // ─── HELPERS ─────────────────────────────────────────────────────────────

  Future<void> _savePendingPaymentState({
    required String reference,
    required int userId,
    required int planId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_payment_ref', reference);
    await prefs.setInt('pending_payment_plan_id', planId);
    await prefs.setInt('pending_payment_user_id', userId);
  }

  Future<void> _clearPendingPaymentState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_payment_ref');
    await prefs.remove('pending_payment_plan_id');
    await prefs.remove('pending_payment_user_id');
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
}
