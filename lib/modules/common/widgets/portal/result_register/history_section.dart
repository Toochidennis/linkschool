import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/widgets/portal/result_register/registered_student_screen.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/admin/result/class_detail/registration/see_all_history.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/providers/admin/term_provider.dart';

class HistorySection extends StatelessWidget {
  final String classId;  // Added classId parameter
  
  const HistorySection({
    required this.classId,  // Added required parameter
    super.key,
  });

  // Method to show terms bottom sheet, updated with navigation to RegisteredStudentsScreen
  void _showTermsBottomSheet(BuildContext context, String session, List<Map<String, dynamic>> terms) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow scrolling control
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6, // Limit to 60% of screen height
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '$session Terms',
                    style: AppTextStyles.normal700(
                      fontSize: 24,
                      color: AppColors.backgroundDark,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: ListView.builder(
                    itemCount: terms.length,
                    itemBuilder: (context, index) {
                      final term = terms[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _buildTermButton(
                          term['termName'] ?? 'Unknown Term',
                          () {
                            // Close the bottom sheet
                            Navigator.pop(bottomSheetContext);
                            
                            // Get the year and term value for navigation
                            final year = int.tryParse(term['year'] ?? '0') ?? 0;
                            final termValue = term['termId'] ?? 0;
                            
                            // Navigate to RegisteredStudentsScreen with required parameters
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisteredStudentsScreen(
                                  year: year,
                                  termValue: termValue,
                                  termName: term['termName'] ?? 'Unknown Term',
                                  classId: classId,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to create consistent term buttons
  Widget _buildTermButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppColors.dialogBtnColor,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(4),
            ),
            child: Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              child: Text(
                text,
                style: AppTextStyles.normal600(
                  fontSize: 16, 
                  color: AppColors.backgroundDark,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TermProvider>(
      builder: (context, termProvider, child) {
        // Group terms by year
        final groupedTerms = <String, List<Map<String, dynamic>>>{};
        
        for (final term in termProvider.terms) {
          final year = term['year'].toString();
          if (!groupedTerms.containsKey(year)) {
            groupedTerms[year] = [];
          }
          groupedTerms[year]!.add(term);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), 
              topRight: Radius.circular(10)
            ),
            color: AppColors.regBgColor1,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'History',
                    style: AppTextStyles.normal600(
                      fontSize: 16, 
                      color: AppColors.backgroundDark
                    )
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SeeAllHistory())
                      );
                    },
                    child: Text(
                      'See all',
                      style: AppTextStyles.normal500(
                        fontSize: 14, 
                        color: AppColors.barTextGray
                      ).copyWith(decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // If no terms are available
              if (termProvider.terms.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No academic sessions available',
                    style: AppTextStyles.normal600(
                      fontSize: 16,
                      color: AppColors.primaryLight
                    ),
                  ),
                ),
              
              // ListView of academic sessions
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: groupedTerms.length,
                itemBuilder: (context, index) {
                  final year = groupedTerms.keys.elementAt(index);
                  final nextYear = (int.parse(year) + 1).toString();
                  final session = '$year/$nextYear';
                  final sessionTerms = groupedTerms[year]!;

                  return InkWell(
                    onTap: () => _showTermsBottomSheet(
                      context, 
                      session, 
                      sessionTerms
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      height: 90,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$session academic session',
                                style: AppTextStyles.normal700(
                                  fontSize: 14, 
                                  color: AppColors.backgroundDark
                                )
                              ),
                              SizedBox(
                                height: 24,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16, 
                                      vertical: 0
                                    ),
                                    backgroundColor: AppColors.backgroundLight,
                                    side: const BorderSide(
                                      color: AppColors.primaryLight
                                    ),
                                  ),
                                  onPressed: () => _showTermsBottomSheet(
                                    context, 
                                    session, 
                                    sessionTerms
                                  ),
                                  child: Text(
                                    'See details',
                                    style: AppTextStyles.normal500(
                                      fontSize: 12,
                                      color: AppColors.primaryLight
                                    )
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Text(
                                '${sessionTerms.length}', // Number of terms
                                style: AppTextStyles.normal600(
                                  fontSize: 12, 
                                  color: AppColors.regTextGray
                                )
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'terms available',
                                style: AppTextStyles.normal600(
                                  fontSize: 11, 
                                  color: AppColors.regTextGray
                                )
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:linkschool/modules/admin/result/class_detail/registration/see_all_history.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/providers/admin/term_provider.dart';

// class HistorySection extends StatelessWidget {
//   const HistorySection({super.key});

//   // Method to show terms bottom sheet, updated with the implementation from LevelSelection
//   void _showTermsBottomSheet(BuildContext context, String session, List<Map<String, dynamic>> terms) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true, // Allow scrolling control
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext bottomSheetContext) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//           ),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.6, // Limit to 60% of screen height
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 24),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Text(
//                     '$session Terms',
//                     style: AppTextStyles.normal700(
//                       fontSize: 24,
//                       color: AppColors.backgroundDark,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Flexible(
//                   child: ListView.builder(
//                     itemCount: terms.length,
//                     itemBuilder: (context, index) {
//                       final term = terms[index];
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         child: _buildTermButton(
//                           term['termName'] ?? 'Unknown Term',
//                           () {
//                             // Add any additional action when a term is tapped
//                             Navigator.pop(bottomSheetContext);
//                             // You can add navigation to a term detail screen here if needed
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Helper method to create consistent term buttons
//   Widget _buildTermButton(String text, VoidCallback onPressed) {
//     return Container(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.3),
//             spreadRadius: 1,
//             blurRadius: 3,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: AppColors.dialogBtnColor,
//         child: InkWell(
//           onTap: onPressed,
//           borderRadius: BorderRadius.circular(4),
//           child: Ink(
//             decoration: BoxDecoration(
//               color: Colors.white, 
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Container(
//               width: double.infinity,
//               height: 50,
//               alignment: Alignment.center,
//               child: Text(
//                 text,
//                 style: AppTextStyles.normal600(
//                   fontSize: 16, 
//                   color: AppColors.backgroundDark,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<TermProvider>(
//       builder: (context, termProvider, child) {
//         // Group terms by year
//         final groupedTerms = <String, List<Map<String, dynamic>>>{};
        
//         for (final term in termProvider.terms) {
//           final year = term['year'].toString();
//           if (!groupedTerms.containsKey(year)) {
//             groupedTerms[year] = [];
//           }
//           groupedTerms[year]!.add(term);
//         }

//         return Container(
//           margin: const EdgeInsets.symmetric(horizontal: 16),
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(10), 
//               topRight: Radius.circular(10)
//             ),
//             color: AppColors.regBgColor1,
//           ),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'History',
//                     style: AppTextStyles.normal600(
//                       fontSize: 16, 
//                       color: AppColors.backgroundDark
//                     )
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => const SeeAllHistory())
//                       );
//                     },
//                     child: Text(
//                       'See all',
//                       style: AppTextStyles.normal500(
//                         fontSize: 14, 
//                         color: AppColors.barTextGray
//                       ).copyWith(decoration: TextDecoration.underline),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
              
//               // If no terms are available
//               if (termProvider.terms.isEmpty)
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text(
//                     'No academic sessions available',
//                     style: AppTextStyles.normal600(
//                       fontSize: 16,
//                       color: AppColors.primaryLight
//                     ),
//                   ),
//                 ),
              
//               // ListView of academic sessions
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: groupedTerms.length,
//                 itemBuilder: (context, index) {
//                   final year = groupedTerms.keys.elementAt(index);
//                   final nextYear = (int.parse(year) + 1).toString();
//                   final session = '$year/$nextYear';
//                   final sessionTerms = groupedTerms[year]!;

//                   return InkWell(
//                     onTap: () => _showTermsBottomSheet(
//                       context, 
//                       session, 
//                       sessionTerms
//                     ),
//                     child: Container(
//                       margin: const EdgeInsets.only(bottom: 16),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: AppColors.backgroundLight,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       height: 90,
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 '$session academic session',
//                                 style: AppTextStyles.normal700(
//                                   fontSize: 14, 
//                                   color: AppColors.backgroundDark
//                                 )
//                               ),
//                               SizedBox(
//                                 height: 24,
//                                 child: OutlinedButton(
//                                   style: OutlinedButton.styleFrom(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 16, 
//                                       vertical: 0
//                                     ),
//                                     backgroundColor: AppColors.backgroundLight,
//                                     side: const BorderSide(
//                                       color: AppColors.primaryLight
//                                     ),
//                                   ),
//                                   onPressed: () => _showTermsBottomSheet(
//                                     context, 
//                                     session, 
//                                     sessionTerms
//                                   ),
//                                   child: Text(
//                                     'See details',
//                                     style: AppTextStyles.normal500(
//                                       fontSize: 12,
//                                       color: AppColors.primaryLight
//                                     )
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 14),
//                           Row(
//                             children: [
//                               Text(
//                                 '${sessionTerms.length}', // Number of terms
//                                 style: AppTextStyles.normal600(
//                                   fontSize: 12, 
//                                   color: AppColors.regTextGray
//                                 )
//                               ),
//                               const SizedBox(width: 10),
//                               Text(
//                                 'terms available',
//                                 style: AppTextStyles.normal600(
//                                   fontSize: 11, 
//                                   color: AppColors.regTextGray
//                                 )
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }