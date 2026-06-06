import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/mascot.dart';
import '../../services/tts_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/bounce_button.dart';
import '../../widgets/rive_mascot_widget.dart';

/// Écran d'exercices de phonétique française CE1
/// 6 sons à discrimination : [a], [o], [ɛ], [j], [ã], [ʃ]
class PhonetiqueScreen extends StatefulWidget {
  const PhonetiqueScreen({super.key});

  @override
  State<PhonetiqueScreen> createState() => _PhonetiqueScreenState();
}

class _PhonetiqueScreenState extends State<PhonetiqueScreen> {
  final Mascot _mascot = Mascots.ninonDolphin;
  
  // Les 6 exercices de phonétique
  static const List<PhonetiqueExercise> _allExercises = [
    // Son [a] - comme dans "chat", "papa"
    PhonetiqueExercise(
      sound: 'a',
      description: 'Le son [a] se trouve dans "chat", "papa", "maman"',
      word: 'chat',
      options: ['chat', 'chien', 'chou', 'clé'],
      correctIndex: 0,
      lesson: 'Le son [a] s\'écrit souvent "a" ou "à".\nExemples : mama, papa, chat, lac',
    ),
    // Son [o] - comme dans "hot", "moto"
    PhonetiqueExercise(
      sound: 'o',
      description: 'Le son [o] se trouve dans "moto", "oto", "hôtel"',
      word: 'moto',
      options: ['moto', 'mitaine', 'mutuelle', 'motte'],
      correctIndex: 0,
      lesson: 'Le son [o] s\'écrit "o", "eau", "au" ou "ô".\nExemples : moto, peau, château',
    ),
    // Son [ɛ] - comme dans "père", "tête"
    PhonetiqueExercise(
      sound: 'ɛ',
      description: 'Le son [ɛ] se trouve dans "père", "tête", "bête"',
      word: 'tête',
      options: ['tête', 'tarte', 'tissu', 'tissu', 'tôle'],
      correctIndex: 0,
      lesson: 'Le son [ɛ] s\'écrit "è", "ê", "ei" ou "ai".\nExemples : père, tête, maître',
    ),
    // Son [j] - comme dans "fille", "travail"
    PhonetiqueExercise(
      sound: 'j',
      description: 'Le son [j] se trouve dans "fille", "travail", "paix"',
      word: 'fille',
      options: ['fille', 'foule', 'file', 'faule'],
      correctIndex: 0,
      lesson: 'Le son [j] s\'écrit "ille", "aille", "eille".\nExemples : fille, travaille, araignée',
    ),
    // Son [ã] - comme dans "enfant", "chant"
    PhonetiqueExercise(
      sound: 'ã',
      description: 'Le son [ã] se trouve dans "enfant", "chant", "vent"',
      word: 'enfant',
      options: ['enfant', 'éléphant', 'enfer', 'infecte'],
      correctIndex: 0,
      lesson: 'Le son [ã] s\'écrit "an", "en", "ant", "ent".\nExemples : enfant, chant, temps',
    ),
    // Son [ʃ] - comme dans "chat", "schtroumpf"
    PhonetiqueExercise(
      sound: 'ʃ',
      description: 'Le son [ʃ] se trouve dans "chat", "schtroumpf", "cheval"',
      word: 'chat',
      options: ['chat', 'çat', 'scat', 'ksat'],
      correctIndex: 0,
      lesson: 'Le son [ʃ] s\'écrit "ch".\nExemples : chat, cheval, Schule (en allemand)',
    ),
  ];

  late List<PhonetiqueExercise> _exercises;
  int _current = 0;
  int _score = 0;
  bool _finished = false;
  int? _selectedIndex;
  bool? _isCorrect;
  bool _showLesson = false;

  @override
  void initState() {
    super.initState();
    _exercises = List.from(_allExercises)..shuffle();
  }

  void _speakWord(String word) {
    context.read<TtsService>().speak(word);
  }

