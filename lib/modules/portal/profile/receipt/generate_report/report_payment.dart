import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/portal/profile/receipt/generate_report/statistics_view.dart';
import 'package:linkschool/modules/portal/profile/receipt/generate_report/transaction_view.dart';
// import 'package:linkschool/modules/common/constants.dart';

class ReportPaymentScreen extends StatefulWidget {
  const ReportPaymentScreen({super.key});

  @override
  State<ReportPaymentScreen> createState() => _ReportPaymentScreenState();
}

class _ReportPaymentScreenState extends State<ReportPaymentScreen> {
  int _selectedIndex = 0;

  // List of widgets to display for each navigation item
  final List<Widget> _screens = [
    const TransactionsView(),
    const StatisticsView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          'Payments',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        // centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // Handle download action
            },
            child: Text(
              'Download',
              style: AppTextStyles.normal600(fontSize: 14, color: AppColors.paymentTxtColor1),
            ),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/profile/nav_transaction_icon.svg',
              color: _selectedIndex == 0 ? Color.fromRGBO(47, 85, 221, 1) : Colors.grey,
            ),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/profile/nav_statistics_icon.svg',
              color: _selectedIndex == 1 ? Color.fromRGBO(47, 85, 221, 1) : Colors.grey,
            ),
            label: 'Statistics',
          ),
        ],
        selectedItemColor: Color.fromRGBO(47, 85, 221, 1),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';


// class ReportPaymentScreen extends StatelessWidget {

//   const ReportPaymentScreen({
//     super.key, 
//   });

//   @override
//   Widget build(BuildContext context) {
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
//           'Payments',
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.primaryLight,
//           ),
//         ),
//         backgroundColor: AppColors.backgroundLight,
//         centerTitle: true,
//         actions: [
//           TextButton(
//             onPressed: () {
//               // Handle download action
//             },
//             child: const Text(
//               'Download',
//               style: TextStyle(color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Container(
//                   width: 327,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: Color.fromRGBO(209, 219, 255, 1),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text('Termly report'),
//                       SvgPicture.asset('assets/icons/profile/filter_icon.svg'),
//                     ],
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Month/Year Picker
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () {
//                           // Handle date picker
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           // decoration: BoxDecoration(
//                           //   border: Border.all(color: Colors.grey),
//                           //   borderRadius: BorderRadius.circular(8),
//                           // ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('February 2023'),
//                               const Icon(Icons.arrow_drop_down),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     // Session Picker
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () {
//                           // Handle session picker
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           // decoration: BoxDecoration(
//                           //   border: Border.all(color: Colors.grey),
//                           //   borderRadius: BorderRadius.circular(8),
//                           // ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('2023/2024 3rd Term'),
//                               const Icon(Icons.arrow_drop_down),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: 10, // Replace with actual data length
//                   itemBuilder: (context, index) {
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 16),
//                       child: Row(
//                         children: [
//                           SvgPicture.asset('assets/icons/profile/payment_icon.svg'),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Dennis Johnson',
//                                   style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundDark),
//                                 ),
//                                 Text(
//                                   '07-03-2018 17:13',
//                                   style: AppTextStyles.normal400(
//                                     fontSize: 12,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Text(
//                             '23,790.00',
//                             style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundDark),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     offset: const Offset(0, -5),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildNavItem(
//                     icon: 'assets/icons/profile/nav_transaction_icon.svg',
//                     label: 'Transactions',
//                     isSelected: true,
//                   ),
//                   _buildNavItem(
//                     icon: 'assets/icons/profile/nav_statistics_icon.svg',
//                     label: 'Statistics',
//                     isSelected: false,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required String icon,
//     required String label,
//     required bool isSelected,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//       decoration: BoxDecoration(
//         color: isSelected ? const Color(0xFF2F55DD) : Colors.transparent,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           SvgPicture.asset(
//             icon,
//             color: isSelected ? Colors.white : Colors.grey,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               color: isSelected ? Colors.white : Colors.grey,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }