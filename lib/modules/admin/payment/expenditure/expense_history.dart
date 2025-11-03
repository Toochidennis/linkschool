import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/admin/payment/expenditure/expense_history_detail.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
// import 'package:linkschool/lib/widgets/naira_svg_icon.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  final String grade;
  final double amount;
  final String name;
  final Map<String, dynamic> transaction;

  const ExpenseHistoryScreen({
    super.key,
    required this.grade,
    required this.amount,
    required this.name,
    required this.transaction,
  });

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
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
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Expense History',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DropdownButton<String>(
                    hint: const Text('Class'),
                    items: ['Basic', 'JSS', 'SSS']
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (_) {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 1, // Single transaction for now
                  itemBuilder: (context, index) => _buildTransactionItem(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: SvgPicture.asset('assets/icons/profile/payment_icon.svg'),
        title: Text(
          widget.name,
          style: AppTextStyles.normal500(fontSize: 18, color: AppColors.backgroundDark),
        ),
        subtitle: Text(
          widget.transaction['date'] ?? '07-03-2018  17:23',
          style: AppTextStyles.normal500(fontSize: 12, color: AppColors.text10Light),
        ),
        trailing: Row(
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
              widget.amount.toStringAsFixed(2),
              style: AppTextStyles.normal700(fontSize: 18, color: Colors.red),
            ),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseHistoryDetail(
              studentName: widget.name,
              amount: widget.amount.toStringAsFixed(2),
              transaction: widget.transaction,
            ),
          ),
        ),
      ),
    );
  }
}

