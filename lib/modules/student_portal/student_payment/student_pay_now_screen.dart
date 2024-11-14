import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class StudentPayNowScreen extends StatefulWidget {
  const StudentPayNowScreen({super.key});

  @override
  State<StudentPayNowScreen> createState() => _StudentPayNowScreenState();
}

class _StudentPayNowScreenState extends State<StudentPayNowScreen> {
  late double opacity;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.paymentTxtColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Payment Receipt',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.eLearningBtnColor1,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            Text(
              'Second Term Fee Charges for 2017/2018 Session',
              style: AppTextStyles.normal600(
                fontSize: 16.0,
                color: AppColors.eLearningBtnColor1,
              ),
            ),
            const SizedBox(height: 16.0),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Bus fee', style: AppTextStyles.normal400(fontSize: 12, color: AppColors.backgroundDark)),
                    Text('₦3000', style: AppTextStyles.normal400(fontSize: 12, color: AppColors.backgroundDark)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total amount to pay', style: AppTextStyles.normal600(fontSize: 14, color: AppColors.backgroundDark)),
                Text('₦356,870.00', style: AppTextStyles.normal600(fontSize: 18, color: AppColors.backgroundDark)),
              ],
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Implement payment logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.eLearningBtnColor1,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Proceed to pay',
                      style: AppTextStyles.normal600(
                          fontSize: 16, color: AppColors.backgroundLight)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}