import 'dart:math';

import 'package:flutter/material.dart';
import 'package:linkschool/ui/dashboard/explore/explore_dashboard.dart';
import 'package:linkschool/ui/dashboard/portal/portal_dashboard.dart';

class DashboardSwitcher extends StatefulWidget {
  const DashboardSwitcher({super.key});

  @override
  State<DashboardSwitcher> createState() => _DashboardSwitcherState();
}

class _DashboardSwitcherState extends State<DashboardSwitcher> {
  bool showPortal = true;

  void switchDashboard() {
    print('Switched to: ${showPortal ? 'Explore' : 'Portal'} dashboard');
    setState(() {
      showPortal = !showPortal;
      print('Switched to: ${showPortal ? 'Explore' : 'Portal'} dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 4600),
        layoutBuilder: (widget, list) => Stack(
          children: [widget!, ...list],
        ),
        switchInCurve: Curves.easeInBack,
        switchOutCurve: Curves.easeInBack.flipped,
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotateAnimation =
              Tween(begin: 3.1416, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotateAnimation,
            child: child,
            builder: (context, child) {
              final isUnder = (ValueKey(showPortal) != child!.key);
              final value = isUnder
                  ? min(rotateAnimation.value, 3.1416 / 2)
                  : rotateAnimation.value;
              var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
              tilt *= isUnder ? -1.0 : 1.0;
              return Transform(
                transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        child: showPortal
            ? ExploreDashboard(

                onSwitch: switchDashboard,
              )
            : PortalDashboard(
                key: const ValueKey(false),
                onSwitch: switchDashboard,
              ),
      ),
    );
  }
}
