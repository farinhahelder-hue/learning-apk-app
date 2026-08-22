import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Profils sensoriels prédéfinis. Chaque profil règle d'un coup les
/// animations, la vitesse de voix et le niveau de stimulation, mais chaque
/// réglage reste ensuite modifiable indépendamment.
enum SensoryProfile { doux, normal, dynamique }

extension SensoryProfileInfo on SensoryProfile {
  String get id => name;

  String get label => switch (this) {
        SensoryProfile.doux => 'Doux',
        SensoryProfile.normal => 'Normal',
        SensoryProfile.dynamique => 'Dynamique',
      };

  String get emoji => switch (this) {
        SensoryProfile.doux => '🌙',
        SensoryProfile.normal => '🌤️',
        SensoryProfile.dynamique => '🎉',
      };

  String get description => switch (this) {
        SensoryProfile.doux =>
          'Sons faibles, animations lentes, couleurs pastel. Pour les moments de fatigue ou de surcharge.',
        SensoryProfile.normal =>
          'Voix, musique légère et animations modérées. Le réglage de tous les jours.',
        SensoryProfile.dynamique =>
          'Sons plus présents, animations complètes, récompenses animées. Pour les jours en forme !',
      };
}

/// Réglages de confort sensoriel, persistés via SharedPreferences.
/// Indépendants des volumes son/musique (voir AudioService) : Emilie peut
/// garder les animations en coupant la musique, ou l'inverse.
class AccessibilitySettingsService extends ChangeNotifier {
  final SharedPreferences _prefs;

  bool _calmModeEnabled = false;
  bool _showThinkingTimer = false;
  bool _animationsEnabled = true;
  bool _autoReadEnabled = false;
  SensoryProfile _profile = SensoryProfile.normal;
  double _voiceRate = 0.45;

  AccessibilitySettingsService(this._prefs) {
    _calmModeEnabled = _prefs.getBool('calm_mode') ?? false;
    _showThinkingTimer = _prefs.getBool('show_timer') ?? false;
    _animationsEnabled = _prefs.getBool('animations_on') ?? true;
    _autoReadEnabled = _prefs.getBool('auto_read') ?? false;
    _voiceRate = _prefs.getDouble('voice_rate') ?? 0.45;
    final saved = _prefs.getString('sensory_profile');
    _profile = SensoryProfile.values.firstWhere(
      (p) => p.id == saved,
      orElse: () => SensoryProfile.normal,
    );
  }

  // ── Getters ────────────────────────────────────────────────
  /// Réduit les confettis, vibrations fortes et couleurs vives.
  bool get calmModeEnabled => _calmModeEnabled;

  /// Minuteur visuel doux pendant les exercices. Désactivé par défaut :
  /// un minuteur, même doux, peut être contre-productif pour certains
  /// profils TDAH.
  bool get showThinkingTimer => _showThinkingTimer;

  /// Anime les transitions et les personnages. Peut être coupé
  /// indépendamment du son.
  bool get animationsEnabled => _animationsEnabled;

  /// Lit automatiquement la consigne à voix haute à chaque question.
  bool get autoReadEnabled => _autoReadEnabled;

  SensoryProfile get profile => _profile;

  /// Vitesse de lecture : 0.30 (très lente) à 0.55 (normale).
  double get voiceRate => _voiceRate;

  String get voiceRateLabel {
    if (_voiceRate <= 0.32) return 'Très lente';
    if (_voiceRate <= 0.42) return 'Lente';
    return 'Normale';
  }

  // ── Réglages individuels ───────────────────────────────────
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

  Future<void> setAnimationsEnabled(bool value) async {
    _animationsEnabled = value;
    await _prefs.setBool('animations_on', value);
    notifyListeners();
  }

  Future<void> setAutoRead(bool value) async {
    _autoReadEnabled = value;
    await _prefs.setBool('auto_read', value);
    notifyListeners();
  }

  Future<void> setVoiceRate(double value) async {
    _voiceRate = value.clamp(0.25, 0.60);
    await _prefs.setDouble('voice_rate', _voiceRate);
    notifyListeners();
  }

  Future<void> toggleCalmMode() => setCalmMode(!_calmModeEnabled);
  Future<void> toggleThinkingTimer() => setShowThinkingTimer(!_showThinkingTimer);
  Future<void> toggleAnimations() => setAnimationsEnabled(!_animationsEnabled);
  Future<void> toggleAutoRead() => setAutoRead(!_autoReadEnabled);

  // ── Profils ────────────────────────────────────────────────
  /// Applique un profil : règle d'un coup calme, animations et voix.
  /// Les réglages restent modifiables un par un ensuite.
  Future<void> applyProfile(SensoryProfile p) async {
    _profile = p;
    switch (p) {
      case SensoryProfile.doux:
        _calmModeEnabled = true;
        _animationsEnabled = false;
        _autoReadEnabled = true;
        _voiceRate = 0.35;
        break;
      case SensoryProfile.normal:
        _calmModeEnabled = false;
        _animationsEnabled = true;
        _autoReadEnabled = false;
        _voiceRate = 0.45;
        break;
      case SensoryProfile.dynamique:
        _calmModeEnabled = false;
        _animationsEnabled = true;
        _autoReadEnabled = false;
        _voiceRate = 0.55;
        break;
    }
    await _prefs.setString('sensory_profile', p.id);
    await _prefs.setBool('calm_mode', _calmModeEnabled);
    await _prefs.setBool('animations_on', _animationsEnabled);
    await _prefs.setBool('auto_read', _autoReadEnabled);
    await _prefs.setDouble('voice_rate', _voiceRate);
    notifyListeners();
  }
}
