import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/utils/registration/registration_utils.dart';
import 'package:linkschool/modules/portal/result/class_detail/registration/bulk_registration.dart';



class ButtonSection extends StatelessWidget {
  const ButtonSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomLongElevatedButton(
            text: 'Register Student',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BulkRegistrationScreen())),
            backgroundColor: AppColors.videoColor4,
            textStyle: AppTextStyles.normal600(
                fontSize: 16, color: AppColors.backgroundLight),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.regBtnColor2,
                    side: const BorderSide(color: AppColors.videoColor4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    '+ Copy registration',
                    style: AppTextStyles.normal600(
                        fontSize: 12, color: AppColors.videoColor4),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.regBtnColor2,
                    side: const BorderSide(color: AppColors.videoColor4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text('+ Bulk registration',
                      style: AppTextStyles.normal600(
                          fontSize: 12, color: AppColors.videoColor4)),
                  onPressed: () => showRegistrationDialog(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
