import 'package:curved_nav_bar/fab_bar/fab_bottom_app_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/portal/e_learning/e_learning_dashboard_screen.dart';
import 'package:linkschool/modules/portal/profile/payment_dashboard_screen.dart';
import 'package:linkschool/modules/portal/result/result_dashboard_screen.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/portal/home/portal_home.dart';
import 'package:linkschool/modules/common/bottom_nav_item.dart';
import 'package:linkschool/modules/common/bottom_navigation_bar.dart';

class PortalDashboard extends StatefulWidget {
  final Function(bool) onSwitch;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const PortalDashboard({
    Key? key,
    required this.onSwitch,
    required this.selectedIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  State<PortalDashboard> createState() => _PortalDashboardState();
}


class _PortalDashboardState extends State<PortalDashboard> {
  late int _selectedIndex;
  late List<Widget> _screens;  // Declare _screens without initializing

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _initializeScreens();  // Initialize screens in initState
  }

  void _initializeScreens() {
    _screens = [
      PortalHome(appBar: _buildAppBar()),
      ResultDashboardScreen(appBar: _buildAppBar()),
      ELearningScreen(appBar: _buildAppBar()),
      PaymentDashboardScreen(),
    ];
  }

PreferredSizeWidget _buildAppBar() {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight + 16),
    child: SafeArea(
      child: AppBar(
        toolbarHeight: kToolbarHeight + 16,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 32.0),
          child: RichText(
            text: const TextSpan(
              children: [
                TextSpan(text: 'Welcome, ', style: AppTextStyles.italic2Light),
                TextSpan(text: 'ToochiDennis', style: AppTextStyles.italic3Light)
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 32.0),
            child: IconButton(
              onPressed: () {},
              icon: SvgPicture.asset(
                'assets/icons/notifications.svg',
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
        elevation: 0,
      ),
    ),
  );
}

  @override
  void didUpdateWidget(PortalDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = widget.selectedIndex;
      });
    }
  }

  final List<FABBottomAppBarItem> _navItems = [
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey(false),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomNavigationBar(
        actionButtonImagePath: 'assets/icons/explore.svg',
        appBarItems: _navItems,
        bodyItems: _screens,
        onSwitch: widget.onSwitch,
        onTabSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          widget.onTabSelected(index);
        },
      ),
    );
  }
}