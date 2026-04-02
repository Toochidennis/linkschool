import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:linkschool/config/providers_config.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_themes.dart';
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
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
final AppLinks _appLinks = AppLinks();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  try {
    await Hive.initFlutter();
    await Hive.openBox('userData');
    await Hive.openBox('attendance');
    await Hive.openBox('loginResponse');
  } catch (e) {
    // Intentionally ignored.
  }

  setupServiceLocator();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: getAppProviders(),
      child: const MyApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(CbtExamSyncService().syncOnStartup());
    unawaited(MobileAds.instance.initialize());
    unawaited(_logFacebookAppLaunchSafely());
  });
}

Future<void> _logFacebookAppLaunchSafely() async {
  try {
    await FacebookAnalyticsService.initialize();
    await FacebookAnalyticsService.logAppLaunch();
  } catch (e, stackTrace) {
    debugPrintStack(stackTrace: stackTrace);
  }
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
            builder: (context, child) {
              final overlayStyle = settings.isDarkMode
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark;
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: overlayStyle,
                child: child ?? const SizedBox.shrink(),
              );
            },
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
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeServices());
      unawaited(_initializeApp());
      _initLinkListener();
    });
  }

  Future<void> _initializeServices() async {
    await NotificationNavigationService().initialize(appNavigatorKey);
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      await NotificationNavigationService().handleDeepLink(initialLink);
    }
  }

  void _initLinkListener() {
    _linkSub = _appLinks.uriLinkStream.listen(
      (uri) {
        unawaited(NotificationNavigationService().handleDeepLink(uri));
      },
      onError: (Object error) {},
    );
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
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const AppNavigationFlow();
  }
}
