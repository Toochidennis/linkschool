import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';

class StudentViewDetailPaymentDialog extends StatefulWidget {
  const StudentViewDetailPaymentDialog({super.key});

  @override
  State<StudentViewDetailPaymentDialog> createState() =>
      _StudentViewDetailPaymentDialogState();
}

class _StudentViewDetailPaymentDialogState
    extends State<StudentViewDetailPaymentDialog> {
  late double opacity;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _confirmEmailController.dispose();
    super.dispose();
  }

  void _showIdentityConfirmation() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Confirm Identity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add email address'),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your email',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Confirm email address'),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmEmailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Confirm your email',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.eLearningRedBtnColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text('Cancel',
                                style: AppTextStyles.normal500(
                                  fontSize: 18,
                                  color: AppColors.eLearningRedBtnColor,
                                )),
                          ),
                        ),
                      ),
                const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(47, 85, 221, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text('Proceed',
                                style: AppTextStyles.normal500(
                                    fontSize: 16.0,
                                    color: AppColors.backgroundLight)),
                          ),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
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
        height: MediaQuery.of(context).size.height, 
        decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        'assets/icons/profile/success_receipt_icon.svg',
                        height: 60,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Second Term Fee Charges for 2017/2018 Session',
                      style: AppTextStyles.normal600(
                        fontSize: 16.0,
                        color: AppColors.eLearningBtnColor1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24.0),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 12,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Library fee', // Changed label from "Bus fee"
                              style: AppTextStyles.normal400(
                                fontSize: 12,
                                color: AppColors.backgroundDark,
                              ),
                            ),
                            Row(
                              children: [
                                const NairaSvgIcon(color: AppColors.backgroundDark),
                                const SizedBox(width: 4),
                                Text(
                                  '3000',
                                  style: AppTextStyles.normal400(
                                    fontSize: 12,
                                    color: AppColors.backgroundDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total amount to pay',
                          style: AppTextStyles.normal600(
                            fontSize: 14,
                            color: AppColors.backgroundDark,
                          ),
                        ),
                        Row(
                          children: [
                            const NairaSvgIcon(color: AppColors.backgroundDark),
                            const SizedBox(width: 4),
                            Text(
                              '356,870.00',
                              style: AppTextStyles.normal600(
                                fontSize: 18,
                                color: AppColors.backgroundDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _showIdentityConfirmation,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.eLearningBtnColor1,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Proceed to pay',
            style: AppTextStyles.normal600(
              fontSize: 16,
              color: AppColors.backgroundLight,
            ),
          ),
        ),
      ),
    );
  }
}
