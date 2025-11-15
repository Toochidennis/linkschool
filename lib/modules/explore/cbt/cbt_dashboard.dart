import 'package:flutter/material.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
import 'package:linkschool/modules/model/explore/cbt_history_model.dart';
import 'package:linkschool/modules/explore/e_library/test_screen.dart';
import 'package:linkschool/modules/explore/cbt/all_test_history_screen.dart';
import 'package:linkschool/modules/explore/cbt/all_subjects_screen.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../common/text_styles.dart';
import '../../common/app_colors.dart';
import '../../common/constants.dart';
import '../components/year_picker_dialog.dart';
import '../ebooks/books_button_item.dart';

class CBTDashboard extends StatefulWidget {
   final bool showAppBar;
final bool fromELibrary;
  const CBTDashboard({super.key,  this.showAppBar =true, this.fromELibrary=false});

  @override
  State<CBTDashboard> createState() => _CBTDashboardState();
}

class _CBTDashboardState extends State<CBTDashboard> with AutomaticKeepAliveClientMixin {
     @override
   bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load boards when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CBTProvider>().loadBoards();
    });
  }

  @override
  Widget build(BuildContext context) {
     super.build(context); 
    return Scaffold(
      appBar: widget.showAppBar 
          ? Constants.customAppBar(context: context, showBackButton: true,title: 'CBT Dashboard',)
          : null,
      body: Consumer<CBTProvider>(
        builder: (context, provider, child) {
          return Skeletonizer(
            enabled: provider.isLoading,
            child: Container(
              decoration: Constants.customBoxDecoration(context),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                   SliverToBoxAdapter(
                    child: _buildPerformanceMetrics(),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
                  SliverToBoxAdapter(
                    child: _buildTestHistory(),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  SliverToBoxAdapter(
                    child: _buildCBTCategories(provider),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        provider.selectedBoard?.title ?? 'Board Title',
                        style: AppTextStyles.normal600(
                          fontSize: 22.0,
                          color: AppColors.text4Light,
                        ),
                      ),
                    ),
                  ),
                 
                  const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
                  SliverToBoxAdapter(
                    child: Constants.headingWithSeeAll600(
                      title: 'Choose subject',
                      titleSize: 18.0,
                      titleColor: AppColors.text4Light,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllSubjectsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  _buildSubjectList(provider),
                  const SliverToBoxAdapter(child: SizedBox(height: 20.0)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCBTCategories(CBTProvider provider) {
    if (provider.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 6, // Display 6 placeholder items
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            );
          },
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children: provider.boardCodes.map((code) {
            return BooksButtonItem(
              label: code,
              isSelected: provider.selectedBoard?.boardCode == code,
              onPressed: () => provider.selectBoard(code),
            );
          }).toList(),
        ),
      );
    }
  }

  Widget _buildPerformanceMetrics() {
    return Consumer<CBTProvider>(
      builder: (context, provider, child) {
        // Don't show performance metrics if there's no history
        if (provider.recentHistory.isEmpty) {
          return const SizedBox.shrink();
        }
        
        // Debug logging
        print('📊 Dashboard Display - Performance Metrics:');
        print('   Total Tests: ${provider.totalTests}');
        print('   Success Count: ${provider.successCount}');
        print('   Average Score: ${provider.averageScore.toStringAsFixed(1)}%');
        print('   Recent History Count: ${provider.recentHistory.length}');
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPerformanceCard(
                imagePath: 'assets/icons/test.png',
                title: 'Tests',
                completionRate: provider.totalTests.toString(),
                backgroundColor: AppColors.cbtColor1,
                borderColor: AppColors.cbtBorderColor1,
              ),
              const SizedBox(width: 16.0),
              _buildPerformanceCard(
                imagePath: 'assets/icons/success.png',
                title: 'Completed',
                completionRate: provider.successCount.toString(),
                backgroundColor: AppColors.cbtColor2,
                borderColor: AppColors.cbtBorderColor2,
              ),
              const SizedBox(width: 16.0),
              _buildPerformanceCard(
                imagePath: 'assets/icons/average.png',
                title: 'Average',
                completionRate: '${provider.averageScore.toStringAsFixed(0)}%',
                backgroundColor: AppColors.cbtColor3,
                borderColor: AppColors.cbtBorderColor3,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTestHistory() {
    return Consumer<CBTProvider>(
      builder: (context, provider, child) {
        // Don't show test history section if there's no data
        if (provider.recentHistory.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Constants.headingWithSeeAll600(
              title: 'Test history',
              titleSize: 18.0,
              titleColor: AppColors.text4Light,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllTestHistoryScreen(),
                  ),
                ).then((_) {
                  // Refresh stats when coming back
                  provider.refreshStats();
                });
              },
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 16.0),
                itemCount: provider.recentHistory.length,
                itemBuilder: (context, index) {
                  final history = provider.recentHistory[index];
                  final colors = [
                    AppColors.cbtColor3,
                    AppColors.cbtColor4,
                    AppColors.cbtColor1,
                  ];
                  
                  return _buildHistoryCard(
                    context: context,
                    history: history,
                    courseName: history.subject,
                    year: history.year.toString(),
                    progressValue: history.percentage / 100,
                    borderColor: colors[index % colors.length],
                    provider: provider,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubjectList(CBTProvider provider) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (provider.isLoading) {
            return _buildChooseSubjectCard(
              subject: 'Subject Name',
              year: 'Year Range',
              cardColor: AppColors.cbtCardColor1,
              subjectIcon: 'default',
            );
          }
          final subject = provider.currentBoardSubjects[index];
          return _buildChooseSubjectCard(
            subject: subject.name,
            year: subject.years != null && subject.years!.isNotEmpty
                ? "${subject.years!.first.year}-${subject.years!.last.year}"
                : "N/A",
            cardColor: subject.cardColor ?? AppColors.cbtCardColor1,
            subjectIcon: subject.subjectIcon ?? 'default',
          );
        },
        childCount: provider.isLoading
            ? 10
            : provider.currentBoardSubjects
                .length, // Increased to 10 placeholder items
      ),
    );
  }

  Widget _buildPerformanceCard({
    required String title,
    required String completionRate,
    required String imagePath,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        height: 130.0,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              spreadRadius: 0,
              offset: const Offset(0, 1),
              blurRadius: 2,
              color: Colors.black.withOpacity(0.25),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
              width: 24.0,
              height: 24.0,
            ),
            const SizedBox(height: 4.0),
            Text(
              completionRate,
              style: AppTextStyles.normal600(
                fontSize: 24.0,
                color: AppColors.backgroundLight,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              title,
              style: AppTextStyles.normal600(
                fontSize: 16.0,
                color: AppColors.backgroundLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required BuildContext context,
    required CbtHistoryModel history,
    required String courseName,
    required String year,
    required double progressValue,
    required Color borderColor,
    required CBTProvider provider,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to test screen to retake the exam
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestScreen(
              examTypeId: history.examId,
              subjectId: null, // Can be null, test screen handles it
              subject: history.subject,
              year: history.year,
              calledFrom: 'dashboard', // Indicate it's called from dashboard
            ),
          ),
        ).then((_) {
          // Refresh stats when coming back from test
          provider.refreshStats();
        });
      },
      child: Container(
        width: 195,
        margin: const EdgeInsets.only(left: 16.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 70.0,
                  width: 70.0,
                  child: CircularProgressIndicator(
                    color: borderColor,
                    value: progressValue,
                    strokeWidth: 7.5,
                  ),
                ),
                Text(
                  '${(progressValue * 100).round()}%',
                  style: AppTextStyles.normal600(
                    fontSize: 16.0,
                    color: AppColors.text4Light,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseName,
                    style: AppTextStyles.normal600(
                      fontSize: 16.0,
                      color: AppColors.text4Light,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '($year)',
                    style: AppTextStyles.normal600(
                      fontSize: 12.0,
                      color: AppColors.text7Light,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Tap to retake',
                    style: AppTextStyles.normal600(
                      fontSize: 14.0,
                      color: AppColors.text8Light,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // In your _buildChooseSubjectCard method, update the onTap handler:

Widget _buildChooseSubjectCard({
  required String subject,
  required String year,
  required Color cardColor,
  required String subjectIcon,
}) {
  return Consumer<CBTProvider>(
    builder: (context, provider, child) {
      // Get the YearModel list instead of just year strings
      final yearModels = provider.getYearModelsForSubject(subject);

      return GestureDetector(
        onTap: () {
          if (yearModels.isNotEmpty) {
            // Find the subject model to get subject ID
            final subjectModel = provider.currentBoardSubjects.firstWhere(
              (s) => s.name == subject,
              orElse: () => provider.currentBoardSubjects.first,
            );

            YearPickerDialog.show(
              context,
              title: 'Choose Year',
              yearModels: yearModels, // Pass YearModel list
              subject: subject,
              subjectIcon: provider.getSubjectIcon(subject),
              cardColor: provider.getSubjectColor(subject),
              subjectList: provider.getOtherSubjects(subject),
              subjectId: subjectModel.id, // Pass subject ID
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No years available for this subject'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: Container(
          width: double.infinity,
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.cbtColor5)),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icons/$subjectIcon.png',
                    width: 24.0,
                    height: 24.0,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                        maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.normal600(
                        fontSize: 16.0,
                        color: AppColors.backgroundDark,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      year,
                      style: AppTextStyles.normal600(
                        fontSize: 12.0,
                        color: AppColors.text9Light,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}
}







// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:skeletonizer/skeletonizer.dart';
// import '../../common/text_styles.dart';
// import '../../common/app_colors.dart';
// import '../../common/constants.dart';
// import '../components/year_picker_dialog.dart';
// import '../ebooks/books_button_item.dart';

// class CBTDashboard extends StatefulWidget {
//   /// Whether to show the AppBar. Defaults to true.
//   final bool showAppBar;
//   final bool fromELibrary;

//   const CBTDashboard({super.key, this.showAppBar = true, this.fromELibrary = false});

//   @override
//   State<CBTDashboard> createState() => _CBTDashboardState();
// }

// class _CBTDashboardState extends State<CBTDashboard> with AutomaticKeepAliveClientMixin {
//     @override
//   bool get wantKeepAlive => true;
//   @override
//   void initState() {
//     super.initState();
//     // Load boards when the screen initializes
//    if(mounted){
//      WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<CBTProvider>().loadBoards();
//     });
//    }
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context); 

//     return Scaffold(
//       appBar: widget.showAppBar
//           ? Constants.customAppBar(context: context, showBackButton: true)
//           : null,
//       body: Consumer<CBTProvider>(
//         builder: (context, provider, child) {
//           return Skeletonizer(
//             enabled: provider.isLoading,
//             child: Container(
//               decoration: Constants.customBoxDecoration(context),
//               child: CustomScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 slivers: [
//                   const SliverToBoxAdapter(child: SizedBox(height: 30)),
//                   SliverToBoxAdapter(
//                     child: _buildCBTCategories(provider),
//                   ),
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Text(
//                         provider.selectedBoard?.title ?? 'Board Title',
//                         style: AppTextStyles.normal600(
//                           fontSize: 22.0,
//                           color: AppColors.text4Light,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SliverToBoxAdapter(
//                     child: _buildPerformanceMetrics(),
//                   ),
//                   const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
//                   SliverToBoxAdapter(
//                     child: _buildTestHistory(),
//                   ),
//                   const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
//                   SliverToBoxAdapter(
//                     child: Constants.headingWithSeeAll600(
//                       title: 'Choose subject',
//                       titleSize: 18.0,
//                       titleColor: AppColors.text4Light,
//                     ),
//                   ),
                  
//                   //_buildSubjectList(provider),
//                   // Add some bottom padding
//                   const SliverToBoxAdapter(child: SizedBox(height: 100.0)),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// Widget _buildCBTCategories(CBTProvider provider) {
//   if (provider.isLoading) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           childAspectRatio: 2.5,
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//         ),
//         itemCount: 6, // Display 6 placeholder items
//         itemBuilder: (context, index) {
//           return Container(
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(8),
//             ),
//           );
//         },
//       ),
//     );
//   } else {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Wrap(
//         spacing: 10.0,
//         runSpacing: 10.0,
//         children: provider.boardCodes.map((code) {
//           return BooksButtonItem(
//             label: code,
//             isSelected: provider.selectedBoard?.boardCode == code,
//             onPressed: () => provider.selectBoard(code),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

// Widget _buildPerformanceMetrics() {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _buildPerformanceCard(
//           imagePath: 'assets/icons/test.png',
//           title: 'Tests',
//           completionRate: '123',
//           backgroundColor: AppColors.cbtColor1,
//           borderColor: AppColors.cbtBorderColor1,
//         ),
//         const SizedBox(width: 16.0),
//         _buildPerformanceCard(
//           imagePath: 'assets/icons/success.png',
//           title: 'Success',
//           completionRate: '123%',
//           backgroundColor: AppColors.cbtColor2,
//           borderColor: AppColors.cbtBorderColor2,
//         ),
//         const SizedBox(width: 16.0),
//         _buildPerformanceCard(
//           imagePath: 'assets/icons/average.png',
//           title: 'Average',
//           completionRate: '123%',
//           backgroundColor: AppColors.cbtColor3,
//           borderColor: AppColors.cbtBorderColor3,
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildTestHistory() {
//   return Consumer<CBTProvider>(
//     builder: (context, provider, child) {
//       // Generate sample history based on available subjects
//       final recentSubjects = provider.currentBoardSubjects.take(3).toList();
      
//       if (recentSubjects.isEmpty) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Constants.headingWithSeeAll600(
//               title: 'Test history',
//               titleSize: 18.0,
//               titleColor: AppColors.text4Light,
//             ),
//             const SizedBox(height: 100),
//           ],
//         );
//       }
      
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Constants.headingWithSeeAll600(
//             title: 'Test history',
//             titleSize: 18.0,
//             titleColor: AppColors.text4Light,
//           ),
//           SizedBox(
//             height: 120,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.only(right: 16.0),
//               itemCount: recentSubjects.length,
//               itemBuilder: (context, index) {
//                 final subject = recentSubjects[index];
//                 final latestYear = subject.years?.isNotEmpty == true 
//                     ? subject.years!.last.year 
//                     : '2024';
//                 final colors = [
//                   AppColors.cbtColor3,
//                   AppColors.cbtColor4,
//                   AppColors.cbtColor1,
//                 ];
//                 final progressValues = [0.75, 0.60, 0.45]; // Sample progress values
                
//                 return _buildHistoryCard(
//                   courseName: subject.name,
//                   year: latestYear,
//                   progressValue: progressValues[index % progressValues.length],
//                   borderColor: colors[index % colors.length],
//                 );
//               },
//             ),
//           ),
//         ],
//       );
//     },
//   );
// }

// Widget _buildSubjectList(CBTProvider provider) {
//   return SliverList(
//     delegate: SliverChildBuilderDelegate(
//       (context, index) {
//         if (provider.isLoading) {
//           return _buildChooseSubjectCard(
//             subject: 'Subject Name',
//             year: 'Year Range',
//             cardColor: AppColors.cbtCardColor1,
//             subjectIcon: 'default',
//           );
//         }
//         final subject = provider.currentBoardSubjects[index];
//         return _buildChooseSubjectCard(
//           subject: subject.name,
//           year: subject.years != null && subject.years!.isNotEmpty
//               ? "${subject.years!.first.year}-${subject.years!.last.year}"
//               : "N/A",
//           cardColor: subject.cardColor ?? AppColors.cbtCardColor1,
//           subjectIcon: subject.subjectIcon ?? 'default',
//         );
//       },
//       childCount: provider.isLoading
//           ? 10
//           : provider
//               .currentBoardSubjects.length, // Increased to 10 placeholder items
//     ),
//   );
// }

// Widget _buildPerformanceCard({
//   required String title,
//   required String completionRate,
//   required String imagePath,
//   required Color backgroundColor,
//   required Color borderColor,
// }) {
//   return Expanded(
//     child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
//       height: 130.0,
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(8.0),
//         border: Border.all(color: borderColor),
//         boxShadow: [
//           BoxShadow(
//             spreadRadius: 0,
//             offset: const Offset(0, 1),
//             blurRadius: 2,
//             color: Colors.black.withOpacity(0.25),
//           )
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Image.asset(
//             imagePath,
//             width: 24.0,
//             height: 24.0,
//           ),
//           const SizedBox(height: 4.0),
//           Text(
//             completionRate,
//             style: AppTextStyles.normal600(
//               fontSize: 24.0,
//               color: AppColors.backgroundLight,
//             ),
//           ),
//           const SizedBox(height: 4.0),
//           Text(
//             title,
//             style: AppTextStyles.normal600(
//               fontSize: 16.0,
//               color: AppColors.backgroundLight,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// Widget _buildHistoryCard({
//   required String courseName,
//   required String year,
//   required double progressValue,
//   required Color borderColor,
// }) {
//   return Container(
//     width: 195,
//     margin: const EdgeInsets.only(left: 16.0),
//     padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//     decoration: BoxDecoration(
//       color: AppColors.backgroundLight,
//       borderRadius: BorderRadius.circular(4.0),
//       border: Border.all(color: borderColor),
//     ),
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Stack(
//           alignment: Alignment.center,
//           children: [
//             SizedBox(
//               height: 70.0,
//               width: 70.0,
//               child: CircularProgressIndicator(
//                 color: borderColor,
//                 value: progressValue,
//                 strokeWidth: 7.5,
//               ),
//             ),
//             Text(
//               '${(progressValue * 100).round()}%',
//               style: AppTextStyles.normal600(
//                 fontSize: 16.0,
//                 color: AppColors.text4Light,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(width: 10.0),
//         Expanded(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 courseName,
//                 style: AppTextStyles.normal600(
//                   fontSize: 16.0,
//                   color: AppColors.text4Light,
//                 ),
//               ),
//               const SizedBox(height: 4.0),
//               Text(
//                 '($year)',
//                 style: AppTextStyles.normal600(
//                   fontSize: 12.0,
//                   color: AppColors.text7Light,
//                 ),
//               ),
//               const SizedBox(height: 4.0),
//               Text(
//                 'Tap to retake',
//                 style: AppTextStyles.normal600(
//                   fontSize: 14.0,
//                   color: AppColors.text8Light,
//                 ),
//               ),
//             ],
//           ),
//         )
//       ],
//     ),
//   );
// }


// Widget _buildChooseSubjectCard({
//   required String subject,
//   required String year,
//   required Color cardColor,
//   required String subjectIcon,
// }) {
//   return Consumer<CBTProvider>(
//     builder: (context, provider, child) {
//       final years = provider.getYearsForSubject(subject);
//       final yearDisplay =
//           years.isNotEmpty ? "${years.first}-${years.last}" : "N/A";
    
//       return GestureDetector(
//         onTap: () {
//           // Get YearModel objects (includes both year and exam_id)
//          //// final yearModels = provider.getYearModelsForSubject(subject);
//          // print("Year Models for $subject: ${yearModels.map((y) => '${y.year} (ID: ${y.id})').join(', ')}");  
//           // if (yearModels.isNotEmpty) {
//           //   // // Find the subject model to get the correct subject ID
//           //   // final subjectModel = provider.currentBoardSubjects.firstWhere(
//           //   //   (s) => s.name == subject,
//           //   //   orElse: () => provider.currentBoardSubjects.first,
//           //   // );

//           //   // YearPickerDialog.show(
//           //   //   context,
//           //   //   examTypeId: provider.selectedBoard?.id ?? '',
//           //   //   title: 'Choose Year for $subject',
//           //   //   startYear: int.parse(years.first),

//           //   //   numberOfYears: yearModels.length,
//           //   //   yearModels: yearModels,
//           //   //    // Pass YearModel list (includes exam_id!)
//           //   //   subject: subject,
//           //   //   subjectIcon: provider.getSubjectIcon(subject),
//           //   //   cardColor: provider.getSubjectColor(subject),
//           //   //   subjectList: provider.getOtherSubjects(subject),
//           //   //   subjectId: subjectModel.id,
//           //   // );
            
//           // } else {
//           //   ScaffoldMessenger.of(context).showSnackBar(
//           //     SnackBar(
//           //       content: Text('No years available for $subject'),
//           //       duration: const Duration(seconds: 2),
//           //       backgroundColor: AppColors.cbtColor1,
//           //     ),
//           //   );
//           // }
//         },
//         child: Container(
//           width: double.infinity,
//           height: 70,
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
//           decoration: const BoxDecoration(
//             border: Border(top: BorderSide(color: AppColors.cbtColor5)),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 60,
//                 decoration: BoxDecoration(
//                   color: cardColor,
//                   borderRadius: BorderRadius.circular(4.0),
//                 ),
//                 child: Center(
//                   child: Image.asset(
//                     'assets/icons/$subjectIcon.png',
//                     width: 24.0,
//                     height: 24.0,
//                     errorBuilder: (context, error, stackTrace) =>
//                         const Icon(Icons.error),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10.0),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       subject,
//                       style: AppTextStyles.normal600(
//                         fontSize: 16.0,
//                         color: AppColors.backgroundDark,
//                       ),
//                     ),
//                     const SizedBox(height: 8.0),
//                     Text(
//                       yearDisplay,
//                       style: AppTextStyles.normal600(
//                         fontSize: 12.0,
//                         color: AppColors.text9Light,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
