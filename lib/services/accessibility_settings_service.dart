import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/haptics.dart';

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
  bool _letterBlocksEnabled = false;
  bool _hapticsEnabled = true;
  SensoryProfile _profile = SensoryProfile.normal;
  double _voiceRate = 0.45;
  double _textScale = 1.0;

  AccessibilitySettingsService(this._prefs) {
    _calmModeEnabled = _prefs.getBool('calm_mode') ?? false;
    _showThinkingTimer = _prefs.getBool('show_timer') ?? false;
    _animationsEnabled = _prefs.getBool('animations_on') ?? true;
    _autoReadEnabled = _prefs.getBool('auto_read') ?? false;
    _letterBlocksEnabled = _prefs.getBool('letter_blocks') ?? false;
    _hapticsEnabled = _prefs.getBool('haptics_on') ?? true;
    _voiceRate = _prefs.getDouble('voice_rate') ?? 0.45;
    _textScale = _prefs.getDouble('text_scale') ?? 1.0;
    AppHaptics.enabled = _hapticsEnabled;
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

  /// Dictée image : regrouper les digrammes (ch, ou, eau…) en blocs plutôt
  /// que de proposer les lettres une par une. C'est une option pédagogique
  /// à essayer avec Emilie, pas une règle fixe.
  bool get letterBlocksEnabled => _letterBlocksEnabled;

  /// Vibrations du téléphone. Certaines personnes s'en servent pour
  /// s'ancrer, d'autres les vivent comme une agression : c'est un
  /// interrupteur à part entière, pas un effet du mode calme.
  bool get hapticsEnabled => _hapticsEnabled;

  /// Facteur de taille du texte, appliqué à toute l'application.
  double get textScale => _textScale;

  String get textScaleLabel {
    if (_textScale <= 0.95) return 'Petit';
    if (_textScale <= 1.05) return 'Normal';
    if (_textScale <= 1.25) return 'Grand';
    return 'Très grand';
  }

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

  Future<void> setLetterBlocks(bool value) async {
    _letterBlocksEnabled = value;
    await _prefs.setBool('letter_blocks', value);
    notifyListeners();
  }

  Future<void> toggleLetterBlocks() => setLetterBlocks(!_letterBlocksEnabled);

  Future<void> setHaptics(bool value) async {
    _hapticsEnabled = value;
    AppHaptics.enabled = value;
    await _prefs.setBool('haptics_on', value);
    notifyListeners();
  }

  Future<void> setTextScale(double value) async {
    _textScale = value.clamp(0.9, 1.4);
    await _prefs.setDouble('text_scale', _textScale);
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
  Future<void> toggleHaptics() => setHaptics(!_hapticsEnabled);

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
        _hapticsEnabled = false;
        _voiceRate = 0.35;
        break;
      case SensoryProfile.normal:
        _calmModeEnabled = false;
        _animationsEnabled = true;
        _autoReadEnabled = false;
        _hapticsEnabled = true;
        _voiceRate = 0.45;
        break;
      case SensoryProfile.dynamique:
        _calmModeEnabled = false;
        _animationsEnabled = true;
        _autoReadEnabled = false;
        _hapticsEnabled = true;
        _voiceRate = 0.55;
        break;
    }
    AppHaptics.enabled = _hapticsEnabled;
    await _prefs.setString('sensory_profile', p.id);
    await _prefs.setBool('calm_mode', _calmModeEnabled);
    await _prefs.setBool('animations_on', _animationsEnabled);
    await _prefs.setBool('auto_read', _autoReadEnabled);
    await _prefs.setBool('haptics_on', _hapticsEnabled);
    await _prefs.setDouble('voice_rate', _voiceRate);
    notifyListeners();
  }
}
