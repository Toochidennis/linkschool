// Updated vendor_transaction_receipts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
import 'package:linkschool/modules/model/admin/vendor/vendor_transaction_year.dart';
import 'package:linkschool/modules/model/profile/vendor_transaction_model.dart';


class VendorTransactionReceiptsScreen extends StatefulWidget {
  final VendorTransactionDetail detail;
  final VendorTransaction? transaction;

  const VendorTransactionReceiptsScreen({super.key, required this.detail, this.transaction});

  @override
  State<VendorTransactionReceiptsScreen> createState() => _VendorTransactionReceiptsScreenState();
}

class _VendorTransactionReceiptsScreenState extends State<VendorTransactionReceiptsScreen> {
  late double opacity;

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.normal600(fontSize: 16, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.normal400(fontSize: 16, color: AppColors.backgroundDark),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    final displayYear = '${widget.detail.year - 1}/${widget.detail.year}';
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
          'Transaction Receipt',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.paymentTxtColor1,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
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
              )
            ],
          ),
        ),
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Receipt Header Section - Similar to profile in vendor_transaction_screen
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 25),
                      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.detail.description,
                            style: AppTextStyles.normal600(
                              fontSize: 18,
                              color: AppColors.paymentTxtColor1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const NairaSvgIcon(color: Colors.red),
                              Text(
                                widget.detail.amount.toStringAsFixed(2),
                                style: AppTextStyles.normal600(
                                  fontSize: 18,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            displayYear,
                            style: AppTextStyles.normal500(
                              fontSize: 14,
                              color: AppColors.backgroundDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.paymentTxtColor1,
                      child: SvgPicture.asset(
                        'assets/icons/profile/payment_icon.svg',
                        color: Colors.white,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Details Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Date:', widget.detail.date),
                      const Divider(),
                      _buildDetailRow('Customer Name:', widget.detail.customerName),
                      const Divider(),
                      _buildDetailRow('Customer Reference:', widget.detail.customerReference),
                      const Divider(),
                      _buildDetailRow('Account Name:', widget.detail.accountName),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/model/profile/vendor_transaction_model.dart';

// class VendorTransactionDetailsScreen extends StatefulWidget {
//   final VendorTransaction transaction;

//   const VendorTransactionDetailsScreen({
//     Key? key,
//     required this.transaction,
//   }) : super(key: key);

//   @override
//   State<VendorTransactionDetailsScreen> createState() => _VendorTransactionDetailsScreenState();
// }

// class _VendorTransactionDetailsScreenState extends State<VendorTransactionDetailsScreen> {
//   Widget _detailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label, 
//             style: const TextStyle(
//               color: Colors.grey,
//               fontSize: 16,
//             )
//           ),
//           Text(
//             value, 
//             style: const TextStyle(
//               fontWeight: FontWeight.w500,
//               fontSize: 16,
//             )
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () => Navigator.of(context).pop(),
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.primaryLight,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         centerTitle: true,
//         title: Text(
//           'Transaction Details',
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.primaryLight,
//           ),
//         ),
//         backgroundColor: AppColors.backgroundLight,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _detailRow('Amount', '₦${widget.transaction.amount.toStringAsFixed(2)}'),
//             const Divider(),
//             _detailRow('Date', widget.transaction.dateTime),
//             const Divider(),
//             _detailRow('Name', widget.transaction.name),
//             const Divider(),
//             _detailRow('Phone number', widget.transaction.phoneNumber),
//             const Divider(),
//             _detailRow('Session', widget.transaction.session),
//             const Divider(),
//             _detailRow('Reference number', widget.transaction.reference),
//             const Divider(),
//             _detailRow('Description', widget.transaction.description),
//           ],
//         ),
//       ),
//     );
//   }
// }