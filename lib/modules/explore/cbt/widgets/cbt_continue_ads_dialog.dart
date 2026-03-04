import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class CbtContinueAdsDialog extends StatelessWidget {
  const CbtContinueAdsDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 32,
              spreadRadius: 2,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon Badge ──
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.eLearningBtnColor1.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.eLearningBtnColor1.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.lock_clock_rounded,
                  size: 36,
                  color: AppColors.eLearningBtnColor1,
                ),
              ),
              const SizedBox(height: 16),

              // ── Title ──
              Text(
                'Trial Limit Reached!',
                style: AppTextStyles.normal700(
                  fontSize: 22,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ve used all 10 free questions.\nChoose how to keep going.',
                textAlign: TextAlign.center,
                style: AppTextStyles.normal400(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              // ── Subscribe Button (Primary CTA) ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, 'subscribe'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade500,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Pay Now',
                        style: AppTextStyles.normal600(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── OR Divider ──
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: AppTextStyles.normal500(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Continue with Ads Button (Secondary) ──
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, 'ads'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.eLearningBtnColor1,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppColors.eLearningBtnColor1,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Continue with Ads',
                        style: AppTextStyles.normal600(
                          fontSize: 15,
                          color: AppColors.eLearningBtnColor1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Dismiss link ──
              GestureDetector(
                onTap: () => Navigator.pop(context, 'dismiss'),
                child: Text(
                  'Maybe later',
                  style: AppTextStyles.normal500(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
