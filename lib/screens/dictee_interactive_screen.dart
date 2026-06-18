import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/mascot.dart';
import '../../services/speech_service.dart';
import '../../services/tts_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/bounce_button.dart';
import '../../widgets/rive_mascot_widget.dart';

/// Écran de dictée interactive avec reconnaissance vocale
/// 8 mots progressifs avec phonétique IPA
class DicteeInteractiveScreen extends StatefulWidget {
  const DicteeInteractiveScreen({super.key});

  @override
  State<DicteeInteractiveScreen> createState() =>
      _DicteeInteractiveScreenState();
}

class _DicteeInteractiveScreenState extends State<DicteeInteractiveScreen>
    with SingleTickerProviderStateMixin {
  final Mascot _mascot = Mascots.billyBird;
  late SpeechService _speechService;
  late TtsService _ttsService;
  late AnimationController _pulseController;

  // Mots de la dictée avec leur phonétique IPA
  static const List<DicteeWord> _words = [
    DicteeWord(
        word: 'chat',
        ipa: '[ʃa]',
        hint: 'Un animal domestique qui fait "miaou"'),
    DicteeWord(
        word: 'maman', ipa: '[mamɑ̃]', hint: 'Ta maman est la meilleure !'),
    DicteeWord(word: 'pomme', ipa: '[pɔm]', hint: 'Un fruit rouge ou vert'),
    DicteeWord(
        word: 'étoile', ipa: '[etwal]', hint: 'Brille dans le ciel la nuit'),
    DicteeWord(
        word: 'cheval', ipa: '[ʃəval]', hint: 'Un animal avec une crinière'),
    DicteeWord(
        word: 'merci', ipa: '[mɛʁsi]', hint: 'On le dit quand on est poli'),
    DicteeWord(word: 'bateau', ipa: '[bato]', hint: 'Il navigue sur l\'eau'),
    DicteeWord(
        word: 'lune', ipa: '[lyn]', hint: 'Elle brille la nuit dans le ciel'),
  ];

  int _currentIndex = 0;
  int _correctCount = 0;
  bool _isListening = false;
  String _lastTranscript = '';
  bool? _lastResult;
  bool _finished = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _speechService = SpeechService();
    _ttsService = TtsService();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final ok = await _speechService.initialize();
    if (!ok && mounted) {
      setState(() => _permissionDenied = true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  DicteeWord get _currentWord => _words[_currentIndex];

  void _speakWord() {
    _ttsService.speak(_currentWord.word);
  }

  void _repeatWord() {
    _ttsService.speak(_currentWord.word);
  }

  Future<void> _startListening() async {
    if (_isListening) {
      await _speechService.stopListening();
      return;
    }

    setState(() {
      _isListening = true;
      _lastTranscript = '';
      _lastResult = null;
    });

    await _speechService.startListening(
      onResult: (String words) {
        if (words.isNotEmpty) {
          setState(() => _lastTranscript = words);
          _checkAnswer(words);
        }
      },
      localeId: 'fr_FR',
      listenFor: const Duration(seconds: 8),
    );
  }

  void _checkAnswer(String transcript) {
    final normalizedTranscript = transcript.toLowerCase().trim();
    final normalizedWord = _currentWord.word.toLowerCase();

    // Comparaison simple : le mot prononcé contient le mot attendu
    final isCorrect = normalizedTranscript == normalizedWord ||
        normalizedTranscript.contains(normalizedWord) ||
        _calculateSimilarity(normalizedTranscript, normalizedWord) > 0.7;

    setState(() {
      _lastResult = isCorrect;
      if (isCorrect) _correctCount++;
    });

    if (isCorrect) {
      _ttsService.speak('Bravo Emilie ! ${_currentWord.word} !');
    } else {
      _ttsService.speak('Réessaie, tu peux le faire !');
    }

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) _nextWord();
    });
  }

  double _calculateSimilarity(String s1, String s2) {
    if (s1.isEmpty || s2.isEmpty) return 0;

    int matches = 0;
    for (int i = 0; i < s1.length && i < s2.length; i++) {
      if (s1[i] == s2[i]) matches++;
    }
    return matches / s2.length;
  }

  void _nextWord() {
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
        _lastTranscript = '';
        _lastResult = null;
        _isListening = false;
      });
      // Lire le nouveau mot après un petit délai
      Future.delayed(const Duration(milliseconds: 500), _speakWord);
    } else {
      setState(() => _finished = true);
    }
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _correctCount = 0;
      _lastTranscript = '';
      _lastResult = null;
      _isListening = false;
      _finished = false;
    });
    Future.delayed(const Duration(milliseconds: 500), _speakWord);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.frenchGradient,
        ),
        child: SafeArea(
          child: _finished ? _buildResults() : _buildExercise(),
        ),
      ),
    );
  }

  Widget _buildExercise() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      '✏️ Dictée Interactive',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: (_currentIndex + 1) / _words.length,
                      backgroundColor: Colors.white30,
                      color: Colors.white,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_currentIndex + 1} / ${_words.length}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check,
                        color: AppTheme.primaryGreen, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$_correctCount',
                      style: const TextStyle(
                        color: AppTheme.primaryPink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Mascotte
                RiveMascotWidget(
                  mascot: _mascot,
                  mood: _lastResult == null
                      ? MascotMood.thinking
                      : _lastResult == true
                          ? MascotMood.happy
                          : MascotMood.encourage,
                  size: 80,
                  showSpeechBubble: true,
                  speechText: _isListening
                      ? 'Je t\'écoute Emilie ! 🐦🎤'
                      : _lastResult == null
                          ? 'Écoute le mot et répète ! 👂'
                          : _lastResult == true
                              ? 'Super ! Tu as bien prononcé ! 🎉'
                              : 'Réessaie, tu vas y arriver ! 💪',
                ).animate().fadeIn(),

                const SizedBox(height: 24),

                // Instructions ou résultat
                if (_permissionDenied)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.mic_off, color: Colors.red, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'Permission microphone refusée',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Activez le microphone dans les paramètres',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ).animate().shake()
                else ...[
                  // Mot à dicter
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Indice
                        Text(
                          _currentWord.hint,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Bouton pour écouter
                        BounceButton(
                          onTap: _speakWord,
                          color: AppTheme.primaryPink,
                          borderRadius: BorderRadius.circular(30),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.volume_up, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Écouter le mot',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ).animate().scale(),

                        const SizedBox(height: 24),

                        // Phonétique
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primaryBlue),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.record_voice_over,
                                  color: AppTheme.primaryBlue, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Phonétique : ${_currentWord.ipa}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Bouton microphone
                        GestureDetector(
                          onTap: _startListening,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isListening
                                      ? Colors.red
                                      : AppTheme.primaryPink,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isListening
                                              ? Colors.red
                                              : AppTheme.primaryPink)
                                          .withOpacity(0.3 +
                                              (_pulseController.value * 0.3)),
                                      blurRadius:
                                          20 + (_pulseController.value * 20),
                                      spreadRadius:
                                          5 + (_pulseController.value * 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isListening ? Icons.stop : Icons.mic,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isListening
                              ? 'Appuie pour arrêter'
                              : 'Appuie et prononce le mot',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Transcript actuel
                  if (_lastTranscript.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Tu as prononcé :',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"$_lastTranscript"',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_lastResult != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _lastResult!
                                    ? const Color(0xFF81C784)
                                    : const Color(0xFFEF9A9A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _lastResult! ? '✓ Correct !' : '✗ Réessaie',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ).animate().fadeIn(),
                  ],

                  // Bouton répéter
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _repeatWord,
                    icon: const Icon(Icons.replay, color: Colors.white70),
                    label: const Text(
                      'Répéter le mot',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final pct = _correctCount / _words.length;
    final stars = pct >= 0.8 ? 3 : (pct >= 0.5 ? 2 : 1);

    String message;
    String emoji;
    if (pct >= 0.8) {
      message = "Excellente dictée Emilie ! Tu es une championne ! 👑";
      emoji = '🏆';
    } else if (pct >= 0.5) {
      message = "Très bien ! Tu progresses ! Continue comme ça ! 💪";
      emoji = '⭐';
    } else {
      message = "On s'entraîne encore ? Tu vas réussir ! 🎯";
      emoji = '💪';
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RiveMascotWidget(
              mascot: _mascot,
              mood: pct >= 0.5 ? MascotMood.celebrate : MascotMood.happy,
              size: 120,
            ).animate().scale(curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(emoji, style: const TextStyle(fontSize: 80))
                .animate()
                .scale(delay: 300.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Icon(
                  i < stars ? Icons.star : Icons.star_border,
                  size: 48,
                  color: i < stars ? Colors.amber : Colors.white54,
                )
                    .animate(delay: Duration(milliseconds: 400 + i * 150))
                    .scale(curve: Curves.elasticOut);
              }),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$_correctCount / ${_words.length} mots corrects',
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
            const SizedBox(height: 32),
            BounceButton(
              onTap: _restart,
              color: Colors.white,
              shadowColor: Colors.white,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: AppTheme.primaryPink),
                  SizedBox(width: 8),
                  Text(
                    'Rejouer',
                    style: TextStyle(
                      color: AppTheme.primaryPink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 800.ms),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '← Retour au menu',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modèle de mot pour la dictée
class DicteeWord {
  final String word; // Mot à écrire
  final String ipa; // Phonétique IPA
  final String hint; // Indice pour l'élève

  const DicteeWord({
    required this.word,
    required this.ipa,
    required this.hint,
  });
}
