import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../utils/app_theme.dart';
import '../../widgets/bounce_button.dart';
import '../../widgets/rive_mascot_widget.dart';
import '../../models/mascot.dart';

/// Écran de tables de multiplication avec 4 niveaux (2, 3, 4, 5)
/// 10 exercices par niveau avec timer 30s et score 1-3 étoiles
class MultiplicationTablesScreen extends StatefulWidget {
  const MultiplicationTablesScreen({super.key});

  @override
  State<MultiplicationTablesScreen> createState() => _MultiplicationTablesScreenState();
}

class _MultiplicationTablesScreenState extends State<MultiplicationTablesScreen> {
  int? _selectedTable;
  List<MultiplicationExercise> _exercises = [];
  int _current = 0;
  int _score = 0;
  bool _finished = false;
  String? _selectedAnswer;
  bool? _isCorrect;
  Timer? _timer;
  int _remainingSeconds = 30;
  late ConfettiController _confetti;
  final Mascot _mascot = Mascots.barbeNoire;

  static const List<String> _encouragements = [
    "C'est bien, Emilie ! Continue comme ça ! 💪",
    "Super travail ! Tu es sur la bonne voie ! 🌟",
    "Tu te débrouilles très bien ! Courage ! 🎯",
    "Emilie, tu es formidable ! On continue ! ⭐",
    "Bien joué ! Tu apprends vite ! 🚀",
  ];

  static const List<String> _wrongMessages = [
    "Ne t'inquiète pas, on recommence ! 😊",
    "Ce n'est pas grave, courage ! 💪",
    "Emilie, tu vas y arriver ! 🔄",
    "Pas de panique, c'est en forgeant... 🔧",
  ];

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  void _startTable(int table) {
    setState(() {
      _selectedTable = table;
      _exercises = _generateExercises(table);
      _exercises.shuffle();
      _current = 0;
      _score = 0;
      _finished = false;
      _selectedAnswer = null;
      _isCorrect = null;
    });
    _startTimer();
  }

