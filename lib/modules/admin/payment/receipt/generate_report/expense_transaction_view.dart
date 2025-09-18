import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
import 'package:linkschool/modules/services/admin/payment/expenditure_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class ExpenseTransactionView extends StatefulWidget {
  final Map<String, dynamic>? initialParams;

  const ExpenseTransactionView({super.key, this.initialParams});

  @override
  State<ExpenseTransactionView> createState() => _ExpenseTransactionViewState();
}

class _ExpenseTransactionViewState extends State<ExpenseTransactionView> {
  late double opacity;
  Map<String, dynamic>? _expenditureData;
  bool _isLoading = true;
  late Map<String, dynamic> _filterParams;
  final ExpenditureService _expenditureService = locator<ExpenditureService>();

  @override
  void initState() {
    super.initState();
    _filterParams = Map.from(widget.initialParams ?? {'report_type': 'monthly'});
    _filterParams.remove('group_by'); // To get individual transactions
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userBox = Hive.box('userData');
      _filterParams['_db'] = userBox.get('_db');
      final response = await _expenditureService.generateReport(_filterParams);
      if (response.success && response.data != null) {
        setState(() {
          _expenditureData = response.data;
          _isLoading = false;
        });
      } else {
        throw Exception(response.message ?? 'Failed to load data');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      // Show error snackbar if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _expenditureData?['transactions'] ?? [];

    return Container(
      decoration: Constants.customBoxDecoration(context),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(209, 219, 255, 1).withOpacity(0.35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Termly report', // Update based on _filterParams['report_type']
                          style: AppTextStyles.normal500(fontSize: 14, color: AppColors.backgroundDark),
                        ),
                        SvgPicture.asset('assets/icons/profile/filter_icon.svg', height: 24, width: 24),
                      ],
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Expanded(
                //         child: GestureDetector(
                //           onTap: () {
                //             // Handle date picker
                //           },
                //           child: Container(
                //             padding: const EdgeInsets.all(12),
                //             child: const Row(
                //               children: [
                //                 Text('February 2023'),
                //                 Icon(Icons.arrow_drop_down),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //       const SizedBox(width: 16),
                //       Expanded(
                //         child: GestureDetector(
                //           onTap: () {
                //             // Handle session picker
                //           },
                //           child: Container(
                //             padding: const EdgeInsets.all(12),
                //             child: const Row(
                //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //               children: [
                //                 Text('2023/2024 3rd Term'),
                //                 Icon(Icons.arrow_drop_down),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Expanded(
                  child: transactions.isEmpty
                      ? const Center(child: Text('No transactions available'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: transactions.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  SvgPicture.asset('assets/icons/profile/payment_icon.svg'),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          transaction['name'] ?? 'Unknown',
                                          style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundDark),
                                        ),
                                        Text(
                                          transaction['date'] ?? '',
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
                                      const NairaSvgIcon(color: AppColors.backgroundDark),
                                      const SizedBox(width: 2),
                                      Text(
                                        (transaction['amount'] ?? 0).toStringAsFixed(2),
                                        style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundDark),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:hive/hive.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
// import 'package:linkschool/modules/services/admin/payment/expenditure_service.dart';
// import 'package:linkschool/modules/services/api/service_locator.dart';
// import 'dart:convert';

// class ExpenseTransactionView extends StatefulWidget {
//   final Map<String, dynamic>? initialParams;

//   const ExpenseTransactionView({super.key, this.initialParams});

//   @override
//   State<ExpenseTransactionView> createState() => _ExpenseTransactionViewState();
// }

// class _ExpenseTransactionViewState extends State<ExpenseTransactionView> {
//   late double opacity;
//   Map<String, dynamic>? _expenditureData;
//   bool _isLoading = true;
//   late Map<String, dynamic> _filterParams;

//   final ExpenditureService _expenditureService = locator<ExpenditureService>();

//   @override
//   void initState() {
//     super.initState();
//     _filterParams = Map.from(widget.initialParams ?? {'report_type': 'monthly'});
//     _filterParams.remove('group_by'); // To get individual transactions
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() => _isLoading = true);

//     try {
//       final userBox = Hive.box('userData');
//       _filterParams['_db'] = userBox.get('_db');
//       final response = await _expenditureService.generateReport(_filterParams);
//       setState(() {
//         _expenditureData = response.data;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading transactions: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final transactions = _expenditureData?['transactions'] ?? [];
//     return Container(
//       decoration: Constants.customBoxDecoration(context),
//       child: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Container(
//                     height: 50,
//                     decoration: BoxDecoration(
//                       color: const Color.fromRGBO(209, 219, 255, 1).withOpacity(0.35),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text('Monthly report', style: AppTextStyles.normal500(fontSize: 14, color: AppColors.backgroundDark),),
//                         SvgPicture.asset('assets/icons/profile/filter_icon.svg', height: 24, width: 24,),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () {
//                             // Handle date picker
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(12),
//                             child: const Row(
//                               children: [
//                                 Text('February 2023'),
//                                 Icon(Icons.arrow_drop_down),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () {
//                             // Handle session picker
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(12),
//                             child: const Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('2023/2024 3rd Term'),
//                                 Icon(Icons.arrow_drop_down),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: transactions.isEmpty
//                       ? const Center(child: Text('No transactions available'))
//                       : ListView.separated(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           itemCount: transactions.length,
//                           separatorBuilder: (context, index) => const Divider(),
//                           itemBuilder: (context, index) {
//                             final trans = transactions[index];
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               child: Row(
//                                 children: [
//                                   SvgPicture.asset('assets/icons/profile/payment_icon.svg'),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           trans['name'] ?? 'Unknown Vendor',
//                                           style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundDark),
//                                         ),
//                                         Text(
//                                           trans['date'] ?? '',
//                                           style: AppTextStyles.normal500(
//                                             fontSize: 12,
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Row(
//                                     children: [
//                                       const NairaSvgIcon(color: AppColors.backgroundDark),
//                                       const SizedBox(width: 2),
//                                       Text(
//                                         (trans['amount'] ?? 0).toStringAsFixed(2),
//                                         style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundDark),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                 ),        
//               ],
//             ),
//     );
//   }
// }