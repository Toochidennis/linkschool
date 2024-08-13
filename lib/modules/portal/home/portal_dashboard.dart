import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/portal/home/result/result_dashboard_screen.dart';
// import 'package:linkschool/modules/portal/result/result_dashboard_screen.dart';

import '../../common/text_styles.dart';
import '../../../modules/portal/home/portal_home.dart';
import '../../common/bottom_nav_item.dart';
import '../../common/bottom_navigation_bar.dart';

class PortalDashboard extends StatefulWidget {
  final Function(bool) onSwitch;

  const PortalDashboard({super.key, required this.onSwitch});

  @override
  State<PortalDashboard> createState() => _PortalDashboardState();
}

class _PortalDashboardState extends State<PortalDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey(false),
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: 'Welcome, ', style: AppTextStyles.italic2Light),
              TextSpan(text: 'ToochiDennis', style: AppTextStyles.italic3Light)
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/icons/notifications.svg',
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
        elevation: 0,
      ),
      body: CustomNavigationBar(
        actionButtonImagePath: 'assets/icons/explore.svg',
        appBarItems: [
          createBottomNavIcon(
            imagePath: 'assets/icons/home.svg',
            text: 'Home',
            width: 20.0,
            height: 20.0,
          ),
          createBottomNavIcon(
            imagePath: 'assets/icons/result.svg',
            text: 'Results',
            width: 18.0,
            height: 18.0,
          ),
          createBottomNavIcon(
            imagePath: 'assets/icons/e-learning.svg',
            text: 'E-learning',
            width: 18.0,
            height: 18.0,
            
          ),
          createBottomNavIcon(
            imagePath: 'assets/icons/profile.svg',
            text: 'Profile',
          ),
        ],
        bodyItems: [
          const PortalHome(),
          const ResultDashboardScreen(),
          Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.blue,
          )
        ],
        onSwitch: widget.onSwitch,
      ),
    );
  }
}
