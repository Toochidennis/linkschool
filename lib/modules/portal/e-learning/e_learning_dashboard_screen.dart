import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/result_dashboard/level_selection.dart';

class ELearningScreen extends StatefulWidget {
  const ELearningScreen({Key? key}) : super(key: key);

  @override
  State<ELearningScreen> createState() => _ELearningScreenState();
}

class _ELearningScreenState extends State<ELearningScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      } else {
        // Set to the first page with an instant jump and then smooth scroll to the first page
        _pageController.jumpToPage(0);
        _currentPage = 1; // Prepare for the next animation
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildTopContainers(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24.0)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              sliver: SliverToBoxAdapter(
                child: _buildRecentActivity(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24.0)),
            SliverToBoxAdapter(
              child: Constants.heading600(
                title: 'Select Level',
                titleSize: 18.0,
                titleColor: AppColors.resultColor1,
              ),
            ),
            const SliverToBoxAdapter(
              child: const LevelSelection(
                  isSecondScreen: true,
                  subjects: ['Civic Education', 'Mathematics', 'English', 'Physics', 'Chemistry'],

              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopContainers() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              _buildTopContainer(
                date: '19TH FEBRUARY 2024',
                title: 'First Continuous Assessment',
                subject: 'Mathematics',
                classes: 'JSS1, JSS2, JSS3',
              ),
              _buildTopContainer(
                date: '22ND FEBRUARY 2024',
                title: 'Second Continuous Assessment',
                subject: 'English Language',
                classes: 'JSS1, JSS2',
              ),
              _buildTopContainer(
                date: '25TH FEBRUARY 2024',
                title: 'Final Examination',
                subject: 'Basic Science',
                classes: 'JSS3',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) => _buildDot(index)),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 12 : 8,
      height: isActive ? 12 : 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.orange : Colors.grey.withOpacity(0.3),
      ),
    );
  }

  Widget _buildTopContainer({
    required String date,
    required String title,
    required String subject,
    required String classes,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: AppTextStyles.normal500(fontSize: 14, color: AppColors.backgroundLight)),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.normal700(fontSize: 22, color: AppColors.backgroundLight)),
          const SizedBox(height: 4),
          Text('Subject: $subject', style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundLight)),
          const SizedBox(height: 4),
          Text('For: $classes', style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundLight)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Recent activity', style: AppTextStyles.normal600(fontSize: 18, color: AppColors.backgroundDark)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 16 : 8, right: 8, bottom: 8),
                child: _buildActivityCard(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(int index) {
    final List<Map<String, String>> cardData = [
      {'day': 'Yesterday', 'topic': 'Homeostasis', 'teacher': 'Dennis Toochi', 'subject': 'Basic Science', 'class': 'JSS2'},
      {'day': 'Today', 'topic': 'Photosynthesis', 'teacher': 'Joy Smith', 'subject': 'Biology', 'class': 'JSS3'},
    ];

    final data = cardData[index % cardData.length];

    return Container(
      width: 265,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/e_learning/subject.svg', // Replace with actual icon
                  width: 48,
                  height: 48,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(data['day']!, style: AppTextStyles.normal500(fontSize: 14, color: AppColors.backgroundDark)),
                  Text(data['topic']!, style: AppTextStyles.normal600(fontSize: 18, color: AppColors.primaryLight)),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${data['teacher']} • ${data['subject']} • ${data['class']}',
                          style: AppTextStyles.normal500(fontSize: 14, color: AppColors.textGray),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
