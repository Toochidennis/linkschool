import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_themes.dart';
import 'package:linkschool/modules/providers/admin/assessment_provider.dart';
import 'package:linkschool/modules/providers/admin/attendance_provider.dart';
import 'package:linkschool/modules/providers/admin/behaviour_provider.dart';
import 'package:linkschool/modules/providers/admin/class_provider.dart';
import 'package:linkschool/modules/providers/admin/course_registration_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/activity_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/assignment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/admin_comment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/delete_question.dart';
import 'package:linkschool/modules/providers/admin/e_learning/delete_sylabus_content.dart';
import 'package:linkschool/modules/providers/admin/e_learning/mark_assignment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/material_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/quiz_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/single_content_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/syllabus_content_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/syllabus_provider.dart';
import 'package:linkschool/modules/providers/admin/course_result_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/topic_provider.dart';
import 'package:linkschool/modules/providers/admin/level_provider.dart';
import 'package:linkschool/modules/providers/admin/payment/account_provider.dart';
import 'package:linkschool/modules/providers/admin/payment/fee_provider.dart';
import 'package:linkschool/modules/providers/admin/performance_provider.dart';
import 'package:linkschool/modules/providers/admin/skills_behavior_table_provider.dart';
import 'package:linkschool/modules/providers/admin/student_provider.dart';
import 'package:linkschool/modules/providers/admin/term_provider.dart';
import 'package:linkschool/modules/providers/admin/view_course_result_provider.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
import 'package:linkschool/modules/providers/explore/exam_provider.dart';
import 'package:linkschool/modules/providers/explore/for_you_provider.dart';
import 'package:linkschool/modules/providers/explore/home/news_provider.dart';
import 'package:linkschool/modules/providers/explore/subject_provider.dart';
import 'package:linkschool/modules/providers/staff/overview.dart';
import 'package:linkschool/modules/providers/staff/streams_provider.dart';
import 'package:linkschool/modules/providers/staff/syllabus_provider.dart';
import 'package:linkschool/modules/providers/student/elearningcontent_provider.dart';
import 'package:linkschool/modules/providers/student/payment_provider.dart';
import 'package:linkschool/modules/providers/student/payment_submission_provider.dart';
import 'package:linkschool/modules/services/admin/e_learning/single-content_service.dart';
import 'package:linkschool/modules/providers/student/marked_assignment_provider.dart';
import 'package:linkschool/modules/providers/student/marked_quiz_provider.dart';
import 'package:linkschool/modules/providers/student/single_elearningcontent_provider.dart';
import 'package:linkschool/modules/providers/student/streams_provider.dart';
import 'package:linkschool/modules/providers/student/student_result_provider.dart';
import 'package:linkschool/modules/providers/student/student_comment_provider.dart';
import 'package:linkschool/modules/services/explore/cbt_service.dart';
import 'package:linkschool/modules/services/staff/overview_service.dart';
import 'package:linkschool/routes/onboardingScreen.dart';
import 'package:linkschool/routes/app_navigation_flow.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'modules/providers/admin/registered_terms_provider.dart';
import 'modules/providers/explore/game/game_provider.dart';
import 'modules/providers/admin/grade_provider.dart';
import 'modules/providers/student/dashboard_provider.dart';
import 'package:linkschool/modules/services/admin/e_learning/activity_service.dart';

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
        // Core providers
        ChangeNotifierProvider(create: (_) => locator<AuthProvider>()),
        
        // Explore providers
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
        ChangeNotifierProvider(create: (_) => CBTProvider(CBTService())),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
        ChangeNotifierProvider(create: (_) => ForYouProvider()),
        
        // Admin E-Learning providers
        ChangeNotifierProvider(create: (_) => locator<SyllabusProvider>()),
        ChangeNotifierProvider(create: (_) => locator<SyllabusContentProvider>()),
        ChangeNotifierProvider(create: (_) => locator<TopicProvider>()),
        ChangeNotifierProvider(create: (_) => locator<MaterialProvider>()),
        ChangeNotifierProvider(create: (_) => locator<AssignmentProvider>()),
        ChangeNotifierProvider(create: (_) => locator<QuizProvider>()),
        ChangeNotifierProvider(create: (_) => locator<DeleteSyllabusProvider>()),
        ChangeNotifierProvider(create: (_) => locator<DeleteQuestionProvider>()),
        ChangeNotifierProvider(create: (_) => locator<MarkAssignmentProvider>()),
        ChangeNotifierProvider(create: (_) => OverviewProvider(locator<OverviewService>())),
        ChangeNotifierProvider(create: (_) => locator<AdminCommentProvider>()),
        ChangeNotifierProvider(create: (_) => locator<StudentCommentProvider>()),
        
        // Admin core providers
        ChangeNotifierProvider(create: (_) => locator<GradeProvider>()),
        ChangeNotifierProvider(create: (_) => locator<SkillsProvider>()),
        ChangeNotifierProvider(create: (_) => locator<SkillsBehaviorTableProvider>()),
        ChangeNotifierProvider(create: (_) => locator<StudentProvider>()),
        ChangeNotifierProvider(create: (_) => locator<AttendanceProvider>()),
        ChangeNotifierProvider(create: (_) => locator<PerformanceProvider>()),
        
        // CRITICAL: Add the missing payment providers from service locator
        ChangeNotifierProvider(create: (_) => locator<AccountProvider>()),
        ChangeNotifierProvider(create: (_) => locator<FeeProvider>()),
        
        // Level, Class, Assessment, Term providers
        ChangeNotifierProvider(create: (_) => LevelProvider()),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
        ChangeNotifierProvider(create: (_) => AssessmentProvider()),
        ChangeNotifierProvider(create: (_) => TermProvider()),
        ChangeNotifierProvider(create: (_) => RegisteredTermsProvider()),
        ChangeNotifierProvider(create: (_) => CourseRegistrationProvider()),
        
        // Course result providers
        ChangeNotifierProvider(create: (_) => CourseResultProvider()),
        ChangeNotifierProvider(create: (_) => ViewCourseResultProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ElearningContentProvider()),
        ChangeNotifierProvider(create: (_) => locator<StreamsProvider>()),
        ChangeNotifierProvider(create: (_) => locator<MarkedAssignmentProvider>()),

          // StaffProvider from service locator
        ChangeNotifierProvider(create: (_) => locator<StaffSyllabusProvider>()),
        ChangeNotifierProvider(create: (_) => locator<InvoiceProvider>()),
        ChangeNotifierProvider(create: (_) => locator<StudentResultProvider>()),
        ChangeNotifierProvider(create: (_) => locator<StaffOverviewProvider>()),
                  ChangeNotifierProvider(create: (_) => locator<StaffStreamsProvider>()),
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
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkLoginStatus();
      
      // Check if user has completed onboarding
      final userBox = Hive.box('userData');
      final hasSeenOnboarding = userBox.get('hasSeenOnboarding', defaultValue: false);
      
      setState(() {
        _showOnboarding = !hasSeenOnboarding && !authProvider.isLoggedIn;
      });
      
    } catch (e) {
      print('Error initializing app: $e');
      setState(() {
        _showOnboarding = true; // Show onboarding on error
      });
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If user should see onboarding, show it
    if (_showOnboarding) {
      return Onboardingscreen();
    }

    // Otherwise, show the main app navigation flow
    return AppNavigationFlow();
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
// import 'package:linkschool/modules/providers/admin/class_provider.dart';
// import 'package:linkschool/modules/providers/admin/course_registration_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/activity_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/assignment_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/admin_comment_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/delete_question.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/delete_sylabus_content.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/mark_assignment_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/material_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/quiz_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/single_content_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/syllabus_content_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/syllabus_provider.dart';
// import 'package:linkschool/modules/providers/admin/course_result_provider.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/topic_provider.dart';
// import 'package:linkschool/modules/providers/admin/level_provider.dart';
// import 'package:linkschool/modules/providers/admin/payment/account_provider.dart';
// import 'package:linkschool/modules/providers/admin/payment/fee_provider.dart';
// import 'package:linkschool/modules/providers/admin/performance_provider.dart';
// import 'package:linkschool/modules/providers/admin/skills_behavior_table_provider.dart';
// import 'package:linkschool/modules/providers/admin/student_provider.dart';
// import 'package:linkschool/modules/providers/admin/term_provider.dart';
// import 'package:linkschool/modules/providers/admin/view_course_result_provider.dart';
// import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
// import 'package:linkschool/modules/providers/explore/exam_provider.dart';
// import 'package:linkschool/modules/providers/explore/for_you_provider.dart';
// import 'package:linkschool/modules/providers/explore/home/news_provider.dart';
// import 'package:linkschool/modules/providers/explore/subject_provider.dart';
// import 'package:linkschool/modules/providers/staff/overview.dart';
// import 'package:linkschool/modules/providers/staff/syllabus_provider.dart';
// // import 'package:linkschool/modules/providers/staff/overview.dart';
// import 'package:linkschool/modules/providers/student/elearningcontent_provider.dart';
// import 'package:linkschool/modules/providers/student/payment_provider.dart';
// import 'package:linkschool/modules/providers/student/payment_submission_provider.dart';
// import 'package:linkschool/modules/services/admin/e_learning/single-content_service.dart';
// import 'package:linkschool/modules/providers/student/marked_assignment_provider.dart';
// import 'package:linkschool/modules/providers/student/marked_quiz_provider.dart';
// import 'package:linkschool/modules/providers/student/single_elearningcontent_provider.dart';
// import 'package:linkschool/modules/providers/student/streams_provider.dart';
// import 'package:linkschool/modules/providers/student/student_comment_provider.dart';
// import 'package:linkschool/modules/services/explore/cbt_service.dart';
// import 'package:linkschool/modules/services/staff/overview_service.dart';
// import 'package:linkschool/routes/onboardingScreen.dart';
// import 'package:provider/provider.dart';
// import 'package:linkschool/modules/services/api/service_locator.dart';
// import 'modules/providers/admin/registered_terms_provider.dart';
// import 'modules/providers/explore/game/game_provider.dart';
// import 'modules/providers/admin/grade_provider.dart';
// import 'modules/providers/student/dashboard_provider.dart';
// import 'package:linkschool/modules/services/admin/e_learning/activity_service.dart';

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
//         // Core providers
//         ChangeNotifierProvider(create: (_) => locator<AuthProvider>()),
        
//         // Explore providers
//         ChangeNotifierProvider(create: (_) => NewsProvider()),
//         ChangeNotifierProvider(create: (_) => SubjectProvider()),
//         ChangeNotifierProvider(create: (_) => CBTProvider(CBTService())),
//         ChangeNotifierProvider(create: (_) => GameProvider()),
//         ChangeNotifierProvider(create: (_) => ExamProvider()),
//         ChangeNotifierProvider(create: (_) => ForYouProvider()),
        
//         // Admin E-Learning providers
//         ChangeNotifierProvider(create: (_) => locator<SyllabusProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<SyllabusContentProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<TopicProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<MaterialProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<AssignmentProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<QuizProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<DeleteSyllabusProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<DeleteQuestionProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<MarkAssignmentProvider>()),
//         ChangeNotifierProvider(create: (_) => OverviewProvider(locator<OverviewService>())),
//         ChangeNotifierProvider(create: (_) => locator<AdminCommentProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<StudentCommentProvider>()),
        
//         // Admin core providers
//         ChangeNotifierProvider(create: (_) => locator<GradeProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<SkillsProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<SkillsBehaviorTableProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<StudentProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<AttendanceProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<PerformanceProvider>()),
        
//         // CRITICAL: Add the missing payment providers from service locator
//         ChangeNotifierProvider(create: (_) => locator<AccountProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<FeeProvider>()),
        
//         // Level, Class, Assessment, Term providers
//         ChangeNotifierProvider(create: (_) => LevelProvider()),
//         ChangeNotifierProvider(create: (_) => ClassProvider()),
//         ChangeNotifierProvider(create: (_) => AssessmentProvider()),
//         ChangeNotifierProvider(create: (_) => TermProvider()),
//         ChangeNotifierProvider(create: (_) => RegisteredTermsProvider()),
//         ChangeNotifierProvider(create: (_) => CourseRegistrationProvider()),
        
//         // Course result providers
//         ChangeNotifierProvider(create: (_) => CourseResultProvider()),
//         ChangeNotifierProvider(create: (_) => ViewCourseResultProvider()),
//         ChangeNotifierProvider(create: (_) => DashboardProvider()),
//         ChangeNotifierProvider(create: (_) => ElearningContentProvider()),
//         ChangeNotifierProvider(create: (_) => locator<StreamsProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<MarkedAssignmentProvider>()),

//           // StaffProvider  from service locator
//         ChangeNotifierProvider(create: (_) => locator<StaffSyllabusProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<InvoiceProvider>()),
//         ChangeNotifierProvider(create: (_) => locator<StaffOverviewProvider>()),

//         // ChangeNotifierProvider(create: (_) => locator<AccountProvider>()),
//         // ChangeNotifierProvider(create: (_) => locator<FeeProvider>()),
//         // ChangeNotifierProvider(create: (_) => locator<StaffOverviewProvider>()),

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
//       home: const AppInitializer(),
//     );
//   }
// }

// class AppInitializer extends StatefulWidget {
//   const AppInitializer({super.key});

//   @override
//   State<AppInitializer> createState() => _AppInitializerState();
// }

// class _AppInitializerState extends State<AppInitializer> {
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//   }

//   Future<void> _initializeApp() async {
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       await authProvider.checkLoginStatus();
//     } catch (e) {
//       print('Error initializing app: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isInitialized = true;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isInitialized) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     return Onboardingscreen();
//   }
// }