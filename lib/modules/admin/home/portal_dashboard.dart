import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/admin/admin_settings.dart';
import 'package:linkschool/modules/admin/e_learning/e_learning_dashboard_screen.dart';
import 'package:linkschool/modules/admin/home/portal_home.dart';
import 'package:linkschool/modules/admin/payment/payment_dashboard_screen.dart';
import 'package:linkschool/modules/admin/result/result_dashboard_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/flat_bottom_navigation.dart';
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
        bottom: false,
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
      body: _buildBodyItem(
          _selectedIndex, context), // Pass context to _buildBodyItem
      bottomNavigationBar: FlatBottomNavigation(
        items: [
          // NavigationItem(
          //   iconPath: 'assets/icons/home.svg',
          //   activeIconPath: 'assets/icons/home_fill.svg',
          //   label: 'Home',
          // ),

           NavigationItem(
            iconPath: 'assets/icons/home.svg',
            activeIconPath: 'assets/icons/fill_home.svg',
            label: 'Home',
           
          ),
          // NavigationItem(
          //   iconPath: 'assets/icons/result.svg',
          //   label: 'Results',
          // ),
            NavigationItem(
              iconPath: 'assets/icons/two_pager.svg',
              activeIconPath: 'assets/icons/two_pager_fill.svg',
              label: 'Result',
              
            ),
          NavigationItem(
            iconPath: 'assets/icons/portal.svg',
            label: 'Explore',
                iconWidth: 24.0,
        iconHeight: 25.0,
        flipIcon: true,
            color: const Color(0xFF1E3A8A),
          ),
          // NavigationItem(
          //   iconPath: 'assets/icons/e-learning.svg',
          //   label: 'E-learning',
          // ),
            NavigationItem(
              iconPath: 'assets/icons/globe_book.svg',
              activeIconPath: 'assets/icons/globe_book.svg',
              label: 'E-learning',
              
            ),
          NavigationItem(
            iconPath: 'assets/icons/profile.svg',
                activeIconPath: 'assets/icons/person_fill.svg',
            label: 'Payment',
          ),
        ],
        // Map body index to navigation slot (Explore occupies center index 2)
        selectedIndex: _selectedIndex >= 2 ? _selectedIndex + 1 : _selectedIndex,
        onTabSelected: (index) {
          // Explore slot - switch back to Explore dashboard
          if (index == 2) {
            widget.onSwitch(false);
            return;
          }

          // Adjust index for body items (skip Explore slot)
          final adjustedIndex = index > 2 ? index - 1 : index;
          setState(() {
            _selectedIndex = adjustedIndex;
          });
          widget.onTabSelected(adjustedIndex);
        },
      ),
    );
  }
}
