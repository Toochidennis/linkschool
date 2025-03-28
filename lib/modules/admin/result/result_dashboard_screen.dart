import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/widgets/portal/result_dashboard/level_selection.dart';
import 'package:linkschool/modules/common/widgets/portal/result_dashboard/performance_chart.dart';
import 'package:linkschool/modules/common/widgets/portal/result_dashboard/settings_section.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

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
  Map<String, dynamic>? userData;
  List<dynamic> levelNames = [];
  List<dynamic> classNames = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userBox = Hive.box('userData');
      
      // Debug: Print all keys in the box
      print('Hive Box Keys: ${userBox.keys.toList()}');
      
      // Try different approaches to retrieve the data
      final storedUserData = userBox.get('userData');
      final storedLoginResponse = userBox.get('loginResponse');
      
      print('Stored userData: $storedUserData');
      print('Stored loginResponse: $storedLoginResponse');

      // Determine which stored data to use
      dynamic dataToProcess;
      if (storedUserData != null) {
        dataToProcess = storedUserData;
      } else if (storedLoginResponse != null) {
        dataToProcess = storedLoginResponse;
      }

      if (dataToProcess != null) {
        // Ensure dataToProcess is a Map
        Map<String, dynamic> processedData = dataToProcess is String 
            ? json.decode(dataToProcess) 
            : dataToProcess;

        // Extract data from different possible structures
        final response = processedData['response'] ?? processedData;
        final data = response['data'] ?? response;

        // Extract levels and classes
        final levels = data['levels'] ?? [];
        final classes = data['classes'] ?? [];

        setState(() {
          userData = processedData;
          // Transform levels to match the previous format [id, level_name]
          levelNames = levels.map((level) => [
            (level['id'] ?? '').toString(), 
            level['level_name'] ?? ''
          ]).toList();
          
          // Transform classes to match the previous format [id, class_name, level_id]
          classNames = classes.map((cls) => [
            (cls['id'] ?? '').toString(), 
            cls['class_name'] ?? '', 
            (cls['level_id'] ?? '').toString()
          ]).toList();

          print('Processed Level Names: $levelNames');
          print('Processed Class Names: $classNames');
        });
      } else {
        print('No valid user data found in Hive');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

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
            SliverToBoxAdapter(
              child: LevelSelection(
                levelNames: levelNames, 
                classNames: classNames, 
                isSecondScreen: false,
                subjects: [
                  'Math',
                  'Science',
                  'English'
                ], 
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/widgets/portal/result_dashboard/level_selection.dart';
// import 'package:linkschool/modules/common/widgets/portal/result_dashboard/performance_chart.dart';
// import 'package:linkschool/modules/common/widgets/portal/result_dashboard/settings_section.dart';
// import 'package:hive/hive.dart';

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
//   Map<String, dynamic>? userData;
//   List<dynamic>? levelNames;
//   List<dynamic>? classNames;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     final userBox = Hive.box('userData');
//     final userData = userBox.get('userData');

//     if (userData != null) {
//       print('User Data: $userData'); 

//       // Extract levelName and className from the persisted JSON
//       final levelNameData = userData['levelName']?['rows'] ?? [];
//       final classNameData = userData['className']?['rows'] ?? [];

//       print('Level Names: $levelNameData'); 
//       print('Class Names: $classNameData'); 

//       setState(() {
//         this.userData = userData;
//         levelNames = levelNameData;
//         classNames = classNameData;
//       });
//     } else {
//       print('User data is null or not found in Hive');
//     }
//   }

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
//             SliverToBoxAdapter(
//               child: LevelSelection(
//                 levelNames: levelNames ?? [], // list of level names
//                 classNames: classNames ?? [], // list of class names
//                 isSecondScreen: false, // Set to true for course selection
//                 subjects: [
//                   'Math',
//                   'Science',
//                   'English'
//                 ], 
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }