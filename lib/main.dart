import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:linkschool/modules/common/app_themes.dart';
import 'package:linkschool/modules/explore/chat/services/openai_service.dart';

import 'package:linkschool/routes/onboardingScreen.dart';
import 'package:provider/provider.dart';
// import 'package:linkschool/app_navigation_flow.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // For Android (dark icons)
      statusBarBrightness: Brightness.dark, // For iOS (dark icons)
    ),
  );

  // Verify API key is loaded
  final apiKey = dotenv.env['OPENAI_API_KEY'];
  print('Loaded API key: ${apiKey?.substring(0, 10)}...');

  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (_) => OpenAIService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
  // runApp(const MyApp());
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