  void _checkAnswer(int index) {
    if (_selectedIndex != null) return;
    
    final exercise = _exercises[_current];
    final correct = index == exercise.correctIndex;
    
    setState(() {
      _selectedIndex = index;
      _isCorrect = correct;
      if (correct) _score++;
    });

    // Lecture du mot après réponse
    if (correct) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _speakWord(exercise.word);
      });
    }

    // Afficher la leçon après bonne réponse
    if (correct) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _showLesson = true);
      });
    }

    // Passer à la question suivante
    Future.delayed(Duration(milliseconds: correct ? 2500 : 1500), () {
      if (mounted) _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_current < _exercises.length - 1) {
      setState(() {
        _current++;
        _selectedIndex = null;
        _isCorrect = null;
        _showLesson = false;
      });
      // Lire le mot de la nouvelle question
      Future.delayed(const Duration(milliseconds: 500), () {
        _speakWord(_exercises[_current].word);
      });
    } else {
      setState(() => _finished = true);
    }
  }

  void _restart() {
    setState(() {
      _current = 0;
      _score = 0;
      _finished = false;
      _selectedIndex = null;
      _isCorrect = null;
      _showLesson = false;
      _exercises = List.from(_allExercises)..shuffle();
    });
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
    final exercise = _exercises[_current];
    
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
                      '🔤 Phonétique',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '⭐ $_score',
                  style: const TextStyle(
                    color: AppTheme.primaryPink,
                    fontWeight: FontWeight.w800,
                  ),
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
                  mood: _isCorrect == null
                      ? MascotMood.thinking
                      : _isCorrect == true
                          ? MascotMood.happy
                          : MascotMood.wrong,
                  size: 80,
                  showSpeechBubble: true,
                  speechText: _isCorrect == null
                      ? 'Écoute bien le mot, Emilie ! 👂'
                      : _isCorrect == true
                          ? 'Bravo ! Tu as bien entendu ! 🎵'
                          : 'Écoute encore une fois ! 🔄',
                ).animate().fadeIn(),

                const SizedBox(height: 24),

                // Question
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
                      const Text(
                        'Quel mot contient le son',
                        style: TextStyle(fontSize: 18, color: AppTheme.textGrey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '[${exercise.sound}]',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryPink,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Bouton pour écouter
                      BounceButton(
                        onTap: () => _speakWord(exercise.word),
                        color: AppTheme.primaryPink,
                        borderRadius: BorderRadius.circular(30),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.volume_up, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Écouter 🔊',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ).animate().scale(),

                      const SizedBox(height: 16),

                      // Feedback
                      if (_isCorrect != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isCorrect! ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isCorrect! ? Icons.check_circle : Icons.cancel,
                                color: _isCorrect! ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _isCorrect!
                                      ? 'Le mot était "${exercise.word}"'
                                      : 'Le bon mot était "${exercise.word}"',
                                  style: TextStyle(
                                    color: _isCorrect! ? Colors.green.shade700 : Colors.red.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().scale(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Leçon après bonne réponse
                if (_showLesson && _isCorrect == true)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryBlue, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb, color: AppTheme.primaryBlue),
                            SizedBox(width: 8),
                            Text(
                              '💡 Leçon',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exercise.lesson,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textDark,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2),

                if (!_showLesson) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Choisis le bon mot :',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Options
                  ...exercise.options.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final option = entry.value;
                    
                    Color bg = Colors.white;
                    Color fg = AppTheme.textDark;
                    Color border = Colors.grey.withOpacity(0.3);
                    
                    if (_selectedIndex != null) {
                      if (idx == _selectedIndex) {
                        bg = _isCorrect! ? const Color(0xFF81C784) : const Color(0xFFEF9A9A);
                        fg = Colors.white;
                        border = bg;
                      } else if (idx == exercise.correctIndex) {
                        bg = const Color(0xFF81C784);
                        fg = Colors.white;
                        border = bg;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BounceButton(
                        onTap: _selectedIndex == null ? () => _checkAnswer(idx) : null,
                        color: bg,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: border, width: 2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _selectedIndex == null ? fg : fg,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ).animate(delay: Duration(milliseconds: 100 * idx))
                          .fadeIn()
                          .slideX(begin: 0.1),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final pct = _score / _exercises.length;
    final stars = pct >= 0.8 ? 3 : (pct >= 0.5 ? 2 : 1);
    
    String message;
    String emoji;
    if (pct >= 0.8) {
      message = "Excellente oreille Emilie ! 👂⭐";
      emoji = '🎉';
    } else if (pct >= 0.5) {
      message = "Tu progresses, continue ! 💪";
      emoji = '👍';
    } else {
      message = "On s'entraîne encore ? 🎯";
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
                .animate().scale(delay: 300.ms, curve: Curves.elasticOut),

            const SizedBox(height: 16),

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

/// Modèle d'exercice de phonétique
class PhonetiqueExercise {
  final String sound;       // Le son phonétique, ex: 'a', 'o', 'ʃ'
  final String description;  // Description pour l'élève
  final String word;         // Le mot à trouver
  final List<String> options; // Les 4 options
  final int correctIndex;    // Index de la bonne réponse
  final String lesson;       // Leçon après bonne réponse

  const PhonetiqueExercise({
    required this.sound,
    required this.description,
    required this.word,
    required this.options,
    required this.correctIndex,
    required this.lesson,
  });
}