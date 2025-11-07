// Updated transaction_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
import 'package:linkschool/modules/model/admin/payment_model.dart';
import 'package:linkschool/modules/services/admin/payment/payment_service.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class TransactionsView extends StatefulWidget {
  final Map<String, dynamic>? initialParams;

  const TransactionsView({super.key, this.initialParams});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  late double opacity;
  IncomeReport? _report;
  bool _isLoading = true;
  late Map<String, dynamic> _filterParams;

  late PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    final apiService = locator<ApiService>();
    _paymentService = PaymentService(apiService);
    _filterParams =
        Map.from(widget.initialParams ?? {'report_type': 'session'});
    _filterParams.remove('group_by'); // To get individual transactions
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final userBox = Hive.box('userData');
      _filterParams['_db'] = userBox.get('_db');
      final report = await _paymentService.getIncomeReport(_filterParams);
      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transactions: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
     color: Colors.white,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _report == null || _report!.transactions.isEmpty
              ? const Center(child: Text('No transactions available'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _report!.transactions.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final trans = _report!.transactions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                              'assets/icons/profile/payment_icon.svg'),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trans.name,
                                  style: AppTextStyles.normal600(
                                      fontSize: 16,
                                      color: AppColors.backgroundDark),
                                ),
                                Text(
                                  trans.date ?? '',
                                  style: AppTextStyles.normal500(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const NairaSvgIcon(
                                  color: AppColors.backgroundDark),
                              const SizedBox(width: 2),
                              Text(
                                trans.amount!.toStringAsFixed(2),
                                style: AppTextStyles.normal600(
                                    fontSize: 16,
                                    color: AppColors.backgroundDark),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
