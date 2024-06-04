import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/ui/dashboard/common/common/bottom_navigation_bar.dart';

import 'create_bottom_nar_icon.dart';

class ExploreDashboard extends StatefulWidget {
  const ExploreDashboard({super.key});

  @override
  State<ExploreDashboard> createState() => _ExploreDashboardState();
}

class _ExploreDashboardState extends State<ExploreDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/icons/linkskool-logo.svg',
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
          )
        ],
        elevation: 0,
      ),
      body: CustomNavigationBar(
        actionButtonImagePath: 'assets/icons/portal.svg',
        appBarItems: [
          createBottomNavIcon(
            imagePath: 'assets/icons/home.svg',
            text: 'Home',
          ),
          createBottomNavIcon(
            imagePath: 'assets/icons/admission.svg',
            text: 'Admission',
          ),
          createBottomNavIcon(
            imagePath: 'assets/icons/e-books.svg',
            text: 'E-books',
            width: 24.0,
            height: 25.0,
          ),
          createBottomNavIcon(
            imagePath: 'assets/icons/settings.svg',
            text: 'Settings',
          ),
        ],
        bodyItems: [
          Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.red,
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
      ),
    );
  }
}
