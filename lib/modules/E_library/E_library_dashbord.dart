import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';

class ElibraryDashboard extends StatefulWidget {
  const ElibraryDashboard ({super.key, required this.height});
  final double height;

  @override
  _ElibraryDashboardState createState() => _ElibraryDashboardState();
}

class _ElibraryDashboardState extends State<ElibraryDashboard> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration:Constants.customBoxDecoration(context),
        child:Column(
          children: [
            Expanded(
              child: DefaultTabController(
                length: 5, 
                
                child: 
                    Column(
                      children: [
                        TabBar(
                           indicatorColor: AppColors.text2Light,
                            labelColor:AppColors.text2Light, 
                          tabs: [
                             Tab(text: 'for you'),
                             Tab(text: 'CBT'),
                             Tab(text: 'E-books'),
                             Tab(text: 'Games'),
                             Tab(text: 'Videos'),
                        ]),



                           Expanded(
                child: TabBarView(
                  children: [
                      Center(
                        child: Text('hello 1'),
                      ),
                      Center(
                        child: Text('hello 2'),
                      ),
                      Center(
                        child: Text('hello 3'),
                      ),
                       Center(
                        child: Text('hello 4'),
                      ),
                       Center(
                        child: Text('hello 5'),
                      ),
                  ]
                )
              )
                      ],
                    ),
                     ),
            ),
               
              

            
          ],
        ),
      );
  }
}