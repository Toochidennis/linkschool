import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/admin/admin_settings.dart';
import 'package:linkschool/modules/admin/e_learning/e_learning_dashboard_screen.dart';
import 'package:linkschool/modules/admin/home/portal_home.dart';
import 'package:linkschool/modules/admin/payment/payment_dashboard_screen.dart';
import 'package:linkschool/modules/admin/result/result_dashboard_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/bottom_nav_item.dart';
import 'package:linkschool/modules/common/bottom_navigation_bar.dart';
import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart'; // Import the AuthProvider

class PortalDashboard extends StatefulWidget {
  final Function(bool) onSwitch;
  final int selectedIndex;
  final Function(int) onTabSelected;
  final VoidCallback onLogout;

  const PortalDashboard({
    super.key,
    required this.onSwitch,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onLogout,
  });

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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userName =
        authProvider.user?.name ?? 'Guest'; // Use the logged-in user's name

    final name = userName.trim().split(' ');
    final firstName = name.isNotEmpty ? name.first : 'User';
    print("First name: $firstName");

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 18),
      child: SafeArea(
        child: AppBar(
          toolbarHeight: kToolbarHeight + 18,
          backgroundColor: AppColors.paymentTxtColor1,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 32.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Welcome, ',
                    style: AppTextStyles.italic2Light,
                  ),
                  TextSpan(
                    text: userName.trim().split(' ').last,
                    style: AppTextStyles.italic3Light,
                  ),
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

  Widget _buildBodyItem(int index, BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userName =
        authProvider.user?.name ?? 'Guest'; // Use the logged-in user's name
    final name = userName.trim().split(' ');
    final firstName = name.isNotEmpty ? name.first : 'User';
    print("First name: $firstName");

    switch (index) {
      case 0:
        return PortalHome(
          appBar: CustomStudentAppBar(
            title: 'Welcome',
            subtitle: firstName,
            showSettings: true,
            onSettingsTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      AdminSettingsScreen(onLogout: widget.onLogout),
                ),
              );
            },
          ),
          onLogout: widget.onLogout,
        );
      case 1:
        return ResultDashboardScreen(
          appBar: CustomStudentAppBar(
            title: 'Welcome',
            subtitle: firstName,
            showNotification: false,
            onNotificationTap: () {},
          ),
        );
      case 2:
        return ELearningDashboardScreen(
          appBar: CustomStudentAppBar(
            title: 'Welcome',
            subtitle: firstName,
            showNotification: false,
            onNotificationTap: () {},
          ),
        );
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
      appBar: _buildAppBar(context),
      body: _buildBodyItem(
          _selectedIndex, context), // Pass context to _buildBodyItem
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
        bodyItems: List.generate(
            4, (index) => _buildBodyItem(index, context)), // Pass context
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
