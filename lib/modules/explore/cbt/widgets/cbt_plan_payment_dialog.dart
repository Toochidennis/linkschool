import 'package:flutter/material.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/cbt_plan_model.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/services/cbt_billing_service.dart';
import 'package:linkschool/modules/services/cbt_license_service.dart';
import 'package:linkschool/modules/widgets/network_dialog.dart';
import 'package:paystack_for_flutter/paystack_for_flutter.dart';
import 'package:provider/provider.dart';

class CbtPlanPaymentDialog extends StatefulWidget {
  final CbtPlanModel plan;

  const CbtPlanPaymentDialog({super.key, required this.plan});

  @override
  State<CbtPlanPaymentDialog> createState() => _CbtPlanPaymentDialogState();
}

class _CbtPlanPaymentDialogState extends State<CbtPlanPaymentDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _voucherController = TextEditingController();
  bool _isProcessing = false;
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

 @override
Widget build(BuildContext context) {
  final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
  
  return Dialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    insetPadding: EdgeInsets.symmetric(
      horizontal: 8, 
      vertical: keyboardHeight > 0 ? 8 : 24,  // Reduce padding when keyboard is open
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

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
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

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(0);
                setState(() {});
              },
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _tabController.index == 0
                      ? AppColors.eLearningBtnColor1
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Pay Online',
                  style: AppTextStyles.normal600(
                    fontSize: 14,
                    color: _tabController.index == 0
                        ? Colors.white
                        : AppColors.text7Light,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(1);
                setState(() {});
              },
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _tabController.index == 1
                      ? AppColors.eLearningBtnColor1
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Voucher',
                  style: AppTextStyles.normal600(
                    fontSize: 14,
                    color: _tabController.index == 1
                        ? Colors.white
                        : AppColors.text7Light,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          Text(
            'Your payment helps keep the CBT content updated and accessible.',
            style: AppTextStyles.normal400(
              fontSize: 12,
              color: AppColors.text8Light,
            ),
            textAlign: TextAlign.center,
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
          Text(
            'Your payment helps keep the CBT content updated and accessible.',
            style: AppTextStyles.normal400(
              fontSize: 12,
              color: AppColors.text8Light,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
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

  String _formatPrice(CbtPlanModel plan) {
    final currency = plan.currency.toUpperCase();
    final prefix = currency == 'NGN' ? '₦' : '$currency ';
    return '$prefix${plan.finalPrice}';
  }

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
    });
    try {
      final amount = (widget.plan.finalPrice is num)
          ? (widget.plan.finalPrice as num).toInt()
          : int.tryParse(widget.plan.finalPrice.toString()) ?? 0;
      final amountInKobo = amount * 100;
     // final reference = 'CBT_${DateTime.now().millisecondsSinceEpoch}';
      final email = user?.email;
      final paystackSecretKey = EnvConfig.paystackSecretKey;

      PaystackFlutter().pay(
        context: context,
        secretKey: paystackSecretKey,
        amount: amountInKobo.toDouble(),
        email: email!,
        callbackUrl: 'https://callback.com',
        showProgressBar: true,
        paymentOptions: [
          PaymentOption.card,
          PaymentOption.bankTransfer,
          PaymentOption.mobileMoney,
          PaymentOption.ussd,
         
        ],
        currency: Currency.NGN,
        metaData: {
          'plan_id': widget.plan.id,
          'plan_name': widget.plan.name,
          'final_price': amount,
        },
        onSuccess: (callback) async {
          print('Payment successful: ${callback.reference}');
          print(
              '[CBT_FLOW] Verifying billing (online) userId=${user?.id} planId=${widget.plan.id}');

          await _verifyBilling(
            userId: user?.id ?? 0,
            planId: widget.plan.id,
            method: 'online',
            platform: 'mobile',
            firstName: _firstName(user),
            lastName: _lastName(user),
            voucherCode: '',
            reference: callback.reference,
          );

         
        },
        onCancelled: (callback) {
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
      if (mounted) {
        setState(() => _errorMessage = _cleanError(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
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
    });
    try {
      print(
          '[CBT_FLOW] Verifying billing (voucher) userId=${user?.id} planId=${widget.plan.id}');
      await _verifyBilling(
        userId: user?.id ?? 0,
        planId: widget.plan.id,
        method: 'voucher',
        platform: 'mobile',
        firstName: _firstName(user),
        lastName: _lastName(user),
        voucherCode: code,
        reference: '',
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _verifyBilling({
    required int userId,
    required int planId,
    required String method,
    required String platform,
    required String firstName,
    required String lastName,
    required String voucherCode,
    required String reference,
  }) async {
    try {
      print(
          '[CBT_FLOW] Billing verify payload: userId=$userId planId=$planId method=$method platform=$platform voucher=${voucherCode.isNotEmpty} reference=${reference.isNotEmpty}');
      await CbtBillingService().verifyPayment(
        userId: userId,
        planId: planId,
        method: method,
        platform: platform,
        firstName: firstName,
        lastName: lastName,
        voucherCode: voucherCode,
        reference: reference,
      );

      final activation =
          await CbtLicenseService().activateLicense(userId: userId);
      print(
          '[CBT_FLOW] Activation status=${activation.status} licenseStatus=${activation.license.status}');
      final activatedNow =
          activation.status.toLowerCase() == 'activated' ||
              activation.license.status.toLowerCase() == 'active';

      var isActive = activatedNow;
      if (!isActive) {
        // Give backend a moment to propagate status.
        for (var i = 0; i < 3; i++) {
          await Future.delayed(const Duration(milliseconds: 700));
          isActive = await CbtLicenseService()
              .isLicenseActive(userId: userId, forceRefresh: true);
          print('[CBT_FLOW] License check retry ${i + 1} active=$isActive');
          if (isActive) break;
        }
      }
      if (!isActive) {
        throw Exception('License not active yet. Please try again.');
      }

      if (!mounted) return;
      final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
      await userProvider.refreshCurrentUser();

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = _cleanError(e.toString()));
      }
    }
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
    final parts = name.split(' ').where((String e) => e.isNotEmpty).toList();
    return parts.length > 1 ? parts.last : '';
  }

  String _cleanError(String error) {
    final trimmed = error.replaceFirst('Exception: ', '').trim();
    final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(trimmed);
    if (match != null) {
      return match.group(1) ?? trimmed;
    }
    return trimmed;
  }
}
