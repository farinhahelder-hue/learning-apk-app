import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/mascot.dart';
import '../services/audio_service.dart';
import '../utils/app_theme.dart';
import '../utils/new_worlds_curriculum.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/thinking_timer.dart';
import '../widgets/bounce_button.dart';

/// Écran générique pour les nouveaux mondes de découverte
/// (Animaux, Émotions, Géo, Histoire, Univers, Faits incroyables)
/// Intègre : mascotte animée, timer, TTS, confettis, Monika pipipipi
class DiscoveryWorldScreen extends StatefulWidget {
  final Map<String, dynamic> world; // depuis NewWorldsCurriculum.worlds

  const DiscoveryWorldScreen({super.key, required this.world});

  @override
  State<DiscoveryWorldScreen> createState() => _DiscoveryWorldScreenState();
}

class _DiscoveryWorldScreenState extends State<DiscoveryWorldScreen> {
  final _confettiKey = GlobalKey<ConfettiOverlayState>();
  final _timerKey = GlobalKey<ThinkingTimerState>();

  late List<Map<String, dynamic>> _questions;
  late Mascot _mascot;
  int _currentIndex = 0;
  int _score = 0;
  MascotMood _mood = MascotMood.idle;
  String? _speechText;
  String? _selectedAnswer;
  bool _answered = false;
  bool _showFunFact = false;

  @override
  void initState() {
    super.initState();
    _questions = List.from(
        (widget.world['questions'] as List).cast<Map<String, dynamic>>());
    _questions.shuffle();
    final mascotId = widget.world['mascotId'] as String;
    _mascot = Mascots.all.firstWhere(
      (m) => m.id == mascotId,
      orElse: () => Mascots.papaSeal,
    );
    _showCurrentQuestion();
  }

  void _showCurrentQuestion() {
    if (_currentIndex >= _questions.length) return;
    final q = _questions[_currentIndex];
    setState(() {
      _mood = MascotMood.thinking;
      _speechText =
          _mascot.thinkPhrases[_currentIndex % _mascot.thinkPhrases.length];
      _selectedAnswer = null;
      _answered = false;
      _showFunFact = false;
    });
    _timerKey.currentState?.reset();
    // Optionnel : lire la question via TTS
    // context.read<TtsService>().readQuestion(q['question']);
  }

