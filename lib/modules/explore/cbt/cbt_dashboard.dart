import 'package:flutter/material.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../common/text_styles.dart';
import '../../common/app_colors.dart';
import '../../common/constants.dart';
import '../components/year_picker_dialog.dart';
import '../ebooks/books_button_item.dart';

class CBTDashboard extends StatefulWidget {
  /// Whether to show the AppBar. Defaults to true.
  final bool showAppBar;

  const CBTDashboard({super.key, this.showAppBar = true});

  @override
  State<CBTDashboard> createState() => _CBTDashboardState();
}

class _CBTDashboardState extends State<CBTDashboard> {
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
    return Scaffold(
      appBar: widget.showAppBar
          ? Constants.customAppBar(context: context, showBackButton: true)
          : null,
      body: Consumer<CBTProvider>(
        builder: (context, provider, child) {
          return Skeletonizer(
            enabled: provider.isLoading,
            child: Container(
              decoration: Constants.customBoxDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  _buildCBTCategories(provider),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      provider.selectedBoard?.title ?? 'Board Title',
                      style: AppTextStyles.normal600(
                        fontSize: 22.0,
                        color: AppColors.text4Light,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildPerformanceMetrics(),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
                        SliverToBoxAdapter(
                          child: _buildTestHistory(),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
                        SliverToBoxAdapter(
                          child: Constants.headingWithSeeAll600(
                            title: 'Choose subject',
                            titleSize: 18.0,
                            titleColor: AppColors.text4Light,
                          ),
                        ),
                        _buildSubjectList(provider),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
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
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPerformanceCard(
          imagePath: 'assets/icons/test.png',
          title: 'Tests',
          completionRate: '123',
          backgroundColor: AppColors.cbtColor1,
          borderColor: AppColors.cbtBorderColor1,
        ),
        const SizedBox(width: 16.0),
        _buildPerformanceCard(
          imagePath: 'assets/icons/success.png',
          title: 'Success',
          completionRate: '123%',
          backgroundColor: AppColors.cbtColor2,
          borderColor: AppColors.cbtBorderColor2,
        ),
        const SizedBox(width: 16.0),
        _buildPerformanceCard(
          imagePath: 'assets/icons/average.png',
          title: 'Average',
          completionRate: '123%',
          backgroundColor: AppColors.cbtColor3,
          borderColor: AppColors.cbtBorderColor3,
        ),
      ],
    ),
  );
}

Widget _buildTestHistory() {
  return Consumer<CBTProvider>(
    builder: (context, provider, child) {
      // Generate sample history based on available subjects
      final recentSubjects = provider.currentBoardSubjects.take(3).toList();
      
      if (recentSubjects.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Constants.headingWithSeeAll600(
              title: 'Test history',
              titleSize: 18.0,
              titleColor: AppColors.text4Light,
            ),
            const SizedBox(height: 100),
          ],
        );
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Constants.headingWithSeeAll600(
            title: 'Test history',
            titleSize: 18.0,
            titleColor: AppColors.text4Light,
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 16.0),
              itemCount: recentSubjects.length,
              itemBuilder: (context, index) {
                final subject = recentSubjects[index];
                final latestYear = subject.years?.isNotEmpty == true 
                    ? subject.years!.last.year 
                    : '2024';
                final colors = [
                  AppColors.cbtColor3,
                  AppColors.cbtColor4,
                  AppColors.cbtColor1,
                ];
                final progressValues = [0.75, 0.60, 0.45]; // Sample progress values
                
                return _buildHistoryCard(
                  courseName: subject.name,
                  year: latestYear,
                  progressValue: progressValues[index % progressValues.length],
                  borderColor: colors[index % colors.length],
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
          : provider
              .currentBoardSubjects.length, // Increased to 10 placeholder items
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
  required String courseName,
  required String year,
  required double progressValue,
  required Color borderColor,
}) {
  return Container(
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
  );
}

Widget _buildChooseSubjectCard({
  required String subject,
  required String year,
  required Color cardColor,
  required String subjectIcon,
}) {
  return Consumer<CBTProvider>(
    builder: (context, provider, child) {
      final years = provider.getYearsForSubject(subject);
      final yearDisplay =
          years.isNotEmpty ? "${years.first}-${years.last}" : "N/A";

      return GestureDetector(
        onTap: () {
          if (years.isNotEmpty) {
            final yearsList = years
                .map((y) => int.tryParse(y))
                .whereType<int>()
                .toList()
              ..sort((a, b) => b.compareTo(a));

            YearPickerDialog.show(
              context,
              examTypeId: provider.selectedBoard?.id ?? '',
              title: 'Choose Year for ${subject}',
              startYear: yearsList.first,
              numberOfYears: yearsList.length,
              subject: subject,
              subjectIcon: provider.getSubjectIcon(subject),
              cardColor: provider.getSubjectColor(subject),
              subjectList: provider.getOtherSubjects(subject),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No years available for $subject'),
                duration: const Duration(seconds: 2),
                backgroundColor: AppColors.cbtColor1,
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
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
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
                      style: AppTextStyles.normal600(
                        fontSize: 16.0,
                        color: AppColors.backgroundDark,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      yearDisplay,
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
