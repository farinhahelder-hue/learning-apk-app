import 'package:flutter/services.dart';

/// Vibrations de l'application, coupables d'un seul endroit.
///
/// Certaines personnes vivent le retour haptique comme une agression
/// sensorielle, d'autres s'en servent au contraire pour s'ancrer. Le
/// réglage est donc un vrai interrupteur, pas un effet de bord du mode
/// calme : Emilie peut garder les animations en coupant les vibrations,
/// ou l'inverse.
///
/// [enabled] est piloté par AccessibilitySettingsService, qui le remet à
/// jour à chaque changement. Rien d'autre ne doit y toucher.
class AppHaptics {
  const AppHaptics._();

  static bool enabled = true;

  static void light() {
    if (enabled) HapticFeedback.lightImpact();
  }

  static void medium() {
    if (enabled) HapticFeedback.mediumImpact();
  }

  static void heavy() {
    if (enabled) HapticFeedback.heavyImpact();
  }

  static void selection() {
    if (enabled) HapticFeedback.selectionClick();
  }
}
