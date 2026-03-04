import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/cbt_plan_model.dart';
import 'package:linkschool/modules/providers/cbt_plan_provider.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/explore/cbt/widgets/cbt_plan_payment_dialog.dart';
import 'package:linkschool/modules/services/cbt_license_service.dart';
import 'package:linkschool/modules/services/cbt_subscription_service.dart';
import 'package:provider/provider.dart';

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
  int _remainingDays = 0;
  bool _isLoadingTrial = true;
  bool _isStartingTrial = false;
  bool _forceContinueWithAds = false;
  bool _trialStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    Future.microtask(() {
      if (!mounted) return;
      context.read<CbtPlanProvider>().fetchPlans();
      _loadTrialState();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6F45D8),
      body: SafeArea(
        child: Consumer<CbtPlanProvider>(
          builder: (context, provider, child) {
            final plans = provider.plans;
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
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        left: -80,
                        bottom: 40,
                        child:
                            _buildGlowCircle(160, Colors.white.withOpacity(0.08)),
                      ),
                      Positioned(
                        right: -40,
                        top: 120,
                        child:
                            _buildGlowCircle(120, Colors.white.withOpacity(0.12)),
                      ),
                      if (provider.isLoading)
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      else if (provider.errorMessage != null &&
                          plans.isEmpty)
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
                                        scale = (1 - (page - index).abs() * 0.08)
                                            .clamp(0.92, 1.0);
                                      }
                                      return Transform.scale(
                                        scale: scale,
                                        child: child,
                                      );
                                    },
                                    child: _PlanCard(
                                      plan: plan,
                                      accent: _accentForIndex(index),
                                      icon: _iconForIndex(index),
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
                                  if (widget.showTrialButton)
                                  Expanded(
                                    child: SizedBox(
                                      height: 54,
                                      child: ElevatedButton(
                                        onPressed: _isLoadingTrial ||
                                                _isStartingTrial
                                            ? null
                                            : _startTrial,
                                        style: ElevatedButton.styleFrom(
                                           backgroundColor:
                                              Colors.white,
                                        
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          elevation: 6,
                                          shadowColor:
                                              Colors.black.withOpacity(0.2),
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
                                            : Text(
                                                _trialLabel(),
                                                style:
                                                    AppTextStyles.normal600(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  if (widget.showTrialButton) const SizedBox(width: 12), 
                                  Expanded(
                                    child: SizedBox(
                                      height: 54,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          final selectedPlan = plans.isNotEmpty
                                              ? plans[_currentIndex.clamp(
                                                  0, plans.length - 1)]
                                              : null;
                                          if (selectedPlan == null) {
                                            return;
                                          }
                                          showDialog<bool>(
                                            context: context,
                                            barrierDismissible: true,
                                            builder: (context) =>
                                                CbtPlanPaymentDialog(
                                              plan: selectedPlan,
                                            ),
                                          ).then((didProceed) {
                                            if (didProceed == true && mounted) {
                                              Navigator.of(context).pop(true);
                                            }
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                           backgroundColor:
                                              AppColors.barColor3,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          elevation: 8,
                                          shadowColor:
                                              Colors.black.withOpacity(0.25),
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
            color: isActive
                ? Colors.white
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }

  Future<void> _loadTrialState() async {
    try {
      final remaining = await CbtSubscriptionService().getRemainingFreeTests();
      bool forceContinue = false;
      bool trialStarted = false;
      
      final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
      
      // Check if user has already paid
      final hasPaid = await CbtSubscriptionService().hasPaid();
      
      if (!hasPaid) {
        // Check if trial has been started
        final trialStartDate = await CbtSubscriptionService().getTrialStartDate();
        trialStarted = trialStartDate != null;
        // Once trial has started, keep CTA as "Continue with Ads"
        forceContinue = trialStarted;
      }
      
      if (mounted) {
        setState(() {
          _remainingDays = remaining;
          _isLoadingTrial = false;
          _forceContinueWithAds = forceContinue;
          _trialStarted = trialStarted;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _remainingDays = 0;
          _isLoadingTrial = false;
          _forceContinueWithAds = false;
        });
      }
    }
  }

  String _trialLabel() {
    if (_trialStarted || _forceContinueWithAds) {
      return 'Continue with Ads';
    }
    return 'Start $_remainingDays days Trial';
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

    final isContinueWithAds = _forceContinueWithAds || _remainingDays <= 1;

    setState(() => _isStartingTrial = true);
    try {
      if (isContinueWithAds) {
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
      // Pass the plan's trial duration, not the global subscription service value
      await CbtSubscriptionService().setTrialStartDate(originalDuration: planTrialDays);
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
      if (mounted) {
        Navigator.of(context).pop(true);
      }
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
      if (mounted) {
        setState(() => _isStartingTrial = false);
      }
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
}

class _PlanCard extends StatelessWidget {
  final CbtPlanModel plan;
  final Color accent;
  final IconData icon;

  const _PlanCard({
    required this.plan,
    required this.accent,
    required this.icon,
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
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: accent),
            ),
            const SizedBox(height: 20),
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
                _planSubtitle(plan),
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

  String _planSubtitle(CbtPlanModel plan) {
    if (plan.freeTrialDays > 0) {
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
  Color _accentForIndex(int index) {
    const accents = [
      Color(0xFF7C4DFF),
      Color(0xFF4C6FFF),
      Color(0xFF00BFA6),
      Color(0xFFEC4899),
    ];
    return accents[index % accents.length];
  }

  IconData _iconForIndex(int index) {
    const icons = [
      Icons.local_fire_department,
      Icons.workspace_premium,
      Icons.auto_awesome,
      Icons.stars,
    ];
    return icons[index % icons.length];
  }

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
                color: Colors.white.withOpacity(0.8),
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
