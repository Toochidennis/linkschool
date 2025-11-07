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
import 'package:linkschool/modules/providers/admin/e_learning/comment_provider.dart';
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
import 'package:linkschool/modules/providers/admin/home/add_staff_provider.dart';
import 'package:linkschool/modules/providers/admin/home/add_course_provider.dart';
import 'package:linkschool/modules/providers/admin/home/all_feeds.provider.dart';
import 'package:linkschool/modules/providers/admin/home/assign_course_provider.dart';
import 'package:linkschool/modules/providers/admin/home/dashboard_feed_provider.dart';
import 'package:linkschool/modules/providers/admin/home/level_class_provider.dart';
import 'package:linkschool/modules/providers/admin/home/manage_student_provider.dart';
import 'package:linkschool/modules/providers/admin/level_provider.dart';
import 'package:linkschool/modules/providers/admin/payment/account_provider.dart';
import 'package:linkschool/modules/providers/admin/payment/fee_provider.dart';
import 'package:linkschool/modules/providers/admin/performance_provider.dart';
import 'package:linkschool/modules/providers/admin/skills_behavior_table_provider.dart';
import 'package:linkschool/modules/providers/admin/student_provider.dart';
import 'package:linkschool/modules/providers/admin/term_provider.dart';
import 'package:linkschool/modules/providers/admin/view_course_result_provider.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
import 'package:linkschool/modules/providers/explore/ebook_provider.dart';
import 'package:linkschool/modules/providers/explore/exam_provider.dart';
import 'package:linkschool/modules/providers/explore/for_you_provider.dart';
import 'package:linkschool/modules/providers/explore/home/admission_provider.dart';
import 'package:linkschool/modules/providers/explore/home/ebook_provider.dart';
import 'package:linkschool/modules/providers/explore/home/news_provider.dart';
import 'package:linkschool/modules/providers/explore/subject_provider.dart';
import 'package:linkschool/modules/providers/login/schools_provider.dart';
import 'package:linkschool/modules/providers/staff/overview.dart';
import 'package:linkschool/modules/providers/staff/staff_dashboard_provider.dart';
import 'package:linkschool/modules/providers/staff/streams_provider.dart';
import 'package:linkschool/modules/providers/staff/syllabus_provider.dart';
import 'package:linkschool/modules/providers/student/elearningcontent_provider.dart';
import 'package:linkschool/modules/providers/student/home/student_dashboard_feed_provider.dart';
import 'package:linkschool/modules/providers/student/payment_provider.dart';
import 'package:linkschool/modules/providers/student/payment_submission_provider.dart';
import 'package:linkschool/modules/providers/student/marked_assignment_provider.dart';
import 'package:linkschool/modules/providers/student/single_elearningcontent_provider.dart';
import 'package:linkschool/modules/providers/student/streams_provider.dart';
import 'package:linkschool/modules/providers/student/student_comment_provider.dart';
import 'package:linkschool/modules/providers/student/student_result_provider.dart';
import 'package:linkschool/modules/services/admin/e_learning/activity_service.dart';
import 'package:linkschool/modules/services/explore/cbt_service.dart';
import 'package:linkschool/modules/services/staff/overview_service.dart';
import 'package:linkschool/routes/onboardingScreen.dart';
import 'package:linkschool/routes/app_navigation_flow.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/modules/providers/admin/registered_terms_provider.dart';
import 'modules/providers/explore/game/game_provider.dart';
import 'modules/providers/admin/grade_provider.dart';
import 'modules/providers/student/dashboard_provider.dart';
import 'modules/providers/app_settings_provider.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

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
  
  // Initialize app settings
  final appSettings = AppSettingsProvider();
  await appSettings.initializeSettings();

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
        // App Settings Provider - Must be first for global theme
        ChangeNotifierProvider.value(value: appSettings),
        
        // Core providers
        ChangeNotifierProvider(create: (_) => locator<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => SchoolProvider()),
        // Explore
        ChangeNotifierProvider(create: (_) => AdmissionProvider()),
        ChangeNotifierProvider<NewsProvider>(create: (_) => NewsProvider()),

        ChangeNotifierProvider(create: (_) => SubjectProvider()),
        ChangeNotifierProvider(create: (_) => CBTProvider(CBTService())),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
        ChangeNotifierProvider(create: (_) => ForYouProvider()),
        ChangeNotifierProvider(create: (_) => locator<BookProvider>()),
        ChangeNotifierProvider(create: (_) => locator<EbookProvider>()),

        // Admin HomeScreen
        ChangeNotifierProvider(create: (_) => locator<AddStaffProvider>()),
        ChangeNotifierProvider(
          create: (_) => locator<LevelClassProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => locator<AssignCourseProvider>(),
        ),
        ChangeNotifierProvider(create: (_) => locator<ManageStudentProvider>()),
        ChangeNotifierProvider(create: (_) => locator<CourseProvider>()),
        ChangeNotifierProvider(create: (_) => locator<DashboardFeedProvider>()),
        ChangeNotifierProvider(
            create: (_) => locator<FeedsPaginationProvider>()),

        // Admin E-Learning
        ChangeNotifierProvider(create: (_) => locator<SyllabusProvider>()),
        ChangeNotifierProvider(
            create: (_) => locator<SyllabusContentProvider>()),
        ChangeNotifierProvider(create: (_) => locator<TopicProvider>()),
        ChangeNotifierProvider(create: (_) => locator<MaterialProvider>()),
        ChangeNotifierProvider(create: (_) => locator<AssignmentProvider>()),
        ChangeNotifierProvider(create: (_) => locator<QuizProvider>()),
        ChangeNotifierProvider(
            create: (_) => locator<DeleteSyllabusProvider>()),
        ChangeNotifierProvider(
            create: (_) => locator<DeleteQuestionProvider>()),
        ChangeNotifierProvider(
            create: (_) => locator<MarkAssignmentProvider>()),
        ChangeNotifierProvider(create: (_) => locator<SingleContentProvider>()),
        ChangeNotifierProvider(
            create: (_) => OverviewProvider(locator<OverviewService>())),
        ChangeNotifierProvider(create: (_) => locator<AdminCommentProvider>()),
        ChangeNotifierProvider(
            create: (_) => locator<StudentCommentProvider>()),
        ChangeNotifierProvider(create: (_) => locator<CommentProvider>()),

        // Admin core
        ChangeNotifierProvider(create: (_) => locator<GradeProvider>()),
        ChangeNotifierProvider(create: (_) => locator<SkillsProvider>()),
        ChangeNotifierProvider(
            create: (_) => locator<SkillsBehaviorTableProvider>()),
        ChangeNotifierProvider(create: (_) => locator<StudentProvider>()),
        ChangeNotifierProvider(create: (_) => locator<AttendanceProvider>()),
        ChangeNotifierProvider(create: (_) => locator<PerformanceProvider>()),

        // Payments
        ChangeNotifierProvider(create: (_) => locator<AccountProvider>()),
        ChangeNotifierProvider(create: (_) => locator<FeeProvider>()),

        // Level, Class, Assessment, Term
        ChangeNotifierProvider(create: (_) => LevelProvider()),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
        ChangeNotifierProvider(create: (_) => AssessmentProvider()),
        ChangeNotifierProvider(create: (_) => TermProvider()),
        ChangeNotifierProvider(create: (_) => RegisteredTermsProvider()),
        ChangeNotifierProvider(create: (_) => CourseRegistrationProvider()),

        // Course results
        ChangeNotifierProvider(create: (_) => CourseResultProvider()),
        ChangeNotifierProvider(create: (_) => ViewCourseResultProvider()),
        ChangeNotifierProvider(create: (_) => locator<AdminCommentProvider>()),

        // Student
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ElearningContentProvider()),
        ChangeNotifierProvider(create: (_) => locator<StreamsProvider>()),
        ChangeNotifierProvider(
            create: (_) => locator<MarkedAssignmentProvider>()),
        ChangeNotifierProvider(create: (_) => locator<StudentResultProvider>()),
        ChangeNotifierProvider(create: (_) => locator<InvoiceProvider>()),
        ChangeNotifierProvider(create: (_) => locator<PaymentProvider>()),
        ChangeNotifierProvider(
            create: (_) => locator<StudentDashboardFeedProvider>()),
        ChangeNotifierProvider(
            create: (_) => locator<SingleelearningcontentProvider>()),
        ChangeNotifierProvider(
            create: (_) => locator<SingleelearningcontentProvider>()),
        // Staff
        ChangeNotifierProvider(create: (_) => locator<StaffSyllabusProvider>()),
        ChangeNotifierProvider(
            create: (_) =>
                StaffOverviewProvider(locator<StaffOverviewService>())),
        ChangeNotifierProvider(create: (_) => locator<StaffStreamsProvider>()),
        ChangeNotifierProvider(
            create: (_) => locator<StaffDashboardProvider>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsProvider>(
      builder: (context, settings, _) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: settings.textScaleFactor,
          ),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Linkskool',
            theme: settings.isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AppInitializer(),
            navigatorObservers: [routeObserver],
          ),
        );
      },
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
      print('=== Starting App Initialization ===');

      // Get Hive box first
      final userBox = Hive.box('userData');

      // Check onboarding status
      final hasSeenOnboarding =
          userBox.get('hasSeenOnboarding', defaultValue: false);
      print('hasSeenOnboarding: $hasSeenOnboarding');

      // CRITICAL: Wait for the next frame to ensure Provider is ready
      await Future.delayed(const Duration(milliseconds: 50));

      // Get AuthProvider from Provider context
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Check login status
      await authProvider.checkLoginStatus();

      // Give state time to settle
      await Future.delayed(const Duration(milliseconds: 100));

      print('Auth Status:');
      print('  - isLoggedIn: ${authProvider.isLoggedIn}');
      print('  - user: ${authProvider.user?.name ?? "null"}');
      print('  - role: ${authProvider.user?.role ?? "null"}');
      print('  - token exists: ${authProvider.token != null}');

      // Verify from Hive directly as backup
      final isLoggedInHive = userBox.get('isLoggedIn', defaultValue: false);
      final sessionValid = userBox.get('sessionValid', defaultValue: false);
      print('Hive Verification:');
      print('  - isLoggedIn: $isLoggedInHive');
      print('  - sessionValid: $sessionValid');

      if (mounted) {
        setState(() {
          // Show onboarding only if user hasn't seen it AND isn't logged in
          _showOnboarding = !hasSeenOnboarding && !authProvider.isLoggedIn;
          print('Decision: Show onboarding = $_showOnboarding');
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error initializing app: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          final userBox = Hive.box('userData');
          final hasSeenOnboarding =
              userBox.get('hasSeenOnboarding', defaultValue: false);
          _showOnboarding = !hasSeenOnboarding;
          print('Error fallback: Show onboarding = $_showOnboarding');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      print('=== App Initialization Complete ===\n');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    print('🏗️ Building: showOnboarding=$_showOnboarding');

    if (_showOnboarding) {
      return const Onboardingscreen();
    }

    return const AppNavigationFlow();
  }
}
