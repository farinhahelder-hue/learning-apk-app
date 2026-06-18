import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/bounce_button.dart';
import '../../widgets/rive_mascot_widget.dart';
import '../../models/mascot.dart';
import '../../services/audio_service.dart';

/// Mode de jeu pour les tables de multiplication
enum MultiplicationMode {
  separated,  // Une table à la fois (×2, ×3, ×4, ×5)
  mixed,       // Mélange de toutes les tables
}

/// Écran de tables de multiplication avec 2 modes:
/// - Mode séparé: une table à la fois
/// - Mode mixte: mélange de toutes les tables
class MultiplicationTablesScreen extends StatefulWidget {
  const MultiplicationTablesScreen({super.key});

  @override
  State<MultiplicationTablesScreen> createState() => _MultiplicationTablesScreenState();
}

class _MultiplicationTablesScreenState extends State<MultiplicationTablesScreen> {
  MultiplicationMode _mode = MultiplicationMode.separated;
  int? _selectedTable;
  List<MultiplicationExercise> _exercises = [];
  int _current = 0;
  int _score = 0;
  bool _finished = false;
  bool? _isCorrect;
  Timer? _timer;
  int _remainingSeconds = 30;
  late ConfettiController _confetti;
  final Mascot _mascot = Mascots.barbeNoire;
  
  // Compteur de série (streak)
  int _streak = 0;
  bool _showStreakBadge = false;

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

  void _selectMode(MultiplicationMode mode) {
    setState(() {
      _mode = mode;
      if (mode == MultiplicationMode.mixed) {
        _startMixedMode();
      }
    });
  }