  List<MultiplicationExercise> _generateExercises(int table) {
    final random = Random();
    final exercises = <MultiplicationExercise>[];
    
    for (int i = 1; i <= 10; i++) {
      final multiplier = (random.nextInt(9) + 1); // 1-9 pour varier
      final correctAnswer = table * multiplier;
      
      // Générer 3 distracteurs proches de la bonne réponse
      final distractors = <int>{};
      while (distractors.length < 3) {
        final offset = random.nextInt(5) - 2; // -2 à +2
        final distractor = correctAnswer + offset;
        if (distractor > 0 && distractor != correctAnswer && !distractors.contains(distractor)) {
          distractors.add(distractor);
        }
      }
      
      final options = [correctAnswer, ...distractors].toList()..shuffle();
      
      exercises.add(MultiplicationExercise(
        table: table,
        multiplier: multiplier,
        correctAnswer: correctAnswer,
        options: options,
      ));
    }
    
    return exercises;
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _onTimeOut();
        }
      });
    });
  }

  void _onTimeOut() {
    if (_isCorrect != null) return;
    setState(() {
      _selectedAnswer = null;
      _isCorrect = false;
    });
    _timer?.cancel();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _nextQuestion();
    });
  }

  void _checkAnswer(int answer) {
    if (_isCorrect != null) return;
    _timer?.cancel();
    
    final correct = answer == _exercises[_current].correctAnswer;
    setState(() {
      _selectedAnswer = answer.toString();
      _isCorrect = correct;
      if (correct) _score++;
    });
    
    if (!correct) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) _nextQuestion();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _nextQuestion();
      });
    }
  }

  void _nextQuestion() {
    if (_current < _exercises.length - 1) {
      setState(() {
        _current++;
        _selectedAnswer = null;
        _isCorrect = null;
      });
      _startTimer();
    } else {
      _finish();
    }
  }

  void _finish() {
    _timer?.cancel();
    if (_score == _exercises.length) {
      _confetti.play();
    }
    setState(() => _finished = true);
  }

  int _getStars() {
    final pct = _score / _exercises.length;
    if (pct >= 0.9) return 3;
    if (pct >= 0.6) return 2;
    return 1;
  }

  void _returnToMenu() {
    setState(() {
      _selectedTable = null;
      _exercises = [];
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.mathGradient,
            ),
          ),
          SafeArea(
            child: _selectedTable == null
                ? _buildTableSelection()
                : _finished
                    ? _buildResults()
                    : _buildExercise(),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [Colors.yellow, Colors.orange, Colors.pink, Colors.blue, Colors.green],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSelection() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text(
          '📚 Tables de multiplication',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ).animate().fadeIn().slideY(begin: -0.2),
        const SizedBox(height: 8),
        const Text(
          'Choisis la table que tu veux réviser',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 40),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(20),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [2, 3, 4, 5].map((table) {
              return BounceButton(
                onTap: () => _startTable(table),
                color: Colors.white,
                shadowColor: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Table',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '× $table',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: Duration(milliseconds: 100 * table)).fadeIn().scale();
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(20),
          child: BounceButton(
            onTap: () => Navigator.pop(context),
            color: Colors.white.withOpacity(0.2),
            child: const Text(
              '← Retour',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExercise() {
    final exercise = _exercises[_current];
    final encMsg = _encouragements[DateTime.now().second % _encouragements.length];

    return Column(
      children: [
        // Header avec timer et progression
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => _returnToMenu(),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Table × $_selectedTable',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: (_current + 1) / _exercises.length,
                      backgroundColor: Colors.white30,
                      color: Colors.white,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_current + 1} / ${_exercises.length}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _remainingSeconds <= 10 ? Colors.red : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_remainingSeconds s',
                  style: TextStyle(
                    color: _remainingSeconds <= 10 ? Colors.white : AppTheme.primaryBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Question
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Mascotte avec encouragement
                if (_isCorrect == null)
                  RiveMascotWidget(
                    mascot: _mascot,
                    mood: MascotMood.thinking,
                    size: 80,
                    showSpeechBubble: true,
                    speechText: encMsg,
                  ).animate().fadeIn()
                else if (_isCorrect == true)
                  RiveMascotWidget(
                    mascot: _mascot,
                    mood: MascotMood.happy,
                    size: 80,
                    showSpeechBubble: true,
                    speechText: 'Bravo Emilie ! 🎉',
                  ).animate().scale()
                else
                  RiveMascotWidget(
                    mascot: _mascot,
                    mood: MascotMood.wrong,
                    size: 80,
                    showSpeechBubble: true,
                    speechText: _wrongMessages[DateTime.now().second % _wrongMessages.length],
                  ).animate().shake(),

                const SizedBox(height: 24),

                // Question card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
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
                      Text(
                        '$_selectedTable × ${exercise.multiplier} = ?',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
                      
                      // Feedback
                      if (_isCorrect != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: _isCorrect! ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isCorrect! ? Icons.check_circle : Icons.cancel,
                                color: _isCorrect! ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isCorrect!
                                    ? 'Correct ! La réponse était $_selectedTable × ${exercise.multiplier} = ${exercise.correctAnswer}'
                                    : 'La bonne réponse était ${exercise.correctAnswer}',
                                style: TextStyle(
                                  color: _isCorrect! ? Colors.green.shade700 : Colors.red.shade700,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ).animate().scale(curve: Curves.elasticOut),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Options de réponse
                if (_isCorrect == null)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: exercise.options.asMap().entries.map((entry) {
                      return BounceButton(
                        onTap: () => _checkAnswer(entry.value),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        child: Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ).animate(delay: Duration(milliseconds: 100 * entry.key))
                          .fadeIn()
                          .slideX(begin: 0.1);
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final stars = _getStars();
    final pct = _score / _exercises.length;
    
    String message;
    String emoji;
    if (pct == 1) {
      message = "Parfait Emilie ! Tu es une star ! ⭐⭐⭐";
      emoji = '🏆';
    } else if (pct >= 0.8) {
      message = "Très bien ! Continue comme ça ! 🌟";
      emoji = '🌟';
    } else if (pct >= 0.6) {
      message = "C'est bien, entraîne-toi encore ! 💪";
      emoji = '👍';
    } else {
      message = "Ne lâche rien, on va progresser ! 🚀";
      emoji = '💪';
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mascotte
            RiveMascotWidget(
              mascot: _mascot,
              mood: pct >= 0.8 ? MascotMood.celebrate : MascotMood.happy,
              size: 120,
            ).animate().scale(curve: Curves.elasticOut),

            const SizedBox(height: 24),

            // Emoji résultat
            Text(emoji, style: const TextStyle(fontSize: 80))
                .animate()
                .scale(delay: 300.ms, curve: Curves.elasticOut),

            const SizedBox(height: 16),

            // Étoiles
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Icon(
                  i < stars ? Icons.star : Icons.star_border,
                  size: 48,
                  color: i < stars ? Colors.amber : Colors.white54,
                ).animate(delay: Duration(milliseconds: 400 + i * 150))
                    .scale(curve: Curves.elasticOut);
              }),
            ),

            const SizedBox(height: 24),

            // Message
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
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$_score / ${_exercises.length} bonnes réponses',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  if (_selectedTable != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Table × $_selectedTable',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

            const SizedBox(height: 32),

            // Boutons
            BounceButton(
              onTap: () {
                setState(() {
                  _current = 0;
                  _score = 0;
                  _finished = false;
                  _selectedAnswer = null;
                  _isCorrect = null;
                  _exercises.shuffle();
                });
                _startTimer();
              },
              color: Colors.white,
              shadowColor: Colors.white,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.refresh, color: AppTheme.primaryBlue),
                  SizedBox(width: 8),
                  Text(
                    'Rejouer',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 800.ms),

            const SizedBox(height: 12),

            BounceButton(
              onTap: _returnToMenu,
              color: Colors.white.withOpacity(0.2),
              child: const Text(
                'Choisir une autre table',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ).animate().fadeIn(delay: 900.ms),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '← Retour au menu maths',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modèle d'exercice de multiplication
class MultiplicationExercise {
  final int table;
  final int multiplier;
  final int correctAnswer;
  final List<int> options;

  MultiplicationExercise({
    required this.table,
    required this.multiplier,
    required this.correctAnswer,
    required this.options,
  });
}