import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:linkschool/config/providers_config.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_themes.dart';

import 'package:linkschool/modules/providers/app_settings_provider.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/routes/app_navigation_flow.dart';
import 'package:linkschool/routes/onboardingScreen.dart';
import 'package:provider/provider.dart';


final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase (required for auth)
  await Firebase.initializeApp();
  print('Firebase initialized successfully');

  // Initialize Hive (required for session management)
  try {
    await Hive.initFlutter();
    // Open boxes sequentially but without unnecessary delays
    await Hive.openBox('userData');
    await Hive.openBox('attendance');
    await Hive.openBox('loginResponse');
    print('Hive initialized successfully');
  } catch (e) {
    print('Error initializing Hive: $e');
  }

  // Initialize service locator (required for auth)
  setupServiceLocator();

  // DEFERRED: Initialize MobileAds in background (not needed for launch)
  // This will run after the app is visible
  // Future.microtask(() async {
  //   try {
  //     await MobileAds.instance.initialize();
  //     print('✅ MobileAds initialized in background');
  //   } catch (e) {
  //     print('⚠️ MobileAds initialization failed: $e');
  //   }
  // });

  // await EnvConfig.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
   await MobileAds.instance.initialize();
   
  runApp(
    MultiProvider(
      providers: getAppProviders(),
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
            textScaler: TextScaler.linear(settings.textScaleFactor),
          ),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Linkskool',
            theme: settings.isDarkMode
                ? AppThemes.darkTheme
                : AppThemes.lightTheme,
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
  //Uri? _pendingUri;

  @override
  void initState() {
    
    super.initState();
   _initializeApp();
    //_bootstrap();
  }

  // Future<void> _bootstrap() async {
  // await _initializeApp();
  // _initDeepLinks();
  // }

  // void _initDeepLinks() async {
  //   final initialUri = await getInitialUri();

  //   if (initialUri != null) {
  //     _handleUri(initialUri);
  //   }

  //   uriLinkStream.listen((Uri? uri) {
  //     if (uri != null) {
  //       _handleUri(uri);
  //     }
  //   });
  // }

  // void _handleUri(Uri uri) {
  //   debugPrint("Deep link: $uri");

  //   if (uri.pathSegments.contains('submissions')) {
  //     _pendingUri = uri;
  //   }
  // }

  Future<void> _initializeApp() async {
    try {
      // Get Hive box first
      final userBox = Hive.box('userData');

      // Check onboarding status
      final hasSeenOnboarding =
          userBox.get('hasSeenOnboarding', defaultValue: false);

      // Get AuthProvider from Provider context
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Check login status (fast - uses cached session or silent login)
      await authProvider.checkLoginStatus();

      // Get CbtUserProvider and initialize in background (non-blocking)
      final cbtUserProvider =
          Provider.of<CbtUserProvider>(context, listen: false);
      // Don't await - let it initialize in background
      cbtUserProvider.initialize();

      if (mounted) {
        setState(() {
          // Show onboarding only if user hasn't seen it AND isn't logged in
          _showOnboarding = !hasSeenOnboarding && !authProvider.isLoggedIn;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final userBox = Hive.box('userData');
          final hasSeenOnboarding =
              userBox.get('hasSeenOnboarding', defaultValue: false);
          _showOnboarding = !hasSeenOnboarding;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

//   void _navigateFromUri(Uri uri) {
//   final segments = uri.pathSegments;

//   if (segments.contains('submissions')) {

//     final submissionId = segments.last;
//     final profileId = uri.queryParameters['profile_id'];
//     final lessonId  = uri.queryParameters['lesson_id'];
//     final cohortId = uri.queryParameters['cohort_id'];

//     // Decide section
//    // final authProvider = Provider.of<AuthProvider>(context, listen: false);

//     // if (!authProvider.isLoggedIn) {
//     //   Navigator.pushNamed(context, '/explore-login',
//     //     arguments: {
//     //       'redirect': uri.toString(),
//     //     }
//     //   );
//     //   return;
//     // }


//       // Navigator.push(
//       //         context,
//       //         MaterialPageRoute(
//       //           builder: (context) => CourseDetailScreen(
//       //          profileId:int.tryParse(profileId!),
//       //           lessonId: int.tryParse(lessonId!),
//       //            courseTitle:'', 
//       //            courseName: '',
//       //             courseDescription: '',
//       //              provider: '', 
//       //              cohortId:cohortId!,
                 
//       //           ),
//       //         ),
//       //       );

//     // Navigator.pushNamed(
//     //   context,
//     //   '/submission',
//     //   arguments: {
//     //     'submission_id': submissionId,
//     //     'profile_id': profileId,
//     //     'lesson_id': lessonId,
//     //   },
//     // );
//   }
// }

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

    if (_showOnboarding) {
      return const Onboardingscreen();
    }

// if (_pendingUri != null) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//      _navigateFromUri(_pendingUri!);
//       _pendingUri = null; // prevent repeat
//     });
//   }
    return const AppNavigationFlow();
  }
}
