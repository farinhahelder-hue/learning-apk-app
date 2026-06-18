import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// Service de reconnaissance vocale pour la dictée interactive
/// Utilise speech_to_text avec locale fr_FR
class SpeechService extends ChangeNotifier {
  final SpeechToText _stt = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastWords = '';
  double _confidence = 0.0;
  String? _errorMessage;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  double get confidence => _confidence;
  String? get errorMessage => _errorMessage;

  /// Initialiser le service de reconnaissance vocale
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _stt.initialize(
        onStatus: (status) {
          if (kDebugMode) {
            print('STT Status: $status');
          }
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
        onError: (error) {
          if (kDebugMode) {
            print('STT Error: ${error.errorMsg}');
          }
          _errorMessage = _mapErrorMessage(error.errorMsg);
          _isListening = false;
          notifyListeners();
        },
      );

      if (_isInitialized) {
        // Vérifier que le français est disponible
        final locales = await _stt.locales();
        final frenchLocale = locales.firstWhere(
          (l) => l.localeId.startsWith('fr'),
          orElse: () => locales.first,
        );
        if (kDebugMode) {
          print(
              'Using locale: ${frenchLocale.name} (${frenchLocale.localeId})');
        }
      }

      notifyListeners();
      return _isInitialized;
    } catch (e) {
      if (kDebugMode) {
        print('STT Initialization error: $e');
      }
      _errorMessage = 'Impossible d\'initialiser la reconnaissance vocale';
      _isInitialized = false;
      notifyListeners();
      return false;
    }
  }

  String _mapErrorMessage(String errorMsg) {
    switch (errorMsg) {
      case 'error_no_match':
        return 'Je n\'ai pas compris. Réessaie !';
      case 'error_no_speech':
        return 'Je n\'ai rien entendu. Parle plus fort !';
      case 'error_speech_timeout':
        return 'Temps écoulé. Réessaie !';
      case 'error_permission':
        return 'Permission microphone refusée';
      case 'error_not_available':
        return 'Reconnaissance vocale non disponible';
      default:
        return 'Erreur: $errorMsg';
    }
  }

  /// Démarrer l'écoute
  Future<void> startListening({
    required Function(String) onResult,
    String localeId = 'fr_FR',
    Duration listenFor = const Duration(seconds: 10),
  }) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) {
        _errorMessage = 'Reconnaissance vocale non disponible';
        notifyListeners();
        return;
      }
    }

    if (_isListening) {
      await stopListening();
    }

    _errorMessage = null;
    _isListening = true;
    notifyListeners();

    await _stt.listen(
      onResult: (SpeechRecognitionResult result) {
        _lastWords = result.recognizedWords;
        _confidence = result.confidence;

        if (kDebugMode) {
          print(
              'STT Result: "${result.recognizedWords}" (confidence: ${result.confidence})');
        }

        onResult(result.recognizedWords);

        if (result.finalResult) {
          _isListening = false;
          notifyListeners();
        }
      },
      localeId: localeId,
      listenFor: listenFor,
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: false,
      listenMode: ListenMode.confirmation,
    );
  }

  /// Arrêter l'écoute
  Future<void> stopListening() async {
    await _stt.stop();
    _isListening = false;
    notifyListeners();
  }

  /// Annuler l'écoute
  Future<void> cancelListening() async {
    await _stt.cancel();
    _isListening = false;
    _lastWords = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _stt.stop();
    super.dispose();
  }
}
