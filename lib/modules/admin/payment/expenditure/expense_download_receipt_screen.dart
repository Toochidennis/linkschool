import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/custom_dash_line.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
// import 'package:linkschool/lib/widgets/naira_svg_icon.dart';

class ExpenseDownloadReceiptScreen extends StatefulWidget {
  final String amount;
  final Map<String, dynamic> transaction;

  const ExpenseDownloadReceiptScreen({
    super.key,
    required this.amount,
    required this.transaction,
  });

  @override
  State<ExpenseDownloadReceiptScreen> createState() => _ExpenseDownloadReceiptScreenState();
}

class _ExpenseDownloadReceiptScreenState extends State<ExpenseDownloadReceiptScreen> {
  late double opacity;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Download Receipt',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.paymentTxtColor1,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        flexibleSpace: Stack(
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            opacity: opacity,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 500,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SvgPicture.asset('assets/icons/profile/rounded_success_icon.svg'),
                        const SizedBox(height: 16.0),
                        Text(
                          'Expenditure',
                          style: AppTextStyles.normal500(
                            fontSize: 20,
                            color: AppColors.backgroundDark,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const NairaSvgIcon(
                              width: 20.0,
                              height: 20.0,
                              color: Color.fromRGBO(47, 85, 221, 1),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.amount,
                              style: AppTextStyles.normal700(
                                fontSize: 26,
                                color: AppColors.paymentTxtColor1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        CustomPaint(
                          size: Size(double.infinity, 1),
                          painter: CustomDashLine(),
                        ),
                        _buildDetailRow('Date', widget.transaction['date'] ?? '2023-10-23'),
                        _buildDetailRow('Name', widget.transaction['name'] ?? 'John Doe'),
                        _buildDetailRow('Phone Number', widget.transaction['phone_number'] ?? '08012345679'),
                        _buildDetailRow('Session', widget.transaction['session'] ?? '2022/2023'),
                        _buildDetailRow('Reference No', widget.transaction['reference'] ?? 'ABC123XYZ'),
                        _buildDetailRow('Description', widget.transaction['description'] ?? 'Clinical medication'),
                        const SizedBox(height: 32.0),
                        ElevatedButton(
                          onPressed: () {
                            // Implement download functionality here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  'Download',
                                  style: AppTextStyles.normal500(
                                    fontSize: 16.0,
                                    color: AppColors.backgroundLight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: AppTextStyles.normal500(fontSize: 16, color: AppColors.backgroundDark)),
        ],
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/custom_dash_line.dart';
// import 'package:linkschool/modules/common/text_styles.dart';

// class ExpenseDownloadReceiptScreen extends StatefulWidget {
//   final String amount;

//   const ExpenseDownloadReceiptScreen({super.key, required this.amount});

//   @override
//   State<ExpenseDownloadReceiptScreen> createState() =>
//       _ExpenseDownloadReceiptScreenState();
// }

// class _ExpenseDownloadReceiptScreenState
//     extends State<ExpenseDownloadReceiptScreen> {
//   late double opacity;

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Download Receipt',
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.paymentTxtColor1,
//           ),
//         ),
//         backgroundColor: AppColors.backgroundLight,
//         flexibleSpace: Stack(
//           children: [
//             Positioned.fill(
//               child: Opacity(
//                 opacity: opacity,
//                 child: Image.asset(
//                   'assets/images/background.png',
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Container(
//         height: MediaQuery.of(context).size.height,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/images/background.png'),
//             fit: BoxFit.cover,
//             opacity: opacity,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(
//                 height: 500,
//                 child: Card(
//                   elevation: 4,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       children: [
//                         SvgPicture.asset(
//                             'assets/icons/profile/rounded_success_icon.svg'),
//                         SizedBox(
//                           height: 16.0,
//                         ),
//                         Text(
//                           'Expenditure',
//                           style: AppTextStyles.normal500(
//                               fontSize: 20, color: AppColors.backgroundDark),
//                         ),
//                         SizedBox(
//                           height: 16.0,
//                         ),
//                         Text(
//                           widget.amount,
//                           style: AppTextStyles.normal700(
//                               fontSize: 26, color: AppColors.paymentTxtColor1),
//                         ),
//                         SizedBox(
//                           height: 16.0,
//                         ),
//                         // const Divider(thickness: 1, color: Colors.grey),
//                         CustomPaint(
//                           size: Size(double.infinity, 1),
//                           painter: CustomDashLine(),
//                         ),
//                         _buildDetailRow('Date', '2023-10-23'),
//                         _buildDetailRow('Name', 'John Doe'),
//                         _buildDetailRow('Phone Number', '08012345679'),
//                         _buildDetailRow('Session', '2022/2023'),
//                         _buildDetailRow('Reference No', 'ABC123XYZ'),
//                         _buildDetailRow('Description', 'Clinical medication'),
//                         const SizedBox(height: 32.0),
//                         ElevatedButton(
//                           onPressed: () {},
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 const Color.fromRGBO(47, 85, 221, 1),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.symmetric(vertical: 12),
//                             child: SizedBox(
//                               width: double.infinity,
//                               child: Center(
//                                 child: Text('Download',
//                                     style: AppTextStyles.normal500(
//                                         fontSize: 16.0,
//                                         color: AppColors.backgroundLight)),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(color: Colors.grey)),
//           Text(value),
//         ],
//       ),
//     );
//   }
// }
