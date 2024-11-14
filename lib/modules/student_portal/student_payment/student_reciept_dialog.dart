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
            color: AppColors.paymentTxtColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Payment Receipt',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
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
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
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
                      backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
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



// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';

// class StudentRecieptDialog extends StatefulWidget {
//   // final VoidCallback logout;
//   const StudentRecieptDialog({super.key, });

//   @override
//   State<StudentRecieptDialog> createState() => _StudentRecieptDialogState();
// }

// class _StudentRecieptDialogState extends State<StudentRecieptDialog> {
//   late double opacity;


//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'Payment Receipt',
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.eLearningBtnColor1,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: AppColors.backgroundLight,
//         flexibleSpace: FlexibleSpaceBar(
//           background: Stack(
//             children: [
//               Positioned.fill(
//                 child: Opacity(
//                   opacity: opacity,
//                   child: Image.asset(
//                     'assets/images/background.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//       body: Container(
//         decoration: Constants.customBoxDecoration(context),
//       ),
//     );
//   }
// }