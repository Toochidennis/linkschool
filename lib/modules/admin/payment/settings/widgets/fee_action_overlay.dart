import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class FeeActionOverlay extends StatelessWidget {
  final VoidCallback onSetFeeName;
  final VoidCallback onSetFeeAmount;

  const FeeActionOverlay({
    super.key,
    required this.onSetFeeName,
    required this.onSetFeeAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Fee Settings',
            style: AppTextStyles.normal600(
              fontSize: 18,
              color: AppColors.eLearningBtnColor1,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onSetFeeName();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.eLearningBtnColor1,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Set Fee Name',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: AppColors.backgroundLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onSetFeeAmount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.videoColor4,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Set Fee Amount',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: AppColors.backgroundLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.eLearningRedBtnColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Cancel',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: AppColors.eLearningRedBtnColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
