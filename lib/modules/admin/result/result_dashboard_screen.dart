import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/widgets/portal/result_dashboard/level_selection.dart';
import 'package:linkschool/modules/common/widgets/portal/result_dashboard/performance_chart.dart';
import 'package:linkschool/modules/common/widgets/portal/result_dashboard/settings_section.dart';

class ResultDashboardScreen extends StatefulWidget {
  final PreferredSizeWidget appBar;

  const ResultDashboardScreen({
    super.key,
    required this.appBar,
  });

  @override
  State<ResultDashboardScreen> createState() => _ResultDashboardScreenState();
}

class _ResultDashboardScreenState extends State<ResultDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
            SliverToBoxAdapter(
              child: Constants.heading600(
                title: 'Overall Performance',
                titleSize: 18.0,
                titleColor: AppColors.resultColor1,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24.0)),
            const SliverToBoxAdapter(child: PerformanceChart()),
            const SliverToBoxAdapter(child: SizedBox(height: 28.0)),
            SliverToBoxAdapter(
              child: Constants.heading600(
                title: 'Settings',
                titleSize: 18.0,
                titleColor: AppColors.resultColor1,
              ),
            ),
            const SliverToBoxAdapter(child: SettingsSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 48.0)),
            SliverToBoxAdapter(
              child: Constants.heading600(
                title: 'Select Level',
                titleSize: 18.0,
                titleColor: AppColors.resultColor1,
              ),
            ),
            const SliverToBoxAdapter(child: LevelSelection()),
          ],
        ),
      ),
    );
  }
}


// // lib/screens/result_dashboard_screen.dart
// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/widgets/portal/result_dashboard/level_selection.dart';
// import 'package:linkschool/modules/common/widgets/portal/result_dashboard/performance_chart.dart';
// import 'package:linkschool/modules/common/widgets/portal/result_dashboard/settings_section.dart';



// class ResultDashboardScreen extends StatefulWidget {
//   final PreferredSizeWidget appBar;

//   const ResultDashboardScreen({
//     super.key,
//     required this.appBar,
//   });

//   @override
//   State<ResultDashboardScreen> createState() => _ResultDashboardScreenState();
// }

// class _ResultDashboardScreenState extends State<ResultDashboardScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: widget.appBar,
//       body: Container(
//         decoration: Constants.customBoxDecoration(context),
//         child: CustomScrollView(
//           physics: const BouncingScrollPhysics(),
//           slivers: [
//             const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
//             SliverToBoxAdapter(
//               child: Constants.heading600(
//                 title: 'Overall Performance',
//                 titleSize: 18.0,
//                 titleColor: AppColors.resultColor1,
//               ),
//             ),
//             const SliverToBoxAdapter(child: SizedBox(height: 24.0)),
//             const SliverToBoxAdapter(child: PerformanceChart()),
//             const SliverToBoxAdapter(child: SizedBox(height: 28.0)),
//             SliverToBoxAdapter(
//               child: Constants.heading600(
//                 title: 'Settings',
//                 titleSize: 18.0,
//                 titleColor: AppColors.resultColor1,
//               ),
//             ),
//             const SliverToBoxAdapter(child: SettingsSection()),
//             const SliverToBoxAdapter(child: SizedBox(height: 48.0)),
//             SliverToBoxAdapter(
//               child: Constants.heading600(
//                 title: 'Select Level',
//                 titleSize: 18.0,
//                 titleColor: AppColors.resultColor1,
//               ),
//             ),
//             const SliverToBoxAdapter(child: LevelSelection()),
//           ],
//         ),
//       )
//     );
//   }
// }