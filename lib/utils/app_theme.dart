import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue   = Color(0xFF4FC3F7);
  static const Color primaryPink   = Color(0xFFFF80AB);
  static const Color primaryYellow = Color(0xFFFFD54F);
  static const Color primaryGreen  = Color(0xFF81C784);
  static const Color primaryOrange = Color(0xFFFFB74D);
  static const Color primaryPurple = Color(0xFFCE93D8);
  static const Color backgroundLight = Color(0xFFFFF9F0);
  static const Color cardWhite    = Color(0xFFFFFFFF);
  static const Color textDark     = Color(0xFF2D3436);
  static const Color textGrey     = Color(0xFF636E72);
  static const Color mathColor    = Color(0xFF4FC3F7);
  static const Color frenchColor  = Color(0xFFFF80AB);
  static const Color scienceColor = Color(0xFF81C784);

  static const LinearGradient mathGradient = LinearGradient(
    colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient frenchGradient = LinearGradient(
    colors: [Color(0xFFFF80AB), Color(0xFFE91E63)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient scienceGradient = LinearGradient(
    colors: [Color(0xFF81C784), Color(0xFF388E3C)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient homeGradient = LinearGradient(
    colors: [Color(0xFFFFF9F0), Color(0xFFE3F2FD)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );

  // ── Styles de texte accessibles (dyslexie / neurodivergences) ──
  static const TextStyle headingStyle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: textDark,
    height: 1.6,
    letterSpacing: 0.3,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: textDark,
    height: 1.6,
    letterSpacing: 0.2,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textDark,
    height: 1.6,
    letterSpacing: 0.1,
  );

  static const TextStyle captionStyle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textGrey,
    height: 1.5,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
      ),
      fontFamily: 'Nunito',
      scaffoldBackgroundColor: backgroundLight,
      textTheme: const TextTheme(
        displayLarge:  headingStyle,
        titleLarge:    subheadingStyle,
        bodyLarge:     bodyStyle,
        bodyMedium:    bodyStyle,
        labelLarge:    buttonStyle,
        bodySmall:     captionStyle,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito', fontSize: 22,
          fontWeight: FontWeight.w800, color: textDark,
          height: 1.4,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: buttonStyle,
          elevation: 4,
          shadowColor: primaryBlue.withOpacity(0.4),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadowColor: Colors.black.withOpacity(0.1),
      ),
    );
  }
}
