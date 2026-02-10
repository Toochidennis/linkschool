import 'package:flutter/material.dart';
import 'package:linkschool/modules/admin/payment/settings/fee_setting/amount_setting_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';

class AmountSettingSuccessScreen extends StatefulWidget {
  final String levelName;
  final int levelId;
  final double totalAmount;

  const AmountSettingSuccessScreen({
    super.key,
    required this.levelName,
    required this.levelId,
    required this.totalAmount,
  });

  @override
  State<AmountSettingSuccessScreen> createState() =>
      _AmountSettingSuccessScreenState();
}

class _AmountSettingSuccessScreenState extends State<AmountSettingSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _checkAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _checkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _checkAnimationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );

    // Start animations
    _fadeAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _checkAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _checkAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.eLearningBtnColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Success',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.eLearningBtnColor1,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
      ),
      body: Container(
        color: Colors.white,
       // decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Success Icon
              AnimatedBuilder(
                animation: _checkAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _checkAnimation.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            spreadRadius: 5,
                            blurRadius: 15,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Success Message
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Amount Settings Saved Successfully!',
                      style: AppTextStyles.normal600(
                        fontSize: 20,
                        color: AppColors.backgroundDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your fee settings for ${widget.levelName} have been saved.',
                      style: AppTextStyles.normal500(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Total Amount Display
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total Amount: ',
                            style: AppTextStyles.normal500(
                              fontSize: 16,
                              color: AppColors.backgroundDark,
                            ),
                          ),
                          NairaSvgIcon(color: AppColors.backgroundDark),
                          const SizedBox(width: 4),
                          Text(
                            widget.totalAmount.toStringAsFixed(2),
                            style: AppTextStyles.normal600(
                              fontSize: 18,
                              color: AppColors.eLearningBtnColor1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Action Buttons
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AmountSettingScreen(
                                levelName: widget.levelName,
                                levelId: widget.levelId,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.eLearningBtnColor1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Edit Amount Settings',
                          style: AppTextStyles.normal600(
                            fontSize: 16,
                            color: AppColors.backgroundLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context); // Go back to previous screen
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.eLearningBtnColor1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: AppTextStyles.normal600(
                            fontSize: 16,
                            color: AppColors.eLearningBtnColor1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
