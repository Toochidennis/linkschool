import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
import 'package:linkschool/modules/explore/home/custom_button_item.dart';
import 'package:linkschool/modules/staff_portal/home/form_classes_screen.dart';
import 'package:linkschool/modules/staff_portal/home/staff_course_screen.dart';
import 'package:linkschool/modules/student_portal/home/feed_details_screen.dart';
import 'package:linkschool/modules/student_portal/home/new_post_dialog.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  final PageController _pageController = PageController(
    viewportFraction: 0.90,
  );
  Timer? _timer;
  int _currentPage = 0;
  late double opacity;
  String profileImageUrl =
      'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86';

  final List<Map<String, String>> notifications = [
    {
      'name': 'Dennis Toochi',
      'message': 'posted an Qsts on Homeostasis for JSS2',
      'time': 'Yesterday at 9:42 AM',
      'avatar': 'assets/images/student/avatar1.svg',
    },
    {
      'name': 'Ifeanyi Joseph',
      'message': 'posted new course materials for SSS3',
      'time': 'Today at 8:30 AM',
      'avatar': 'assets/images/student/avatar2.svg',
    },
    {
      'name': 'Sarah Okoro',
      'message': 'scheduled a class meeting for Mathematics',
      'time': 'Just now',
      'avatar': 'assets/images/student/avatar3.svg',
    },
  ];

  List<String> feedCardNames = ['John Dennis', 'Jane Emaka', 'Bob John'];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < notifications.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  void _showNewPostDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const NewPostDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: CustomStudentAppBar(
        title: 'Welcome',
        subtitle: 'Tochukwu',
        showNotification: true,
        // showPostInput: true,
        onNotificationTap: () {},
        // onPostTap: _showNewPostDialog,
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 120.0),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  SizedBox(
                    height: 140,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: notifications.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double scale = 1.0;
                            if (_pageController.position.haveDimensions) {
                              num pageOffset =
                                  _pageController.page ?? _currentPage;
                              scale = (1 - ((pageOffset - index).abs() * 0.2))
                                  .clamp(0.8, 1.0);
                            }
                            return Transform.scale(
                              scale: scale,
                              child: _buildNotificationCard(
                                notifications[index]['name']!,
                                notifications[index]['message']!,
                                notifications[index]['time']!,
                                notifications[index]['avatar']!,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),
                  // Add dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      notifications.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? AppColors.eLearningBtnColor1
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('You can...',
                      style: AppTextStyles.normal600(
                          fontSize: 20, color: AppColors.primaryLight)),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: CustomButtonItem(
                          backgroundColor: AppColors.studentCtnColor3,
                          borderColor: AppColors.portalButton1BorderLight,
                          textColor: AppColors.staffTxtColor1,
                          label: 'Form Classes',
                          number: 5, 
                          iconPath: 'assets/icons/student/knowledge_icon.svg',
                          iconHeight: 40.0,
                          iconWidth: 36.0,
                          destination:  FormClassesScreen(), 
                        ),
                      ),
                      const SizedBox(width: 14.0),
                      Expanded(
                        child: CustomButtonItem(
                          backgroundColor: AppColors.staffCtnColor1,
                          borderColor: AppColors.secondaryLight,
                          textColor: AppColors.staffTxtColor2,
                          label: 'Courses',
                          number: 3,
                          iconPath: 'assets/icons/student/study_icon.svg',
                          iconHeight: 40.0,
                          iconWidth: 36.0,
                          destination: null, 
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Feed',
                        style: AppTextStyles.normal600(
                            fontSize: 20, color: AppColors.primaryLight),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            decoration:
                                TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    child: _buildFeedCard(
                        'This is a mock data showing the info details of a recording.',
                        '30 minutes ago',
                        14,
                        0),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    child: _buildFeedCard(
                        'This is a mock data showing the info details of a recording.',
                        '45 minutes ago',
                        18,
                        1),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    child: _buildFeedCard(
                        'This is a mock data showing the info details of a recording.',
                        '1 hour ago',
                        22,
                        2),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton(
                  onPressed: () {},
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
      String name, String message, String time, String avatarPath) {
    return Card(
      elevation: 2,
      child: Container(
        // width: 300,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(profileImageUrl),
              radius: 16.0,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTextStyles.normal500(
                          fontSize: 16, color: AppColors.studentTxtColor2)),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(time,
                      style: AppTextStyles.normal500(
                          fontSize: 16, color: AppColors.text5Light)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionContainer(String text, String iconPath, Color bgColor) {
    // Split the text if it contains a space
    List<String> textParts = text.split(' ');

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: bgColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 50,
            height: 50,
          ),
          const SizedBox(height: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: textParts
                .map((part) => Text(
                      part,
                      style: AppTextStyles.normal500(
                        fontSize: 14,
                        color: text == 'Results'
                            ? AppColors.studentTxtColor1
                            : AppColors.paymentTxtColor2,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedCard(
      String content, String time, int interactions, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeedDetailsScreen(
                name: feedCardNames[index],
                content: content,
                time: time,
                interactions: interactions,
                profileImageUrl: profileImageUrl),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.only(
          top: 16.0,
          bottom: 16.0,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: AppColors.newsBorderColor,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(profileImageUrl),
                        radius: 16.0,
                      ),
                      const SizedBox(width: 8),
                      Text(feedCardNames[index],
                          style: AppTextStyles.normal500(
                              fontSize: 16, color: AppColors.primaryLight)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(content),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_outline),
                        onPressed: () {},
                      ),
                      Text(
                        '$interactions',
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/comment.svg',
                          height: 20.0,
                          width: 20.0,
                        ),
                        onPressed: () {},
                      ),
                      Text(
                        '$interactions',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(time,
                style: AppTextStyles.normal500(
                    fontSize: 12, color: AppColors.primaryLight)),
          ],
        ),
      ),
    );
  }
}