import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../common/bottom_navigation_bar.dart';

import '../../common/bottom_nav_item.dart';
import 'explore_home.dart';

class ExploreDashboard extends StatefulWidget {
  final Function(bool) onSwitch;

  const ExploreDashboard({super.key, required this.onSwitch});

  @override
  State<ExploreDashboard> createState() => _ExploreDashboardState();
}

class _ExploreDashboardState extends State<ExploreDashboard> {
  bool _showSearchIcon = false;

  void _onSearchIconVisibilityChanged(bool isVisible) {
    setState(() {
      _showSearchIcon = isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey(true),
      appBar: AppBar(
        title: SvgPicture.asset('assets/icons/linkskool-logo.svg'),
        actions: [
          if (!_showSearchIcon)
            IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                // Handle search action
              },
            ),
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
            text: 'E-library',
            width: 24.0,
            height: 25.0,
          ),
          createBottomNavIcon(
            imagePath: 'assets/icons/settings.svg',
            text: 'Settings',
          ),
        ],
        bodyItems: [
          ExploreHome(
              onSearchIconVisibilityChanged: _onSearchIconVisibilityChanged),
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
        onSwitch: widget.onSwitch,
      ),
    );
  }
}
