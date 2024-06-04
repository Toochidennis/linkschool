import 'package:flutter/material.dart';
import 'package:linkschool/common/app_themes.dart';
import 'package:linkschool/ui/dashboard/explore/explore_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Linkskool',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      home: const ExploreDashboard(),
    );
  }
}
