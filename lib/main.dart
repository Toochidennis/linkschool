// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkschool/modules/common/app_themes.dart';
import 'package:linkschool/modules/providers/explore/home/ebook_provider.dart';
import 'package:linkschool/modules/providers/explore/home/news_provider.dart';
import 'package:linkschool/modules/services/explore/home/ebook_service.dart';
import 'package:linkschool/routes/onboardingScreen.dart';
import 'package:provider/provider.dart';
// import 'package:linkschool/app_navigation_flow.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // For Android (dark icons)
      statusBarBrightness: Brightness.dark, // For iOS (dark icons)
    ),
  );
  // runApp(
  //   MultiProvider(
  //     providers: [
  //       ChangeNotifierProvider(create: (context) => NewsProvider()),
  //       // Correctly provide BookProvider
  //       ChangeNotifierProvider(
  //           create: (context) => BookProvider(BookService())),
  //       // Provide BookService instance
  //       Provider<BookService>(
  //         create: (_) => BookService(),
  //       ),
  //     ],
  //     child: const MyApp(),
  //   ),
  // );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NewsProvider()),
        // Provide BookProvider only
        ChangeNotifierProvider(
            create: (context) => EbookProvider(ebookService: EbookService())),
        // ChangeNotifierProvider(
        //     create: (_) => EbookProvider(ebookService: EbookService())),
      ],
      child: const MyApp(),
    ),
  );
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
      home: Onboardingscreen(),
    );
  }
}

// AppNavigationFlow()
