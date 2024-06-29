import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/constants.dart';

import '../explore/home/explore_dashboard.dart';
import '../portal/home/portal_dashboard.dart';

class DashboardSwitcher extends StatefulWidget {
  const DashboardSwitcher({super.key});

  @override
  State<DashboardSwitcher> createState() => _DashboardSwitcherState();
}

class _DashboardSwitcherState extends State<DashboardSwitcher> {
  late FlipCardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FlipCardController();
  }

  void _toggleDashboard(bool value) {
    _controller.toggleCard();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Constants.customBoxDecoration(context),
      child: FlipCard(
        fill: Fill.fillBack,
        flipOnTouch: false,
        controller: _controller,
        front: ExploreDashboard(
          onSwitch: _toggleDashboard,
        ),
        back: PortalDashboard(
          onSwitch: _toggleDashboard,
        ),
      ),
    );
  }
}
