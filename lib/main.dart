import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:linkschool/config/providers_config.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_themes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:linkschool/modules/providers/app_settings_provider.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/services/ads_service/facebook_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/modules/services/database/data_base_service.dart';
import 'package:linkschool/modules/services/notification_navigation_service.dart';
import 'package:linkschool/routes/app_navigation_flow.dart';
import 'package:provider/provider.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
final GlobalKey<NavigatorState> appNavigatorKey =
    GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  // await FacebookAnalyticsService.initialize();
  //  await FacebookAnalyticsService.logAppLaunch();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  try {
    await Hive.initFlutter();
    await Hive.openBox('userData');
    await Hive.openBox('attendance');
    await Hive.openBox('loginResponse');
    print('Hive initialized successfully');
  } catch (e) {
    print('Error initializing Hive: $e');
  }

  setupServiceLocator();

  await CbtExamSyncService().syncOnStartup();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  await MobileAds.instance.initialize();

  // Handle cold start via link (app was closed)
  final appLinks = AppLinks();
  final initialLink = await appLinks.getInitialLink();
  if (initialLink != null) {
    debugPrint('Cold start via link: $initialLink');
    // path is "/" — just let the app open normally, no routing needed
  }

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
            navigatorKey: appNavigatorKey,
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
  StreamSubscription<Uri>? _linkSub; // ✅ nullable — not assigned at declaration

  @override
  void initState() {
    super.initState();
    NotificationNavigationService().initialize(appNavigatorKey);
    _initializeApp();
    _initLinkListener();
  }

  void _initLinkListener() {
    _linkSub = AppLinks().uriLinkStream.listen((uri) {
      debugPrint('Link while app open: $uri');
      // path is "/" — app is already visible, nothing to do
    });
  }

  Future<void> _initializeApp() async {
    try {
      final userBox = Hive.box('userData');
      final hasSeenOnboarding =
          userBox.get('hasSeenOnboarding', defaultValue: false);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkLoginStatus();

      final cbtUserProvider =
          Provider.of<CbtUserProvider>(context, listen: false);
      cbtUserProvider.initialize();

      if (mounted) {
        setState(() {
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

  @override
  void dispose() {
    _linkSub?.cancel(); // ✅ cancels stream subscription on widget unmount
    super.dispose();
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

    // if (_showOnboarding) {
    //   return const Onboardingscreen();
    // }

    return const AppNavigationFlow();
  }
}