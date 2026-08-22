import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Service Text-To-Speech via le moteur système Android (offline)
/// Lit les questions, consignes et textes à voix haute
/// Compatible dyslexie : lecture automatique disponible
class TtsService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  bool _enabled = true;
  bool _isSpeaking = false;
  double _speechRate = 0.45;  // plus lent pour les enfants
  double _pitch = 1.1;        // légèrement aigu, plus enfantin
  final String _language = 'fr-FR';
  bool _ready = false;

  bool get enabled  => _enabled;
  bool get isSpeaking => _isSpeaking;
  double get speechRate => _speechRate;

  TtsService() {
    _init();
  }

  Future<void> _init() async {
    try {
      await _tts.setLanguage(_language);
      await _tts.setSpeechRate(_speechRate);
      await _tts.setPitch(_pitch);
      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });
      _ready = true;
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  /// Lire un texte à voix haute
  Future<void> speak(String text) async {
    if (!_enabled || text.isEmpty || !_ready) return;
    try {
      _isSpeaking = true;
      notifyListeners();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS error: $e');
      // Fallback silencieux — l'app continue sans TTS
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// Arrêter la lecture
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _isSpeaking = false;
    notifyListeners();
  }

  /// Lire la question (préfixe adapté à l'exercice)
  Future<void> readQuestion(String question, {String prefix = 'Question :'}) async {
    await speak('$prefix $question');
  }

  /// Lire le feedback (bonne/mauvaise réponse)
  Future<void> readFeedback(String message) async {
    await speak(message);
  }

  void toggle() {
    _enabled = !_enabled;
    if (!_enabled) stop();
    notifyListeners();
  }

  void setSpeechRate(double rate) {
    _speechRate = rate.clamp(0.1, 1.0);
    if (_ready) _tts.setSpeechRate(_speechRate);
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
