import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/math/math_menu_screen.dart';
import 'screens/french/french_menu_screen.dart';
import 'screens/science/science_menu_screen.dart';
import 'screens/parental/parental_dashboard_screen.dart';
import 'screens/world_map_screen.dart';
import 'screens/daily_challenge_screen.dart';
import 'screens/avatar_screen.dart';
import 'screens/story_screen.dart';
import 'screens/audio_settings_screen.dart';
import 'screens/discovery/discovery_world_menu_screen.dart';
import 'screens/games/mini_games_menu_screen.dart';
import 'screens/garden/garden_screen.dart';
import 'screens/sensory/sensory_room_screen.dart';
import 'services/progress_service.dart';
import 'services/audio_service.dart';
import 'services/accessibility_settings_service.dart';
import 'services/tts_service.dart';
import 'services/game_service.dart';
import 'services/garden_service.dart';
import 'services/stats_service.dart';
import 'models/screen_time.dart';
import 'widgets/screen_time_gate.dart';
import 'utils/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
        ChangeNotifierProvider(create: (_) => AccessibilitySettingsService(prefs)),
        ChangeNotifierProvider(create: (_) => AudioService()),
        ChangeNotifierProvider(create: (_) => TtsService()),
        ChangeNotifierProvider(create: (_) => GameService(prefs)),
        ChangeNotifierProvider(create: (_) => ScreenTimeService()),
        ChangeNotifierProvider(create: (_) => GardenService(prefs)),
        ChangeNotifierProvider(create: (_) => StatsService(prefs)),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Appli Émilie',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          final access = context.watch<AccessibilitySettingsService>();
          // Coupe les animations globalement quand le réglage est désactivé
          // (transitions de page, animations implicites, effets par défaut).
          Animate.defaultDuration = access.animationsEnabled
              ? const Duration(milliseconds: 300)
              : Duration.zero;
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: !access.animationsEnabled,
            ),
            child: ScreenTimeGate(
              navigatorKey: navigatorKey,
              child: child!,
            ),
          );
        },
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
          '/math': (context) => const MathMenuScreen(),
          '/french': (context) => const FrenchMenuScreen(),
          '/science': (context) => const ScienceMenuScreen(),
          '/parental': (context) => const ParentalDashboardScreen(),
          '/world-map': (context) => const WorldMapScreen(),
          '/daily-challenge': (context) => const DailyChallengeScreen(),
          '/avatar': (context) => const AvatarScreen(),
          '/story': (context) => const StoryScreen(),
          '/audio-settings': (context) => const AudioSettingsScreen(),
          '/discovery-world': (context) => const DiscoveryWorldMenuScreen(),
          '/mini-games': (context) => const MiniGamesMenuScreen(),
          '/garden': (context) => const GardenScreen(),
          '/sensory-room': (context) => const SensoryRoomScreen(),
        },
      ),
    );
  }
}