  void _startMixedMode() {
    final random = Random();
    final exercises = <MultiplicationExercise>[];
    final tables = [2, 3, 4, 5];
    
    // Générer 15 exercices pour le mode mixte (plus dynamique)
    for (int i = 0; i < 15; i++) {
      final table = tables[random.nextInt(tables.length)];
      final multiplier = random.nextInt(9) + 1;
      final correctAnswer = table * multiplier;
      
      final distractors = <int>{};
      while (distractors.length < 3) {
        final offset = random.nextInt(5) - 2;
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
    
    setState(() {
      _exercises = exercises;
      _selectedTable = null; // Mixte n'a pas de table spécifique
      _current = 0;
      _score = 0;
      _finished = false;
      _streak = 0;
      _isCorrect = null;
    });
    _startTimer();
  }

  void _startTable(int table) {
    setState(() {
      _selectedTable = table;
      _exercises = _generateExercises(table);
      _exercises.shuffle();
      _current = 0;
      _score = 0;
      _finished = false;
      _streak = 0;
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
      _isCorrect = false;
      _streak = 0;
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
    final audio = context.read<AudioService>();
    
    setState(() {
      _isCorrect = correct;
      if (correct) {
        _score++;
        _streak++;
        // Sons et confettis pour bonne réponse
        if (_streak >= 3) {
          _confetti.play();
          audio.onStreak(); // Son confettis
          _showStreakBadge = true;
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _showStreakBadge = false);
          });
        } else {
          audio.onCorrectAnswer(); // Son succès
        }
      } else {
        _streak = 0;
        audio.onWrongAnswer(); // Son erreur
      }
    });
    
    if (!correct) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) _nextQuestion();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _nextQuestion();
      });
    }
  }

  void _nextQuestion() {
    if (_current < _exercises.length - 1) {
      setState(() {
        _current++;
        _isCorrect = null;
      });
      _startTimer();
    } else {
      _finish();
    }
  }

  void _finish() {
    _timer?.cancel();
    final audio = context.read<AudioService>();
    // Animation boss final si score parfait ou > 80%
    final pct = _score / _exercises.length;
    if (pct >= 0.8) {
      _confetti.play();
      audio.onPerfect(); // Son niveau terminé + applaudissements
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
      _mode = MultiplicationMode.separated;
      _selectedTable = null;
      _exercises = [];
      _finished = false;
      _streak = 0;
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
            child: _selectedTable == null && _exercises.isEmpty
                ? _buildModeSelection()
                : _finished
                    ? _buildResults()
                    : _buildExercise(),
          ),
          // Confettis
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [Colors.yellow, Colors.orange, Colors.pink, Colors.blue, Colors.green],
            ),
          ),
          // Badge streak
          if (_showStreakBadge)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        '$_streak de suite !',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .scale(begin: const Offset(0, 0), curve: Curves.elasticOut)
                    .shake(duration: 500.ms, hz: 3),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeSelection() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text(
          '🎯 Maths Express',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ).animate().fadeIn().slideY(begin: -0.2),
        const SizedBox(height: 8),
        const Text(
          'Choisis ton défi !',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 40),
        
        // Mode Séparé
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: BounceButton(
            onTap: () => _selectMode(MultiplicationMode.separated),
            color: Colors.white,
            shadowColor: AppTheme.primaryBlue,
            borderRadius: BorderRadius.circular(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🎯', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mode Séparé',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choisis une table (×2, ×3, ×4 ou ×5)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.primaryBlue),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
        
        const SizedBox(height: 16),
        
        // Mode Mixte
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: BounceButton(
            onTap: () => _selectMode(MultiplicationMode.mixed),
            color: Colors.amber,
            shadowColor: Colors.orange,
            borderRadius: BorderRadius.circular(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('⚡', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mode Mixte',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '15 questions de toutes les tables !',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.orange),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
        
        const SizedBox(height: 40),
        
        // Si mode séparé, montrer les tables
        if (_mode == MultiplicationMode.separated)
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
                          fontSize: 14,
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '× $table',
                        style: TextStyle(
                          fontSize: 40,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Indicateur streak
                        if (_streak > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔥', style: TextStyle(fontSize: 14)),
                                Text(
                                  '$_streak',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().scale(),
                        Text(
                          _selectedTable != null 
                              ? 'Table × $_selectedTable' 
                              : 'Mode Mixte ⚡',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_current + 1) / _exercises.length,
                        backgroundColor: Colors.white30,
                        color: Colors.white,
                        minHeight: 6,
                      ),
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
              )
                  .animate(target: _remainingSeconds <= 5 ? 1 : 0)
                  .shake(duration: 300.ms),
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
                    speechText: _streak >= 3 ? 'Incroyable Emilie ! 🔥' : 'Bravo Emilie ! 🎉',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${exercise.table}',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const Text(
                            ' × ',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textLight,
                            ),
                          ),
                          Text(
                            '${exercise.multiplier}',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const Text(
                            ' = ?',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
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
                                    ? 'Correct ! ${exercise.table} × ${exercise.multiplier} = ${exercise.correctAnswer}'
                                    : 'La réponse était ${exercise.correctAnswer}',
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
    final isPerfect = pct == 1.0;
    final isBossDefeated = pct >= 0.8;
    
    String message;
    String emoji;
    if (isPerfect) {
      message = "Parfait Emilie ! Tu es une star ! ⭐⭐⭐";
      emoji = '🏆';
    } else if (pct >= 0.8) {
      message = "Boss vaincu ! Excellent travail ! 🎉";
      emoji = '🎉';
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
            // Animation boss final si réussi
            if (isBossDefeated)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('⚔️', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text(
                      'BOSS VAINCU !',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .scale(begin: const Offset(0, 0), curve: Curves.elasticOut, delay: 200.ms)
                  .shake(duration: 800.ms, hz: 2),

            const SizedBox(height: 24),

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

            // Étoiles animées
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
                  ] else ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Mode Mixte ⚡',
                      style: TextStyle(
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
                if (_selectedTable != null) {
                  // Mode séparé : rejouer la même table
                  setState(() {
                    _current = 0;
                    _score = 0;
                    _finished = false;
                    _streak = 0;
                    _isCorrect = null;
                    _exercises.shuffle();
                  });
                } else {
                  // Mode mixte : recommencer
                  _startMixedMode();
                  return;
                }
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