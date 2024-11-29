import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';


class StudentRecieptDialog extends StatefulWidget {
  @override
  State<StudentRecieptDialog> createState() => _StudentRecieptDialogState();
}

class _StudentRecieptDialogState extends State<StudentRecieptDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: Colors.white, // Ensure icon stands out on blue background
            width: 34.0,
            height: 34.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.paymentTxtColor1, // Set AppBar background to blue
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
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
        color: AppColors.paymentTxtColor1,
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Card(
            color: Colors.white, // Ensure Card has a white background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SvgPicture.asset(
                        'assets/icons/profile/success_receipt_icon.svg',
                        height: 60),
                  ),
                  const SizedBox(height: 16.0),
                  Center(
                    child: Text(
                      'Second Term Fees Receipt',
                      style: AppTextStyles.normal600(
                        fontSize: 20.0,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Center(
                    child: Text(
                      '₦234,790.00',
                      style: AppTextStyles.normal500(
                          fontSize: 14, color: AppColors.primaryLight),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  _buildDetailRow('Date', '2023-10-23'),
                  _buildDetailRow('Name', 'Dennis, Tochi'),
                  _buildDetailRow('Level', 'SS2'),
                  _buildDetailRow('Class', 'SS2 A'),
                  _buildDetailRow('Registration number', 'MCC23546709'),
                  _buildDetailRow('Session', '2022/2023'),
                  _buildDetailRow('Term', 'Second Term Fees'),
                  _buildDetailRow('Reference number', 'vb45lk89yfx43'),
                  const SizedBox(height: 24.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: const Color.fromRGBO(47, 85, 221, 1),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text('Share',
                                style: AppTextStyles.normal500(
                                  fontSize: 18,
                                  color: const Color.fromRGBO(47, 85, 221, 1),
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
                            child: Text('Download',
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
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.normal400(
              fontSize: 16.0,
              color: AppColors.textGray,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.normal600(
              fontSize: 16.0,
              color: AppColors.primaryLight,
            ),
          ),
        ],
      ),
    );
  }
}