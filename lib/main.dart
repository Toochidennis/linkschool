import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_themes.dart';
import 'package:linkschool/modules/providers/admin/assessment_provider.dart';
import 'package:linkschool/modules/providers/admin/attendance_provider.dart';
import 'package:linkschool/modules/providers/admin/behaviour_provider.dart';
// import 'package:linkschool/modules/providers/admin/behaviour_provider.dart';
import 'package:linkschool/modules/providers/admin/class_provider.dart';
import 'package:linkschool/modules/providers/admin/course_registration_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/assignment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/material_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/quiz_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/syllabus_content_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/syllabus_provider.dart';
import 'package:linkschool/modules/providers/admin/course_result_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/topic_provider.dart';
import 'package:linkschool/modules/providers/admin/level_provider.dart';
import 'package:linkschool/modules/providers/admin/skills_behavior_table_provider.dart';
import 'package:linkschool/modules/providers/admin/student_provider.dart';
import 'package:linkschool/modules/providers/admin/term_provider.dart';
import 'package:linkschool/modules/providers/admin/view_course_result_provider.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
import 'package:linkschool/modules/providers/explore/exam_provider.dart';
import 'package:linkschool/modules/providers/explore/for_you_provider.dart';
import 'package:linkschool/modules/providers/explore/home/news_provider.dart';
import 'package:linkschool/modules/providers/explore/subject_provider.dart';
import 'package:linkschool/modules/services/admin/e_learning/syllabus_content_service.dart';
import 'package:linkschool/modules/services/explore/cbt_service.dart';
import 'package:linkschool/routes/onboardingScreen.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'modules/providers/admin/e_learning/syllabus_content_provider.dart';
import 'modules/providers/admin/registered_terms_provider.dart';
import 'modules/providers/explore/game/game_provider.dart';
import 'modules/providers/admin/grade_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Hive.initFlutter();
    await Hive.openBox('userData');
    await Hive.openBox('attendance');
    await Hive.openBox('loginResponse');
    print('Hive initialized successfully');
  } catch (e) {
    print('Error initializing Hive: $e');
  }
  
  await EnvConfig.init();
  setupServiceLocator();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locator<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
        ChangeNotifierProvider(create: (_) => CBTProvider(CBTService())),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
        ChangeNotifierProvider(create: (_) => ForYouProvider()),
        ChangeNotifierProvider(create: (_) => locator<SyllabusProvider>()),
        ChangeNotifierProvider(create: (_) => locator<SyllabusContentProvider>()),
        ChangeNotifierProvider(create: (_) => locator<GradeProvider>()),
        ChangeNotifierProvider(create: (_) => locator<SkillsProvider>()), 
         ChangeNotifierProvider(create: (_) => locator<SkillsBehaviorTableProvider>()), 
        ChangeNotifierProvider(create: (_) => LevelProvider()),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
        ChangeNotifierProvider(create: (_) => AssessmentProvider()),
        ChangeNotifierProvider(create: (_) => TermProvider()),
        ChangeNotifierProvider(create: (_) => RegisteredTermsProvider()),
        ChangeNotifierProvider(create: (_) => CourseRegistrationProvider()),
        ChangeNotifierProvider(create: (_) => locator<TopicProvider>()),
        ChangeNotifierProvider(create: (_) => locator<MaterialProvider>()),
        ChangeNotifierProvider(create: (_) => locator<AssignmentProvider>()),
        ChangeNotifierProvider(create: (_) => locator<QuizProvider>()),
            ChangeNotifierProvider(create: (_) => locator<SyllabusContentProvider>()),
        // StudentProvider from service locator
        ChangeNotifierProvider(create: (_) => locator<StudentProvider>()),
        ChangeNotifierProvider(create: (_) => locator<AttendanceProvider>()),
        ChangeNotifierProvider(create: (_) => CourseResultProvider()),
        ChangeNotifierProvider(create: (_) => ViewCourseResultProvider()),
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




// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:linkschool/config/env_config.dart';
// import 'package:linkschool/modules/auth/provider/auth_provider.dart';
// import 'package:linkschool/modules/common/app_themes.dart';
// import 'package:linkschool/modules/providers/admin/assessment_provider.dart';
// import 'package:linkschool/modules/providers/admin/attendance_provider.dart';
// import 'package:linkschool/modules/providers/admin/behaviour_provider.dart';
// import 'package:linkschool/modules/providers/admin/behaviour_provider.dart';
// import 'package:linkschool/modules/providers/admin/class_provider.dart';
// import 'package:linkschool/modules/providers/admin/course_registration_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/material_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/syllabus_provider.dart';
// import 'package:linkschool/modules/providers/admin/course_result_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/topic_provider.dart';
// import 'package:linkschool/modules/providers/admin/level_provider.dart';
// import 'package:linkschool/modules/providers/admin/skills_behavior_table_provider.dart';
// import 'package:linkschool/modules/providers/admin/student_provider.dart';
// import 'package:linkschool/modules/providers/admin/term_provider.dart';
// import 'package:linkschool/modules/providers/admin/view_course_result_provider.dart';
// import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
// import 'package:linkschool/modules/providers/explore/exam_provider.dart';
// import 'package:linkschool/modules/providers/explore/for_you_provider.dart';
// import 'package:linkschool/modules/providers/explore/home/news_provider.dart';
// import 'package:linkschool/modules/providers/explore/subject_provider.dart';
// import 'package:linkschool/modules/services/admin/e_learning/syllabus_service.dart';
// import 'package:linkschool/modules/services/explore/cbt_service.dart';
// import 'package:linkschool/routes/onboardingScreen.dart';
// import 'package:provider/provider.dart';
// import 'package:linkschool/modules/services/api/service_locator.dart';
// import 'modules/providers/admin/registered_terms_provider.dart';
// import 'modules/providers/explore/game/game_provider.dart';
// import 'modules/providers/admin/grade_provider.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   try {
//     await Hive.initFlutter();
//     await Hive.openBox('userData');
//     await Hive.openBox('attendance');
//     await Hive.openBox('loginResponse');
//     print('Hive initialized successfully');
//   } catch (e) {
//     print('Error initializing Hive: $e');
//   }
  
//   await EnvConfig.init();
//   setupServiceLocator();
  
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light,
//       statusBarBrightness: Brightness.dark,
//     ),
//   );
  
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => locator<AuthProvider>()),
//         //  ChangeNotifierProvider(create: (_) => SyllabusProvider( SyllabusService())),
//         ChangeNotifierProvider(create: (_) => NewsProvider()),
//         ChangeNotifierProvider(create: (_) => SubjectProvider()),
//         ChangeNotifierProvider(create: (_) => CBTProvider(CBTService())),
//         ChangeNotifierProvider(create: (_) => GameProvider()),
//         ChangeNotifierProvider(create: (_) => ExamProvider()),
//         ChangeNotifierProvider(create: (_) => ForYouProvider()),
//         ChangeNotifierProvider<SyllabusProvider>(create: (_) => locator<SyllabusProvider>()),
//         // GradeProvider from service locator
//         ChangeNotifierProvider(create: (_) => locator<GradeProvider>()),
//         // SkillProvider from service locator
//         ChangeNotifierProvider(create: (_) => locator<SkillsProvider>()),

//         ChangeNotifierProvider(create: (_) => LevelProvider()),
//         ChangeNotifierProvider(create: (_) => ClassProvider()),
//         ChangeNotifierProvider(create: (_) => AssessmentProvider()),
//         ChangeNotifierProvider(create: (_) => TermProvider()),
//         ChangeNotifierProvider(create: (_) => RegisteredTermsProvider()),
//         ChangeNotifierProvider(create: (_) => CourseRegistrationProvider()),
//         ChangeNotifierProvider(create: (_) => locator<TopicProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<MaterialProvider>()),
//         // StudentProvider from service locator
//         ChangeNotifierProvider(create: (_) => locator<StudentProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<AttendanceProvider>()),
//         ChangeNotifierProvider(create: (_) => CourseResultProvider()),
//         ChangeNotifierProvider(create: (_) => ViewCourseResultProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
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