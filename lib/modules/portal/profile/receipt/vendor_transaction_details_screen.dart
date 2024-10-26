import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/profile/vendor_transaction_model.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final VendorTransaction transaction;

  const TransactionDetailsScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            )
          ),
          Text(
            value, 
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Transaction Details',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Amount', '₦${transaction.amount.toStringAsFixed(2)}'),
            const Divider(),
            _detailRow('Date', transaction.dateTime),
            const Divider(),
            _detailRow('Name', transaction.name),
            const Divider(),
            _detailRow('Phone number', transaction.phoneNumber),
            const Divider(),
            _detailRow('Session', transaction.session),
            const Divider(),
            _detailRow('Reference number', transaction.reference),
            const Divider(),
            _detailRow('Description', transaction.description),
          ],
        ),
      ),
    );
  }
}