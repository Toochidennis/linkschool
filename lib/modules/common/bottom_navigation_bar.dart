import 'package:curved_nav_bar/curved_bar/curved_action_bar.dart';
import 'package:curved_nav_bar/fab_bar/fab_bottom_app_bar_item.dart';
import 'package:curved_nav_bar/flutter_curved_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'app_colors.dart';

class CustomNavigationBar extends StatefulWidget {
  final Function(bool) onSwitch;
  final String actionButtonImagePath;
  final List<FABBottomAppBarItem> appBarItems;
  final List<Widget> bodyItems;

  const CustomNavigationBar({
    super.key,
    required this.actionButtonImagePath,
    required this.appBarItems,
    required this.bodyItems,
    required this.onSwitch,
  });

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar>
    with WidgetsBindingObserver {
  Brightness? brightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateBrightness();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    _updateBrightness();
  }

  void _updateBrightness() {
    setState(() {
      brightness = WidgetsBinding.instance.window.platformBrightness;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        Expanded(
          child: CurvedNavBar(
            actionButton: CurvedActionBar(
              onTab: widget.onSwitch,
              activeIcon: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondaryLight,
                    width: 1.0,
                  ),
                ),
                child: SvgPicture.asset(
                  widget.actionButtonImagePath,
                ),
              ),
              inActiveIcon: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondaryLight,
                    width: 1.0,
                  ),
                ),
                child: SvgPicture.asset(
                  widget.actionButtonImagePath,
                ),
              ),
            ),
            activeColor: AppColors.secondaryLight,
            inActiveColor: AppColors.primaryLight,
            navBarBackgroundColor: brightness == Brightness.light
                ? AppColors.backgroundLight
                : AppColors.backgroundDark,
            appBarItems: widget.appBarItems,
            bodyItems: widget.bodyItems,
          ),
        ),
      ],
    ));
  }
}
