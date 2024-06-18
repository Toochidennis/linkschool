import 'package:flutter/material.dart';
import '../../common/app_colors.dart';
import 'all_tab.dart';

class CustomTabController extends StatelessWidget {
  const CustomTabController({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            unselectedLabelColor: Colors.black.withOpacity(0.3),
            indicatorColor: AppColors.primaryLight,
            tabs: const [
              Tab(
                child: Text('All'),
              ),
              Tab(
                child: Text('Library'),
              )
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                AllTab(),
                Container(
                  color: Colors.orange,
                  child: Center(
                    child: Text('Tab 2'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
