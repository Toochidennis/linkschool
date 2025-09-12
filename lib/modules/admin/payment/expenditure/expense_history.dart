import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/admin/payment/expenditure/expense_history_detail.dart';

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
        trailing: Text(
          '-${widget.amount.toStringAsFixed(2)}',
          style: AppTextStyles.normal700(fontSize: 18, color: Colors.red),
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


// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';


// class ExpenseHistoryScreen extends StatefulWidget {
//   final String grade;
//   final String amount;
//   final String name;

//   const ExpenseHistoryScreen({
//     super.key,
//     required this.grade,
//     required this.amount,
//     required this.name,
//   });

//   @override
//   State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
// }

// class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
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
//           'Expense History',
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
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   DropdownButton<String>(
//                     hint: const Text('Class'),
//                     items: ['Basic', 'JSS', 'SSS']
//                         .map((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                     onChanged: (_) {},
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Search...',
//                   prefixIcon: const Icon(Icons.search),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: 5,
//                   itemBuilder: (context, index) {
//                     return _buildStudentItem(context);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStudentItem(BuildContext context) {
//     return Container(
//     margin: const EdgeInsets.only(bottom: 8),
//     decoration: BoxDecoration(
//       border: Border.all(color: Colors.grey.shade300),
//       borderRadius: BorderRadius.circular(8),
//     ),
//       child: ListTile(
//         leading: SvgPicture.asset('assets/icons/profile/payment_icon.svg'),
//         title: Text(widget.name, style: AppTextStyles.normal500(fontSize: 18, color: AppColors.backgroundDark),),
//         trailing: Text(widget.amount, style: AppTextStyles.normal700(fontSize: 18, color: const Color.fromRGBO(47, 85, 221, 1)),),
//         onTap: () {
//           _showReceiptOverlay(context);
//         },
//       ),
//     );
//   }

//  void _showReceiptOverlay(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true, // This allows the bottom sheet to be taller
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return DraggableScrollableSheet(
//           initialChildSize: 0.85, // Start at 85% of screen height
//           minChildSize: 0.5, // Minimum height (50% of screen)
//           maxChildSize: 0.95, // Maximum height (95% of screen)
//           expand: false,
//           builder: (_, controller) {
//             return SingleChildScrollView(
//               controller: controller,
//               child: Container(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 40,
//                       height: 5,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(2.5),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     SvgPicture.asset('assets/icons/profile/success_receipt_icon.svg', height: 60),
//                     const SizedBox(height: 24),
//                     const Text('Second Term Fees Receipt', 
//                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 16),
//                     Text(widget.amount, 
//                       style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
//                     const SizedBox(height: 24),
//                     Divider(thickness: 1, color: Colors.grey.withOpacity(0.5)),
//                     const SizedBox(height: 16),
//                     _buildReceiptDetail('Date', '2023-10-23'),
//                     _buildReceiptDetail('Name',  widget.name),
//                     _buildReceiptDetail('Level', widget.grade),
//                     _buildReceiptDetail('Class', '${widget.grade} A'),
//                     _buildReceiptDetail('Registration number', 'REG${DateTime.now().millisecondsSinceEpoch}'),
//                     _buildReceiptDetail('Session', '2023/2024'),
//                     _buildReceiptDetail('Term', '2nd Term Fees'),
//                     _buildReceiptDetail('Reference number', 'REF${DateTime.now().millisecondsSinceEpoch}'),
//                     const SizedBox(height: 32),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () {},
//                             style: OutlinedButton.styleFrom(
//                               side: const BorderSide(color: const Color.fromRGBO(47, 85, 221, 1),),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: Padding(
//                               padding: EdgeInsets.symmetric(vertical: 12),
//                               child: Text('Share', style: AppTextStyles.normal500(fontSize: 18, color: const Color.fromRGBO(47, 85, 221, 1),)),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () {},
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: Padding(
//                               padding: EdgeInsets.symmetric(vertical: 12),
//                               child: Text('Download', style: AppTextStyles.normal500(fontSize: 16.0, color: AppColors.backgroundLight)),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildReceiptDetail(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
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