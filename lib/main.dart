import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/math/math_menu_screen.dart';
import 'screens/french/french_menu_screen.dart';
import 'screens/science/science_menu_screen.dart';
import 'screens/parental/parental_dashboard_screen.dart';
import 'services/progress_service.dart';
import 'services/audio_service.dart';
import 'services/audio_settings_service.dart';
import 'services/tts_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  final prefs = await SharedPreferences.getInstance();
  runApp(EmilieApp(prefs: prefs));
}

class EmilieApp extends StatelessWidget {
  final SharedPreferences prefs;
  const EmilieApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProgressService(prefs)),
        ChangeNotifierProvider(create: (_) => AudioSettingsService(prefs)),
        ChangeNotifierProvider(create: (_) => AudioService()),
        ChangeNotifierProvider(create: (_) => TtsService()),
      ],
      child: MaterialApp(
        title: 'Emilie App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
          '/math': (context) => const MathMenuScreen(),
          '/french': (context) => const FrenchMenuScreen(),
          '/science': (context) => const ScienceMenuScreen(),
          '/parental': (context) => const ParentalDashboardScreen(),
        },
      ),
    );
  }
}
