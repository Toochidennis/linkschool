import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/explore/courses/explore_courses.dart';
import 'package:linkschool/modules/explore/e_library/e_library_dashbord.dart';
import 'package:linkschool/modules/explore/explore_profile/explore_profileScreen.dart';
import 'package:linkschool/modules/explore/ai_chat/linkskool_ai_chat.dart';
import '../../common/flat_bottom_navigation.dart';
import 'explore_home.dart';

class ExploreDashboard extends StatefulWidget {
  final Function(bool) onSwitch;
  final int selectedIndex;
  final Function(int) onTabSelected;
  final bool isActive;

  const ExploreDashboard({
    super.key,
    required this.onSwitch,
    required this.selectedIndex,
    required this.onTabSelected,
    this.isActive = true,
  });

  @override
  State<ExploreDashboard> createState() => _ExploreDashboardState();
}

class _ExploreDashboardState extends State<ExploreDashboard> {
  bool _showSearchIcon = true; // Default to true

  late List<Widget> _bodyItems;

  //   @override
  // void initState() {
  //   super.initState();
  //   _initializeBodyItems();
  // }

  void _onSearchIconVisibilityChanged(bool isVisible) {
    setState(() {
      _showSearchIcon = isVisible;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeBodyItems();

    // Explicitly set search icon visibility based on selected index
    _updateSearchIconVisibility();
  }

  void _updateSearchIconVisibility() {
    // Hide search icon when Cart screen (index 3) is selected
    setState(() {
      _showSearchIcon = widget.selectedIndex != 3;
    });
  }

  void _initializeBodyItems() {
    _bodyItems = [
      ExploreHome(
        onSearchIconVisibilityChanged: _onSearchIconVisibilityChanged,
      ),

      ExploreCourses(allowProfilePrompt: widget.isActive),
      // ExploreAdmission(
      //   height: MediaQuery.of(context).size.height,
      // ),
      ElibraryDashboard(
        height: MediaQuery.of(context).size.height,
      ),
      ProfileScreen(
        height: MediaQuery.of(context).size.height,
        color: Colors.blue,
      ),
    ];
  }

  List<NavigationItem> _buildNavItems() {
    return [
      NavigationItem(
        iconPath: 'assets/icons/home.svg',
          activeIconPath: 'assets/icons/fill_home.svg',
        label: 'Home',
      ),
      // admission.svg
      NavigationItem(
        iconPath: 'assets/icons/laptop-binary.svg',
        activeIconPath: 'assets/icons/laptop-binary_fill.svg',
         iconWidth: 24.0,
        label: 'Programs',
      ),
      NavigationItem(
        iconPath: 'assets/icons/portal.svg',
        iconWidth: 24.0,
        iconHeight: 25.0,
    
        color: const Color(0xFF1E3A8A), // Blue color for portal
        label: 'Portal',
      ),
      NavigationItem(
        iconPath: 'assets/icons/diary-bookmark-down.svg',
          activeIconPath: 'assets/icons/diary-bookmark-down_fill.svg',
        label: 'E-library',
        iconWidth: 24.0,
        iconHeight: 25.0,
      ),
      NavigationItem(
        iconPath: 'assets/icons/settings.svg',
        activeIconPath: 'assets/icons/settings_fill.svg',
        label: 'Settings',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Ensure search icon visibility is updated when the widget rebuilds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSearchIconVisibility();
    });

    return Scaffold(
      key: const ValueKey('explore_dashboard'),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.paymentTxtColor1,
        title: SvgPicture.asset('assets/icons/linkskool-logo.svg'),
        actions: [
          // AI Chat Icon
          IconButton(
            icon: const Icon(Icons.smart_toy, color: Colors.white),
            tooltip: 'LinkSkool AI Chat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LinkSkoolAIChatPage(),
                ),
              );
            },
          ),
          
           
        ],
        elevation: 0,
      ),
      body: _bodyItems[widget.selectedIndex],
      bottomNavigationBar: FlatBottomNavigation(
        items: _buildNavItems(),
        // Convert body index to navigation index (account for portal at index 2)
        // Body indices: 0=Home, 1=Programs, 2=E-library, 3=Settings
        // Nav indices:  0=Home, 1=Programs, 2=Portal, 3=E-library, 4=Settings
        selectedIndex: widget.selectedIndex >= 2
            ? widget.selectedIndex + 1
            : widget.selectedIndex,
        onTabSelected: (index) {
          // Handle portal switch (index 2)
          if (index == 2) {
            widget.onSwitch(true);
          } else {
            // Adjust index for body items (skip portal index)
            final adjustedIndex = index > 2 ? index - 1 : index;
            widget.onTabSelected(adjustedIndex);
            _updateSearchIconVisibility();
          }
        },
      ),
    );
  }
}