import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Réglages de confort sensoriel, persistés via SharedPreferences.
/// Indépendant des réglages son/musique (voir AudioService).
class AccessibilitySettingsService extends ChangeNotifier {
  final SharedPreferences _prefs;

  bool _calmModeEnabled = false;
  bool _showThinkingTimer = false;

  AccessibilitySettingsService(this._prefs) {
    _calmModeEnabled = _prefs.getBool('calm_mode') ?? false;
    _showThinkingTimer = _prefs.getBool('show_timer') ?? false;
  }

  /// Réduit les confettis, vibrations et animations, adoucit les couleurs.
  bool get calmModeEnabled => _calmModeEnabled;

  /// Affiche un minuteur visuel doux pendant les exercices (désactivé par
  /// défaut : un minuteur, même doux, peut être contre-productif pour
  /// certains profils TDAH).
  bool get showThinkingTimer => _showThinkingTimer;

  Future<void> setCalmMode(bool value) async {
    _calmModeEnabled = value;
    await _prefs.setBool('calm_mode', value);
    notifyListeners();
  }

  Future<void> setShowThinkingTimer(bool value) async {
    _showThinkingTimer = value;
    await _prefs.setBool('show_timer', value);
    notifyListeners();
  }

  Future<void> toggleCalmMode() => setCalmMode(!_calmModeEnabled);
  Future<void> toggleThinkingTimer() => setShowThinkingTimer(!_showThinkingTimer);
}
