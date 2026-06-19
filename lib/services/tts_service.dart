import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// Service Text-To-Speech via le channel natif Android/iOS
/// Lit les questions, consignes et textes à voix haute
/// Compatible dyslexie : lecture automatique disponible
class TtsService extends ChangeNotifier {
  static const _channel = MethodChannel('com.emilieapp/tts');
  bool _enabled = true;
  bool _isSpeaking = false;
  double _speechRate = 0.45; // plus lent pour les enfants
  double _pitch = 1.1; // légèrement aigu, plus enfantin
  String _language = 'fr-FR';

  bool get enabled => _enabled;
  bool get isSpeaking => _isSpeaking;
  double get speechRate => _speechRate;

  /// Lire un texte à voix haute
  Future<void> speak(String text) async {
    if (!_enabled || text.isEmpty) return;
    try {
      _isSpeaking = true;
      notifyListeners();
      await _channel.invokeMethod('speak', {
        'text': text,
        'lang': _language,
        'rate': _speechRate,
        'pitch': _pitch,
      });
    } on PlatformException catch (e) {
      debugPrint('TTS error: $e');
      // Fallback silencieux — l'app continue sans TTS
    } finally {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// Arrêter la lecture
  Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } catch (_) {}
    _isSpeaking = false;
    notifyListeners();
  }

  /// Lire la question (préfixe adapté à l'exercice)
  Future<void> readQuestion(String question,
      {String prefix = 'Question :'}) async {
    await speak('$prefix $question');
  }

  /// Lire le feedback (bonne/mauvaise réponse)
  Future<void> readFeedback(String message) async {
    await speak(message);
  }

  void toggle() {
    _enabled = !_enabled;
    notifyListeners();
  }

  void setSpeechRate(double rate) {
    _speechRate = rate.clamp(0.1, 1.0);
    notifyListeners();
  }
}
