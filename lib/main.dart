import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkschool/modules/common/app_themes.dart';
import 'package:linkschool/modules/common/dashboard_switcher.dart';
import 'package:linkschool/routes/route_generator.dart';
 // Import the RouteGenerator

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // For Android (dark icons)
      statusBarBrightness: Brightness.dark, // For iOS (dark icons)
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Linkskool',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/', // Set the initial route
      onGenerateRoute: RouteGenerator.generateRoute, // Use the RouteGenerator
      home: const DashboardSwitcher(), 
    );
  }
}