import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/admin/payment/expenditure/expense_transaction_detail.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
// import 'package:linkschool/lib/widgets/naira_svg_icon.dart';

class ExpenseHistoryDetail extends StatefulWidget {
  final String studentName;
  final String amount;
  final Map<String, dynamic> transaction;

  const ExpenseHistoryDetail({
    super.key,
    required this.studentName,
    required this.amount,
    required this.transaction,
  });

  @override
  State<ExpenseHistoryDetail> createState() => _ExpenseHistoryDetailState();
}

class _ExpenseHistoryDetailState extends State<ExpenseHistoryDetail> {
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
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          widget.studentName,
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
        child: ListView.builder(
          itemCount: 1, // Single transaction for consistency with ExpenseHistoryScreen
          itemBuilder: (context, index) => _buildDetailItem(context),
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0, left: 16.0, right: 16.0, top: 16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: SvgPicture.asset('assets/icons/profile/payment_icon.svg'),
        title: Text(
          widget.transaction['session'] ?? '2022/2023',
          style: AppTextStyles.normal600(fontSize: 18, color: AppColors.backgroundDark),
        ),
        subtitle: Text(
          widget.transaction['date'] ?? '07-03-2018 17:23',
          style: AppTextStyles.normal500(fontSize: 12, color: AppColors.text10Light),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '-',
                  style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.w700),
                ),
                const NairaSvgIcon(
                  width: 14.0,
                  height: 14.0,
                  color: Colors.red,
                ),
                const SizedBox(width: 2),
                Text(
                  widget.amount,
                  style: AppTextStyles.normal700(fontSize: 18, color: Colors.red),
                ),
              ],
            ),
            Text(
              widget.transaction['description'] ?? 'Clinical medication',
              style: AppTextStyles.normal500(fontSize: 12, color: AppColors.text10Light),
            ),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseTransactionDetail(
              amount: widget.amount,
              transaction: widget.transaction,
            ),
          ),
        ),
      ),
    );
  }
}



