import 'dart:async';

import 'package:flutter/material.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/cbt_plan_model.dart';
import 'package:linkschool/modules/providers/cbt_plan_provider.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/explore/cbt/widgets/cbt_plan_payment_dialog.dart';
import 'package:linkschool/modules/services/cbt_license_service.dart';
import 'package:linkschool/modules/services/cbt_subscription_service.dart';
import 'package:provider/provider.dart';

enum _TrialActionState {
  startTrial,
  continueFreeTrial,
  continueWithAds,
  hidden,
}

class CbtPlansScreen extends StatefulWidget {
  final bool showTrialButton;
  final bool preferTrialLabel;
  const CbtPlansScreen({
    super.key,
    this.showTrialButton = true,
    this.preferTrialLabel = false,
  });

  @override
  State<CbtPlansScreen> createState() => _CbtPlansScreenState();
}

class _CbtPlansScreenState extends State<CbtPlansScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.86);
  int _currentIndex = 0;
  bool _didLoad = false;
  bool _isLoadingTrial = true;
  bool _isStartingTrial = false;
  bool _isOpeningPaymentDialog = false;
  bool _didScheduleAutoClose = false;
  _TrialActionState _trialActionState = _TrialActionState.startTrial;
  int? _remainingTrialDays;
  Timer? _trialCountdownTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    Future.microtask(() {
      if (!mounted) return;
      context.read<CbtPlanProvider>().fetchPlans();
      if (!widget.showTrialButton) {
        setState(() {
          _isLoadingTrial = false;
          _trialActionState = _TrialActionState.hidden;
        });
        return;
      }
      _loadTrialState();
    });
  }

  @override
  void dispose() {
    _trialCountdownTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cbtUserProvider = context.watch<CbtUserProvider>();
    final authProvider = context.watch<AuthProvider>();
    final shouldHidePlansScreen =
        cbtUserProvider.hasPaid || _isPortalSignedIn(authProvider);
    if (shouldHidePlansScreen) {
      _scheduleAutoClose();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF6F45D8),
      body: SafeArea(
        child: Consumer<CbtPlanProvider>(
          builder: (context, provider, child) {
            final plans = provider.plans;
            final showTrialAction = widget.showTrialButton &&
                _trialActionState != _TrialActionState.hidden;
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Choose your plan',
                        style: AppTextStyles.normal600(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!shouldHidePlansScreen) ...[
                  if (_buildTrialStatusText(cbtUserProvider)
                      case final statusText?)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                      child: _buildStatusBanner(
                        text: statusText,
                        isExpired: _isTrialExpired(cbtUserProvider),
                      ),
                    ),
                ],
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        left: -80,
                        bottom: 40,
                        child: _buildGlowCircle(
                            160, Colors.white.withValues(alpha: 0.08)),
                      ),
                      Positioned(
                        right: -40,
                        top: 120,
                        child: _buildGlowCircle(
                            120, Colors.white.withValues(alpha: 0.12)),
                      ),
                      if (provider.isLoading)
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      else if (provider.errorMessage != null && plans.isEmpty)
                        _buildErrorState(provider.errorMessage!)
                      else if (plans.isEmpty)
                        _buildEmptyState()
                      else
                        Column(
                          children: [
                            Expanded(
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: plans.length,
                                onPageChanged: (index) {
                                  setState(() => _currentIndex = index);
                                },
                                itemBuilder: (context, index) {
                                  final plan = plans[index];
                                  return AnimatedBuilder(
                                    animation: _pageController,
                                    builder: (context, child) {
                                      double scale = 1.0;
                                      if (_pageController
                                          .position.haveDimensions) {
                                        final page = _pageController.page ?? 0;
                                        scale =
                                            (1 - (page - index).abs() * 0.08)
                                                .clamp(0.92, 1.0);
                                      }
                                      return Transform.scale(
                                        scale: scale,
                                        child: child,
                                      );
                                    },
                                    child: _PlanCard(
                                      plan: plan,
                                      showTrialOffer: !_hasUsedTrial,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDots(plans.length),
                            const SizedBox(height: 24),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                children: [
                                  if (showTrialAction)
                                    Expanded(
                                      child: SizedBox(
                                        height: 54,
                                        child: ElevatedButton(
                                          onPressed: _isLoadingTrial ||
                                                  _isStartingTrial
                                              ? null
                                              : _startTrial,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            elevation: 6,
                                            shadowColor: Colors.black
                                                .withValues(alpha: 0.2),
                                          ),
                                          child: _isStartingTrial
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : Center(
                                                  child: Text(
                                                    _trialLabel(),
                                                    style:
                                                        AppTextStyles.normal600(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  if (showTrialAction)
                                    const SizedBox(width: 12),
                                  Expanded(
                                    child: SizedBox(
                                      height: 54,
                                      child: ElevatedButton(
                                        onPressed: _isOpeningPaymentDialog
                                            ? null
                                            : () => _openPaymentDialog(plans),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.barColor3,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          elevation: 8,
                                          shadowColor: Colors.black
                                              .withValues(alpha: 0.25),
                                        ),
                                        child: Text(
                                          'Pay Now',
                                          style: AppTextStyles.normal700(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color:
                isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }

  Future<void> _openPaymentDialog(List<CbtPlanModel> plans) async {
    if (_isOpeningPaymentDialog) return;

    final selectedPlan = plans.isNotEmpty
        ? plans[_currentIndex.clamp(0, plans.length - 1)]
        : null;
    if (selectedPlan == null) return;

    _isOpeningPaymentDialog = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;

      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => CbtPlanPaymentDialog(
          plan: selectedPlan,
        ),
      );

      if (!mounted || result != true) {
        return;
      }

      Navigator.of(context).pop(true);
    } finally {
      _isOpeningPaymentDialog = false;
    }
  }

  Future<void> _loadTrialState() async {
    final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
    final initialState = _resolveTrialActionState(
      hasValidLicense: userProvider.hasValidLicense,
      hasPaid: userProvider.hasPaid,
      licenseSource: userProvider.licenseSource,
      licenseReason: userProvider.licenseReason,
    );

    if (mounted) {
      setState(() {
        _isLoadingTrial = false;
        _trialActionState = initialState;
        _remainingTrialDays = _remainingDaysFor(userProvider);
      });
    }
    _syncTrialCountdown(userProvider);

    try {
      final user = userProvider.currentUser;
      if (user?.id != null) {
        await userProvider.syncLicenseStatus(forceRefresh: false);
        final refreshedState = _resolveTrialActionState(
          hasValidLicense: userProvider.hasValidLicense,
          hasPaid: userProvider.hasPaid,
          licenseSource: userProvider.licenseSource,
          licenseReason: userProvider.licenseReason,
        );

        if (mounted) {
          setState(() {
            _trialActionState = refreshedState;
            _remainingTrialDays = _remainingDaysFor(userProvider);
          });
        }
        _syncTrialCountdown(userProvider);
      }
    } catch (_) {
      // Keep the last known local state instead of blocking the plans screen.
    }
  }

  _TrialActionState _resolveTrialActionState({
    required bool hasValidLicense,
    required bool hasPaid,
    required String? licenseSource,
    required String? licenseReason,
  }) {
    if (hasPaid || licenseSource == 'payment') {
      return _TrialActionState.hidden;
    }

    if (hasValidLicense && licenseSource == 'trial') {
      return _TrialActionState.continueFreeTrial;
    }

    if (licenseReason == 'trial_expired' || licenseReason == 'expired') {
      return _TrialActionState.continueWithAds;
    }

    return _TrialActionState.startTrial;
  }

  String _trialLabel() {
    if (_trialActionState == _TrialActionState.continueFreeTrial) {
      return 'Continue with Free Trial';
    }

    if (_trialActionState == _TrialActionState.continueWithAds) {
      return 'Continue with Ads';
    }
    // Use selected plan's freeTrialDays, not global remaining
    final plans = context.read<CbtPlanProvider>().plans;
    final selectedPlan = plans.isNotEmpty
        ? plans[_currentIndex.clamp(0, plans.length - 1)]
        : null;
    final days = selectedPlan?.freeTrialDays ?? 3;
    return 'Start $days days Trial';
  }

  Future<void> _startTrial() async {
    final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    if (user?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to continue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isStartingTrial = true);
    try {
      final userProvider = context.read<CbtUserProvider>();
      if (_trialActionState == _TrialActionState.continueFreeTrial) {
        await CbtSubscriptionService().setAdMode('free_trial');
        if (mounted) {
          Navigator.of(context).pop(true);
        }
        return;
      }

      if (_trialActionState == _TrialActionState.continueWithAds) {
        await CbtSubscriptionService().setAdMode('continue_with_ads');
        if (mounted) {
          Navigator.of(context).pop('continue_ads');
        }
        return;
      }

      // Get the selected plan's trial duration
      final plans = context.read<CbtPlanProvider>().plans;
      final selectedPlan = plans.isNotEmpty
          ? plans[_currentIndex.clamp(0, plans.length - 1)]
          : null;
      final planTrialDays = selectedPlan?.freeTrialDays ?? 3;

      await CbtSubscriptionService().setAdMode('free_trial');
      await CbtLicenseService().startFreeTrial(userId: user!.id!);
      await CbtSubscriptionService()
          .setTrialStartDate(originalDuration: planTrialDays);
      if (!mounted) return;

      final isActive = await CbtLicenseService()
          .isLicenseActive(userId: user.id!, forceRefresh: true);
      if (!mounted) return;

      if (!isActive) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trial not active yet. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await userProvider.syncLicenseStatus(forceRefresh: true);
      await userProvider.syncSubscriptionService();
      _syncTrialCountdown(userProvider);

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_cleanError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isStartingTrial = false);
    }
  }

  String _cleanError(String error) {
    final trimmed = error.replaceFirst('Exception: ', '').trim();
    final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(trimmed);
    if (match != null) {
      return match.group(1) ?? trimmed;
    }
    return trimmed;
  }

  bool _isPortalSignedIn(AuthProvider authProvider) {
    return authProvider.isLoggedIn && !authProvider.isDemoLogin;
  }

  bool get _hasUsedTrial {
    return _trialActionState == _TrialActionState.continueFreeTrial ||
        _trialActionState == _TrialActionState.continueWithAds;
  }

  void _scheduleAutoClose() {
    if (_didScheduleAutoClose) return;
    _didScheduleAutoClose = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !Navigator.of(context).canPop()) return;
      Navigator.of(context).pop(true);
    });
  }

  bool _isTrialExpired(CbtUserProvider userProvider) {
    return userProvider.licenseReason == 'trial_expired' ||
        userProvider.licenseReason == 'expired';
  }

  String? _buildTrialStatusText(CbtUserProvider userProvider) {
    if (userProvider.isOnFreeTrial) {
      final daysLeft = _remainingTrialDays ?? _remainingDaysFor(userProvider);
      if (daysLeft != null) {
        if (daysLeft <= 0) {
          return 'Free trial ends today';
        }
        final dayLabel = daysLeft == 1 ? 'day' : 'days';
        return 'Free trial ends in $daysLeft $dayLabel';
      }
      return 'Free trial is active';
    }

    if (_isTrialExpired(userProvider)) {
      final expiresAt = _parseLicenseDate(userProvider.licenseExpiresAt);
      if (expiresAt != null) {
        return 'Free trial expired on ${_formatDate(expiresAt)}';
      }
      return 'Free trial expired';
    }

    return null;
  }

  void _syncTrialCountdown(CbtUserProvider userProvider) {
    _trialCountdownTimer?.cancel();
    _trialCountdownTimer = null;

    if (!userProvider.isOnFreeTrial || userProvider.licenseExpiresAt == null) {
      return;
    }

    _trialCountdownTimer =
        Timer.periodic(const Duration(minutes: 1), (_) async {
      if (!mounted) return;

      final nextRemainingDays = _remainingDaysFor(userProvider);
      if (nextRemainingDays != _remainingTrialDays) {
        setState(() {
          _remainingTrialDays = nextRemainingDays;
        });
      }

      if (nextRemainingDays == 0) {
        await userProvider.syncLicenseStatus(forceRefresh: true);
        if (!mounted) return;
        setState(() {
          _trialActionState = _resolveTrialActionState(
            hasValidLicense: userProvider.hasValidLicense,
            hasPaid: userProvider.hasPaid,
            licenseSource: userProvider.licenseSource,
            licenseReason: userProvider.licenseReason,
          );
          _remainingTrialDays = _remainingDaysFor(userProvider);
        });
        _syncTrialCountdown(userProvider);
      }
    });
  }

  int? _remainingDaysFor(CbtUserProvider userProvider) {
    final expiry = _parseLicenseDate(userProvider.licenseExpiresAt);
    if (expiry == null) return null;
    final difference = expiry.difference(DateTime.now());
    if (difference.isNegative) return 0;
    return difference.inHours <= 24 ? 1 : (difference.inHours / 24).ceil();
  }

  DateTime? _parseLicenseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    final normalized =
        value.contains(' ') ? value.replaceFirst(' ', 'T') : value;
    return DateTime.tryParse(normalized);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildStatusBanner({
    required String text,
    required bool isExpired,
  }) {
    final backgroundColor =
        isExpired ? const Color(0x33FFB4B4) : const Color(0x1FFFFFFF);
    final borderColor = isExpired
        ? const Color(0x66FFB4B4)
        : Colors.white.withValues(alpha: 0.18);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: AppTextStyles.normal600(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final CbtPlanModel plan;
  final bool showTrialOffer;

  const _PlanCard({
    required this.plan,
    required this.showTrialOffer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatPrice(plan),
              style: AppTextStyles.normal700(
                fontSize: 35,
                color: AppColors.text4Light,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plan.name,
              style: AppTextStyles.normal600(
                fontSize: 20,
                color: AppColors.text4Light,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _planSubtitle(plan, showTrialOffer),
                textAlign: TextAlign.center,
                style: AppTextStyles.normal400(
                  fontSize: 18,
                  color: AppColors.text7Light,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildFeaturesList(plan.features),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(CbtPlanModel plan) {
    final currency = plan.currency.toUpperCase();
    final prefix = currency == 'NGN' ? '₦' : '$currency ';
    final price = plan.finalPrice.toString();
    return '$prefix$price';
  }

  String _planSubtitle(CbtPlanModel plan, bool showTrialOffer) {
    if (showTrialOffer && plan.freeTrialDays > 0) {
      return 'Includes ${plan.freeTrialDays}  days free trial.';
    }
    if (plan.discountPercent > 0.0) {
      return '${plan.discountPercent}% discount applied.';
    }
    return 'Unlock full CBT access and progress insights.';
  }

  Widget _buildFeaturesList(List<String> features) {
    if (features.isEmpty) {
      return const SizedBox.shrink();
    }
    final labels = features.map(_formatFeatureLabel).toList();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: labels.map((feature) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: AppColors.attCheckColor2,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    feature,
                    style: AppTextStyles.normal500(
                      fontSize: 18,
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

  String _formatFeatureLabel(String raw) {
    final cleaned = raw.replaceAll('_', ' ').trim();
    if (cleaned.isEmpty) {
      return '';
    }
    final words = cleaned.split(RegExp(r'\s+'));
    final formatted = words.map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).toList();
    return formatted.join(' ');
  }
}

extension on _CbtPlansScreenState {
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            Text(
              'Unable to load plans.',
              style: AppTextStyles.normal600(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.normal400(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No plans available right now.',
        style: AppTextStyles.normal600(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
