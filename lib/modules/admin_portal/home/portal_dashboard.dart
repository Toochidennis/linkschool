import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/admin_portal/e_learning/e_learning_dashboard_screen.dart';
import 'package:linkschool/modules/admin_portal/result/result_dashboard_screen.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/admin_portal/home/portal_home.dart';
import 'package:linkschool/modules/common/bottom_nav_item.dart';
import 'package:linkschool/modules/common/bottom_navigation_bar.dart';
import 'package:linkschool/modules/admin_portal/profile/payment_dashboard_screen.dart';

class PortalDashboard extends StatefulWidget {
  final Function(bool) onSwitch;
  final int selectedIndex;
  final Function(int) onTabSelected;
  final VoidCallback onLogout;

  const PortalDashboard({
    Key? key,
    required this.onSwitch,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<PortalDashboard> createState() => _PortalDashboardState();
}

class _PortalDashboardState extends State<PortalDashboard> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
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

  Widget _buildBodyItem(int index) {
    switch (index) {
      case 0:
        return PortalHome(appBar: _buildAppBar());
      case 1:
        return ResultDashboardScreen(appBar: _buildAppBar());
      case 2:
        return ELearningScreen(appBar: _buildAppBar());
      case 3:
        return PaymentDashboardScreen(onLogout: widget.onLogout);
      default:
        return Container();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('portal_dashboard'),
      body: _buildBodyItem(_selectedIndex),
      bottomNavigationBar: CustomNavigationBar(
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
          ),
          createBottomNavIcon(
            imagePath: 'assets/icons/profile.svg',
            text: 'Payment',
          ),
        ],
        bodyItems: List.generate(4, (index) => _buildBodyItem(index)),
        onTabSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          widget.onTabSelected(index);
        },
        onSwitch: widget.onSwitch,
        selectedIndex: _selectedIndex,
      ),
    );
  }
}