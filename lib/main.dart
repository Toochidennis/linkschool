// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:linkschool/modules/common/app_themes.dart';
import 'package:linkschool/modules/providers/admin/assessment_provider.dart';
import 'package:linkschool/modules/providers/admin/class_provider.dart';
import 'package:linkschool/modules/providers/admin/grade_provider.dart';
import 'package:linkschool/modules/providers/admin/level_provider.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
import 'package:linkschool/modules/providers/explore/exam_provider.dart';
import 'package:linkschool/modules/providers/explore/for_you_provider.dart';
import 'package:linkschool/modules/providers/explore/home/ebook_provider.dart';
import 'package:linkschool/modules/providers/explore/home/news_provider.dart';
import 'package:linkschool/modules/providers/explore/subject_provider.dart';
import 'package:linkschool/modules/services/explore/cbt_service.dart';
import 'package:linkschool/modules/services/explore/home/ebook_service.dart';
import 'package:linkschool/routes/onboardingScreen.dart';
import 'package:provider/provider.dart';

// import 'modules/providers/admin/grade_provider.dart';
import 'modules/providers/explore/game/game_provider.dart';



// import 'package:linkschool/app_navigation_flow.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // For Android (dark icons)
      statusBarBrightness: Brightness.dark, // For iOS (dark icons)
    ),
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => NewsProvider()),
      ChangeNotifierProvider(create: (context) => SubjectProvider()),
      ChangeNotifierProvider(create: (_) => CBTProvider(CBTService())),
      ChangeNotifierProvider(create: (context) => GameProvider()),
      ChangeNotifierProvider(create: (_) => ExamProvider()),
      ChangeNotifierProvider(create: (context) => ForYouProvider()),
      ChangeNotifierProvider(create: (context) => GradeProvider()),
      ChangeNotifierProvider(create: (context) => LevelProvider()),
      ChangeNotifierProvider(create: (context) => ClassProvider()),
      ChangeNotifierProvider(create: (_) => AssessmentProvider()),
        // ChangeNotifierProvider(create: (context) => GradeProvider()),
    ],
    child: const MyApp(),
  ));
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



// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:linkschool/modules/common/app_themes.dart';
// import 'package:linkschool/modules/providers/admin/grade_provider.dart';
// import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
// import 'package:linkschool/modules/providers/explore/exam_provider.dart';
// import 'package:linkschool/modules/providers/explore/for_you_provider.dart';
// import 'package:linkschool/modules/providers/explore/home/news_provider.dart';
// import 'package:linkschool/modules/providers/explore/subject_provider.dart';
// import 'package:linkschool/modules/services/explore/cbt_service.dart';
// import 'package:linkschool/routes/onboardingScreen.dart';
// import 'package:provider/provider.dart';

// import 'modules/providers/explore/game/game_provider.dart';


// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env");

//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light, // For Android (dark icons)
//       statusBarBrightness: Brightness.dark, // For iOS (dark icons)
//     ),
//   );
//   runApp(MultiProvider(
//     providers: [
//       ChangeNotifierProvider(create: (context) => NewsProvider()),
//       ChangeNotifierProvider(create: (context) => SubjectProvider()),
//       ChangeNotifierProvider(create: (_) => CBTProvider(CBTService())),
//       ChangeNotifierProvider(create: (context) => GameProvider()),
//       ChangeNotifierProvider(create: (_) => ExamProvider()),
//       ChangeNotifierProvider(create: (context) => ForYouProvider()),
//       ChangeNotifierProvider(create: (context) => GradeProvider()),
//     ],
//     child: const MyApp(),
//   ));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Linkskool',
//       theme: AppThemes.lightTheme,
//       darkTheme: AppThemes.darkTheme,
//       themeMode: ThemeMode.system,
//       home: Onboardingscreen(),
//     );
//   }
// }
