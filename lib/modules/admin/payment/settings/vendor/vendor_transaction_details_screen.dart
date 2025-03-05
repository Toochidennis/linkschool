import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/profile/vendor_transaction_model.dart';
import 'package:linkschool/modules/admin/payment/expenditure/expense_download_receipt_screen.dart';
import 'package:linkschool/modules/admin/payment/expenditure/expense_share_reciept_screen.dart';

class VendorTransactionDetailsScreen extends StatefulWidget {
  final VendorTransaction transaction;

  const VendorTransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<VendorTransactionDetailsScreen> createState() => _VendorTransactionDetailsScreenState();
}

class _VendorTransactionDetailsScreenState extends State<VendorTransactionDetailsScreen> {
  late double opacity;

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
          'Transaction Details',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.paymentTxtColor1,
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
              )
            ],
          ),
        ),
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildFirstCard(),
              const SizedBox(height: 16),
              _buildSecondCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showShareReceipt(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color.fromRGBO(47, 85, 221, 1),
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
                  onPressed: () => _showDownloadReceipt(),
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
                            fontSize: 16.0, color: AppColors.backgroundLight)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirstCard() {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            children: [
              SvgPicture.asset('assets/icons/profile/rounded_success_icon.svg'),
              const SizedBox(height: 8.0),
              Text(
                'Vendor Transaction',
                style: AppTextStyles.normal400(
                    fontSize: 14, color: AppColors.backgroundDark),
              ),
              const SizedBox(height: 8.0),
              Text(
                '₦${widget.transaction.amount.toStringAsFixed(2)}',
                style: AppTextStyles.normal700(
                    fontSize: 26, color: AppColors.paymentTxtColor1),
              ),
              const SizedBox(height: 8.0),
              Text('Successful',
                  style: AppTextStyles.normal600(
                      fontSize: 18, color: AppColors.eLearningContColor3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow('Date', widget.transaction.dateTime),
            _buildDetailRow('Name', widget.transaction.name),
            _buildDetailRow('Phone Number', widget.transaction.phoneNumber),
            _buildDetailRow('Session', widget.transaction.session),
            _buildDetailRow('Reference No', widget.transaction.reference),
            _buildDetailRow('Description', widget.transaction.description),
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
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value),
        ],
      ),
    );
  }

  void _showShareReceipt() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) => ExpenseShareRecieptScreen(
          amount: widget.transaction.amount.toStringAsFixed(2),
        ),
      ),
    );
  }

  void _showDownloadReceipt() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) => ExpenseDownloadReceiptScreen(
          amount: widget.transaction.amount.toStringAsFixed(2),
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