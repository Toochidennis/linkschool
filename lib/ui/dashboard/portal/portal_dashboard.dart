import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/common/text_styles.dart';

import '../common/bottom_nav_item.dart';
import '../common/common/bottom_navigation_bar.dart';

class PortalDashboard extends StatefulWidget {
  final VoidCallback onSwitch;

  const PortalDashboard({super.key, required this.onSwitch});

  @override
  State<PortalDashboard> createState() => _PortalDashboardState();
}

class _PortalDashboardState extends State<PortalDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
            text: const TextSpan(children: [
          TextSpan(text: 'Welcome, ', style: AppTextStyles.italic2Light),
          TextSpan(text: 'ToochiDennis', style: AppTextStyles.italic3Light)
        ])),
        actions: [
          IconButton(
            onPressed:widget.onSwitch,
            icon: SvgPicture.asset(
              'assets/icons/notifications.svg',
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          )
        ],
        elevation: 0,
      ),
      body: CustomNavigationBar(
        actionButtonImagePath: 'assets/icons/explore.svg',
        appBarItems: [
          createBottomNavIcon(
            imagePath: 'assets/icons/home.svg',
            text: 'Home',
          ),
          createBottomNavIcon(
            imagePath: 'assets/icons/result.svg',
            text: 'Results',
          ),
          createBottomNavIcon(
            imagePath: 'assets/icons/e-learning.svg',
            text: 'E-learning',
            width: 24.0,
            height: 25.0,
          ),
          createBottomNavIcon(
            imagePath: 'assets/icons/profile.svg',
            text: 'Profile',
          ),
        ],
        bodyItems: [
          Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.orange,
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.orange,
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.blue,
          )
        ],
        onSwitch: () => widget.onSwitch,
      ),
    );
  }
}
