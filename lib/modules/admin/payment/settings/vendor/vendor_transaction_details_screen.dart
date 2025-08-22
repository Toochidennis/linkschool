// New file: lib/modules/admin/payment/settings/vendor/vendor_transaction_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
import 'package:linkschool/modules/model/admin/vendor/vendor_model.dart';
import 'package:linkschool/modules/model/admin/vendor/vendor_transaction_year.dart';
import 'package:linkschool/modules/services/admin/payment/vendor_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
// import 'package:linkschool/modules/model/admin/vendor/vendor_transaction_model.dart';
// import 'package:linkschool/modules/common/naira_icon.dart';
import 'vendor_transaction_receipts_screen.dart';

class VendorTransactionDetailsScreen extends StatefulWidget {
  final Vendor vendor;
  final String year;

  const VendorTransactionDetailsScreen({
    super.key,
    required this.vendor,
    required this.year,
  });

  @override
  State<VendorTransactionDetailsScreen> createState() => _VendorTransactionDetailsScreenState();
}

class _VendorTransactionDetailsScreenState extends State<VendorTransactionDetailsScreen> {
  late double opacity;
  List<VendorTransactionDetail> details = [];
  bool isLoading = true;
  final VendorService _vendorService = locator<VendorService>();

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final response = await _vendorService.fetchVendorTransactionDetails(widget.vendor.id, int.parse(widget.year));
    if (response.success && response.data != null) {
      setState(() {
        details = response.data!;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      CustomToaster.toastError(context, 'Error', response.message);
    }
  }

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
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          '${int.parse(widget.year) - 1}/${widget.year} Transactions',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
          ),
        ),
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : details.isEmpty
                ? const Center(child: Text('No transaction details found'))
                : ListView.builder(
                    itemCount: details.length,
                    itemBuilder: (context, index) {
                      final detail = details[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: SvgPicture.asset('assets/icons/profile/payment_icon.svg'),
                          title: Text(detail.description),
                          subtitle: Text(
                            '${detail.date} - ${detail.accountName}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const NairaSvgIcon(color: Colors.red),
                              Text(
                                detail.amount.toStringAsFixed(2),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VendorTransactionReceiptsScreen(detail: detail),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:linkschool/modules/admin/payment/expenditure/expense_transaction_detail.dart';
// import 'package:linkschool/modules/admin/payment/settings/vendor/vendor_transaction_receipts_screen.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/model/profile/vendor_transaction_model.dart';
// // import 'package:linkschool/modules/admin_portal/payment/expenditure/expense_transaction_detail.dart';

// class VendorTransactionDetailsScreen extends StatefulWidget {
//   final String studentName;
//   final String amount;

//   const VendorTransactionDetailsScreen({super.key, required this.studentName, required this.amount, required VendorTransaction transaction});

//   @override
//   State<VendorTransactionDetailsScreen> createState() => _VendorTransactionDetailsScreenState();
// }

// class _VendorTransactionDetailsScreenState extends State<VendorTransactionDetailsScreen> {
//   late double opacity;
//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.primaryLight,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: Text(
//           widget.studentName,
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.primaryLight,
//           ),
//         ),
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
//         child: ListView.builder(
//           itemCount: 10,
//           itemBuilder: (context, index) => _buildDetailItem(context),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailItem(BuildContext context) {
//     return Container(
//         margin: const EdgeInsets.only(bottom: 8.0),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(8),
//         ),
//       child: ListTile(
//         leading: SvgPicture.asset('assets/icons/profile/payment_icon.svg'),
//         title: const Text('Hospital Fee...'),
//         subtitle: const Text('07-03-2018  17:23', style: TextStyle(color: Colors.grey)),
//         trailing: const Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text('-23,790.00', style: TextStyle(color: Colors.red)),
//             Text('account name', style: TextStyle(color: Colors.grey)),
//           ],
//         ),
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const VendorTransactionReceiptsScreen(transaction: transaction,),
//           ),
//         ),
//       ),
//     );
//   }
// }