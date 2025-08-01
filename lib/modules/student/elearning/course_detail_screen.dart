import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/model/student/dashboard_model.dart';
import 'package:linkschool/modules/model/student/elearningcontent_model.dart';
import 'package:linkschool/modules/student/elearning/course_content_screen.dart';
import 'package:linkschool/modules/student/elearning/forum_screen.dart';

class CourseDetailScreen extends StatefulWidget {

  final String courseTitle;
  final DashboardData dashboardData;

  const CourseDetailScreen({super.key, required this.courseTitle , required this.dashboardData});

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {

  int _selectedIndex = 0;
  late double opacity;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> _screens = [
      CourseContentScreen(dashboardData:widget.dashboardData,courseTitle:widget.courseTitle),
      ForumScreen(),
    ];

    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.paymentTxtColor1,
            width: 34.0,
            height: 34.0,
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
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {},
              icon: SvgPicture.asset(
                'assets/icons/notifications.svg',
                colorFilter:
                    const ColorFilter.mode(AppColors.paymentTxtColor1, BlendMode.srcIn),
              ),
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
            icon: SvgPicture.asset('assets/icons/student/coursework_icon.svg',
                height: 20), // Replace with actual SVG path
            label: 'Coursework',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/student/forum_icon.svg',
                height: 20), // Replace with actual SVG path
            label: 'Forum',
          ),
        ],
        selectedItemColor: AppColors.paymentTxtColor1,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
