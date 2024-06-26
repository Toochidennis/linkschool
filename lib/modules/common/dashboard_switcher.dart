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
  bool reverseAnimation = false;

  void switchDashboard(bool value) {
    setState(() {
      showPortal = !showPortal;
      reverseAnimation = !reverseAnimation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1400),
        layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotateAnimation = Tween(begin: pi, end: 0.0).animate(animation);

          final tween = Tween<double>(
            begin: reverseAnimation ? 0.0 : pi,
            end: reverseAnimation ? pi : 0.0,
          ).animate(animation);

          return AnimatedBuilder(
            animation: tween,
            child: child,
            builder: (context, child) {
              final isUnder = (ValueKey(showPortal) != child!.key);
              var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
              tilt *= isUnder ? -1.0 : 1.0;
              final value = isUnder
                  ? min(rotateAnimation.value, pi / 2)
                  : rotateAnimation.value;
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
                key: const ValueKey('explore'), onSwitch: switchDashboard)
            : PortalDashboard(
                key: const ValueKey('portal'), onSwitch: switchDashboard),
      ),
    );
  }
}
