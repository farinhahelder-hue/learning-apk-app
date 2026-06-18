import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE0F0), Color(0xFFE0F7FF), Color(0xFFFFFDE7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌟', style: TextStyle(fontSize: 100))
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .then()
                  .shimmer(duration: 1200.ms),
              const SizedBox(height: 24),
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3),
              const SizedBox(height: 12),
              const Text(
                'Bonjour Emilie ! 👋',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 22,
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.w600,
                ),
              ).animate(delay: 700.ms).fadeIn(duration: 600.ms),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
                strokeWidth: 4,
              ).animate(delay: 1000.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
