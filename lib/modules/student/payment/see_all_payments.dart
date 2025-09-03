// lib/modules/student/payment/see_all_payments.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart'; // NairaSvgIcon
import 'package:linkschool/modules/model/student/payment_model.dart';
import 'package:linkschool/modules/student/payment/student_reciept_dialog.dart'; // 👈 correct import (reciept)

class PaymentHistorySeeAllScreen extends StatefulWidget {
  final List<Payment> payments;

  const PaymentHistorySeeAllScreen({super.key, required this.payments});

  @override
  State<PaymentHistorySeeAllScreen> createState() =>
      _PaymentHistorySeeAllScreenState();
}

class _PaymentHistorySeeAllScreenState
    extends State<PaymentHistorySeeAllScreen> {
  String? selectedYear;
  String? selectedTerm;
  bool sortNewestFirst = true;

  List<String> get years =>
      widget.payments.map((p) => p.year.toString()).toSet().toList()
        ..sort((a, b) => b.compareTo(a)); // newest year first

  List<String> get terms =>
      widget.payments.map((p) => p.termName).toSet().toList()
        ..sort((a, b) => a.compareTo(b));

  List<Payment> _applyFilters() {
    var data = List<Payment>.from(widget.payments);

    // Filter by year
    if (selectedYear != null) {
      data = data.where((p) => p.year.toString() == selectedYear).toList();
    }

    // Filter by term
    if (selectedTerm != null) {
      data = data.where((p) => p.termName == selectedTerm).toList();
    }

    // Sort by date
    data.sort((a, b) =>
        sortNewestFirst ? b.date.compareTo(a.date) : a.date.compareTo(b.date));
    return data;
  }

  void _openReceipt(BuildContext context, Payment payment) {
    showDialog(
      context: context,
      builder: (_) => StudentRecieptDialog(payment: payment), // 👈 correct class name
    );
  }

  String _formatCount(int n) => n == 1 ? '1 payment' : '$n payments';

  @override
  Widget build(BuildContext context) {
    final filtered = _applyFilters();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Payment History",
          style: AppTextStyles.normalLight.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Filters + Sort
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Year filter
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedYear,
                      decoration: const InputDecoration(
                        labelText: "Year",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: years
                          .map((y) =>
                              DropdownMenuItem(value: y, child: Text(y)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedYear = v),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Term filter
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedTerm,
                      decoration: const InputDecoration(
                        labelText: "Term",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: terms
                          .map((t) =>
                              DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedTerm = v),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Sort
                  IconButton(
                    tooltip: sortNewestFirst ? "Newest first" : "Oldest first",
                    onPressed: () =>
                        setState(() => sortNewestFirst = !sortNewestFirst),
                    icon: Icon(
                      sortNewestFirst
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _formatCount(filtered.length),
                  style: AppTextStyles.normalLight
                      .copyWith(color: Colors.grey[700]),
                ),
              ),
            ),
          ),

          // List
          SliverList.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 0.5,
              color: Colors.grey,
            ),
            itemBuilder: (context, index) {
              final payment = filtered[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: PaymentHistoryItem(
                  payment: payment,
                  onTap: () => _openReceipt(context, payment),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Same visuals as your provided PaymentHistoryItem
class PaymentHistoryItem extends StatelessWidget {
  final Payment payment;
  final VoidCallback onTap;

  const PaymentHistoryItem({
    Key? key,
    required this.payment,
    required this.onTap,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.paymentBtnColor1,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/e_learning/receipt_list_icon.svg',
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          '${payment.termName} Fees for ${payment.year} session',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          _formatDate(payment.date), // payment.date is DateTime
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const NairaSvgIcon(color: AppColors.paymentTxtColor5, size: 16),
                const SizedBox(width: 2),
                Text(
                  _formatAmount(payment.amount),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Text(
              'Paid',
              style: TextStyle(color: Colors.green, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