  void _onAnswerSelected(String answer) {
    if (_answered) return;
    final correct = _questions[_currentIndex]['answer'] as String;
    final isCorrect = answer == correct;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      _showFunFact = true;
      _mood = isCorrect ? MascotMood.happy : MascotMood.wrong;
      _speechText = isCorrect
          ? _mascot.correctPhrases[_score % _mascot.correctPhrases.length]
          : _mascot.wrongPhrases[_currentIndex % _mascot.wrongPhrases.length];
      if (isCorrect) _score++;
    });

    _timerKey.currentState?.stop();
    HapticFeedback.mediumImpact();

    final audio = context.read<AudioService>();
    if (isCorrect) {
      audio.onCorrectAnswer();
      _confettiKey.currentState?.burst();
    } else {
      audio.onWrongAnswer();
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
      _showCurrentQuestion();
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final audio = context.read<AudioService>();
    audio.onPerfect();
    _confettiKey.currentState?.burst();
    setState(() {
      _mood = MascotMood.celebrate;
      _speechText =
          '${_score} / ${_questions.length} — ${_score == _questions.length ? "PARFAIT ! 🌟" : "Bien joué ! ⭐"}';
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        score: _score,
        total: _questions.length,
        worldTitle: widget.world['title'] as String,
        mascot: _mascot,
        onRetry: () {
          Navigator.pop(context);
          setState(() {
            _currentIndex = 0;
            _score = 0;
          });
          _questions.shuffle();
          _showCurrentQuestion();
        },
        onExit: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q =
        _currentIndex < _questions.length ? _questions[_currentIndex] : null;
    final worldColor = Color(widget.world['color'] as int);

    return Scaffold(
      body: Stack(
        children: [
          // Fond dégradé
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  worldColor.withOpacity(0.15),
                  AppTheme.backgroundLight
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Contenu principal
          SafeArea(
            child: Column(
              children: [
                // Header
                _Header(
                  world: widget.world,
                  current: _currentIndex + 1,
                  total: _questions.length,
                  score: _score,
                  worldColor: worldColor,
                  onBack: () => Navigator.pop(context),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // Mascotte + bulle
                        MascotWidget(
                          mascot: _mascot,
                          mood: _mood,
                          size: 110,
                          showSpeechBubble: _speechText != null,
                          speechText: _speechText,
                        ).animate().fadeIn(duration: 400.ms),

                        const SizedBox(height: 20),

                        // Timer + Question
                        if (q != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ThinkingTimer(
                                key: _timerKey,
                                seconds: 30,
                                size: 60,
                                autoStart: !_answered,
                                onEnd: () {
                                  if (!_answered) {
                                    _onAnswerSelected('__timeout__');
                                  }
                                },
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  '${q['emoji']} ${q['question']}',
                                  style: AppTheme.subheadingStyle.copyWith(
                                    fontSize: 19,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          )
                              .animate()
                              .fadeIn(duration: 500.ms)
                              .slideY(begin: -0.1),

                          const SizedBox(height: 24),

                          // Choix de réponses
                          ...((q['choices'] as List).cast<String>()).map(
                            (choice) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _AnswerButton(
                                text: choice,
                                state: _answered
                                    ? (choice == q['answer']
                                        ? _AnswerState.correct
                                        : choice == _selectedAnswer
                                            ? _AnswerState.wrong
                                            : _AnswerState.neutral)
                                    : _AnswerState.neutral,
                                onTap: () => _onAnswerSelected(choice),
                              ),
                            ),
                          ),

                          // Fun Fact après réponse
                          if (_showFunFact && q.containsKey('funFact'))
                            _FunFactCard(
                              text: q['funFact'] as String,
                              color: worldColor,
                            )
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .slideY(begin: 0.2),

                          if (_showFunFact && q.containsKey('lesson'))
                            _FunFactCard(
                              text: q['lesson'] as String,
                              color: const Color(0xFFFFCA28),
                              icon: '💛',
                            )
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .slideY(begin: 0.2),

                          const SizedBox(height: 16),

                          // Bouton Suivant
                          if (_answered)
                            BounceButton(
                              color: worldColor,
                              onTap: _nextQuestion,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentIndex < _questions.length - 1
                                        ? 'Question suivante →'
                                        : 'Voir les résultats 🏆',
                                    style: AppTheme.buttonStyle
                                        .copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 400.ms),

                          const SizedBox(height: 32),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Confettis overlay
          ConfettiOverlay(key: _confettiKey),
        ],
      ),
    );
  }
}

// ── Widgets internes ─────────────────────────────────────────

enum _AnswerState { neutral, correct, wrong }

class _AnswerButton extends StatelessWidget {
  final String text;
  final _AnswerState state;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    IconData? icon;

    switch (state) {
      case _AnswerState.correct:
        bg = const Color(0xFFE8F5E9);
        border = const Color(0xFF4CAF50);
        icon = Icons.check_circle;
        break;
      case _AnswerState.wrong:
        bg = const Color(0xFFFFEBEE);
        border = const Color(0xFFF44336);
        icon = Icons.cancel;
        break;
      case _AnswerState.neutral:
        bg = Colors.white;
        border = const Color(0xFFE0E0E0);
        icon = null;
    }

    return GestureDetector(
      onTap: state == _AnswerState.neutral ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 2),
          boxShadow: [
            BoxShadow(
              color: border
                  .withOpacity(state == _AnswerState.neutral ? 0.1 : 0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon,
                  color: state == _AnswerState.correct
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF44336),
                  size: 24),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                text,
                style: AppTheme.bodyStyle.copyWith(
                  color: state == _AnswerState.neutral
                      ? AppTheme.textDark
                      : state == _AnswerState.correct
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FunFactCard extends StatelessWidget {
  final String text;
  final Color color;
  final String icon;

  const _FunFactCard({
    required this.text,
    required this.color,
    this.icon = '🤩',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.35), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 15,
                color: color.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Map<String, dynamic> world;
  final int current;
  final int total;
  final int score;
  final Color worldColor;
  final VoidCallback onBack;

  const _Header({
    required this.world,
    required this.current,
    required this.total,
    required this.score,
    required this.worldColor,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${world['emoji']} ${world['title']}',
                  style: AppTheme.subheadingStyle.copyWith(fontSize: 17),
                ),
                // Barre de progression Duolingo
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: current / total,
                    minHeight: 10,
                    backgroundColor: worldColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(worldColor),
                  ),
                ),
                Text('$current / $total  •  ⭐ $score pts',
                    style: AppTheme.captionStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultDialog extends StatelessWidget {
  final int score;
  final int total;
  final String worldTitle;
  final Mascot mascot;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const _ResultDialog({
    required this.score,
    required this.total,
    required this.worldTitle,
    required this.mascot,
    required this.onRetry,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final pct = score / total;
    final stars = pct == 1.0
        ? 3
        : pct >= 0.7
            ? 2
            : 1;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('★' * stars + '☆' * (3 - stars),
                style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text('$score / $total', style: AppTheme.headingStyle),
            const SizedBox(height: 4),
            Text(worldTitle, style: AppTheme.captionStyle),
            const SizedBox(height: 16),
            MascotWidget(
              mascot: mascot,
              mood:
                  score == total ? MascotMood.celebrate : MascotMood.encourage,
              size: 90,
              showSpeechBubble: true,
              speechText: score == total
                  ? mascot.correctPhrases[0]
                  : mascot.encouragementPhrase ?? mascot.idlePhrases[0],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: BounceButton(
                    color: Colors.grey.shade200,
                    shadowColor: Colors.grey,
                    onTap: onRetry,
                    child: Text('🔄 Rejouer',
                        style: AppTheme.buttonStyle
                            .copyWith(color: AppTheme.textDark)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BounceButton(
                    color: const Color(0xFF4FC3F7),
                    onTap: onExit,
                    child: Text('🏠 Accueil',
                        style:
                            AppTheme.buttonStyle.copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension on Mascot {
  String? get encouragementPhrase =>
      wrongPhrases.isNotEmpty ? wrongPhrases.last : null;
}
