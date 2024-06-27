import 'dart:math';

import 'package:flutter/material.dart';
import '../explore/home/explore_dashboard.dart';
import '../portal/home/portal_dashboard.dart';

class DashboardSwitcher extends StatefulWidget {
  const DashboardSwitcher({super.key});

  @override
  State<DashboardSwitcher> createState() => _DashboardSwitcherState();
}

class _DashboardSwitcherState extends State<DashboardSwitcher> {
  bool showPortal = true;

  void switchDashboard(bool value) {
    setState(() {
      showPortal = !showPortal;
      print('Switched to: ${showPortal ? 'Explore' : 'Portal'} dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotateAnimation = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotateAnimation,
            child: child,
            builder: (context, child) {
              final isUnder = (ValueKey(showPortal) != child!.key);
              final value = isUnder
                  ? min(rotateAnimation.value, pi / 2)
                  : rotateAnimation.value;
              return Transform(
                transform: Matrix4.rotationY(value)..setEntry(3, 2, 0.015),
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        child: showPortal
            ? ExploreDashboard(onSwitch: switchDashboard)
            : PortalDashboard(onSwitch: switchDashboard),
      ),
    );
  }
}
