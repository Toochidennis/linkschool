import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/search_bar.dart';

class CBT_Dashboard extends StatefulWidget {
  const CBT_Dashboard({super.key});

  @override
  State<CBT_Dashboard> createState() => _CBT_DashboardState();
}

class _CBT_DashboardState extends State<CBT_Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:Constants.customBoxDecoration(context),
      child: SingleChildScrollView(
        child: Column(
          children: [
         
          ],
        ),
      ),
    );
  }
}





