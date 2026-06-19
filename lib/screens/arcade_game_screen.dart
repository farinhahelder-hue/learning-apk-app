import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/exercise.dart';
import '../models/game_session.dart';
import '../services/game_service.dart';
import '../services/progress_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../data/math_exercises.dart';
import '../data/french_exercises.dart';
import '../data/science_exercises.dart';

class ArcadeGameScreen extends StatefulWidget {
  final String worldId;
  final String skillId;
  final String skillLabel;
  final String subject;
  final Color color;

  const ArcadeGameScreen({
    super.key,
    required this.worldId,
    required this.skillId,
    required this.skillLabel,
    required this.subject,
    required this.color,
  });

  @override
  State<ArcadeGameScreen> createState() => _ArcadeGameScreenState();
}

class _ArcadeGameScreenState extends State<ArcadeGameScreen> {
  late List<Exercise> _exercises;
  int _current = 0;
  int _score = 0;
  int _combo = 0; // réponses correctes consécutives
  int _maxCombo = 0;
  int _timeLeft = 60; // 60 secondes par session
  bool _finished = false;
  String? _lastFeedback;
  bool? _lastCorrect;
  Timer? _timer;
  late ConfettiController _confetti;
  late GameSession _session;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    _loadExercises();
    _startTimer();
  }

  void _loadExercises() {
    List<Exercise> all = [];
    // Mapper skillId -> catégorie d'exercices
    final categoryMap = {
      'sk_add20': 'addition',
      'sk_add100': 'addition',
      'sk_sub20': 'subtraction',
      'sk_sub100': 'subtraction',
      'sk_mult2_5': 'multiplication',
      'sk_mult6_9': 'multiplication',
      'sk_shapes2d': 'geometry',
      'sk_shapes3d': 'geometry',
      'sk_angles': 'geometry',
      'sk_count100': 'logic',
      'sk_count1000': 'logic',
      'sk_fractions': 'logic',
      'sk_length': 'logic',
      'sk_mass': 'logic',
      'sk_time': 'logic',
      'sk_money': 'logic',
      'sk_read_simple': 'lecture',
      'sk_read_text': 'lecture',
      'sk_spell_basic': 'orthographe',
      'sk_spell_homophones': 'orthographe',
      'sk_conj_present': 'conjugaison',
      'sk_conj_etre_avoir': 'conjugaison',
      'sk_gram_phrase': 'grammaire',
      'sk_gram_nature': 'grammaire',
      'sk_vocab_animals': 'vocabulaire',
      'sk_read_poetry': 'vocabulaire',
    };

    final cat = categoryMap[widget.skillId];
    if (cat != null) {
      switch (widget.subject) {
        case 'math':
          all = MathExercises.getByCategory(cat);
          break;
        case 'french':
          all = FrenchExercises.getByCategory(cat);
          break;
        case 'science':
          all = ScienceExercises.getByCategory(cat);
          break;
      }
    }

    if (all.isEmpty) all = MathExercises.getByCategory('addition'); // fallback
    all = List.from(all)..shuffle();
    _exercises = all.length > 8 ? all.sublist(0, 8) : all;

    _session = GameSession(
      worldId: widget.worldId,
      skillId: widget.skillId,
      gameType: GameType.arcade,
      exercises: _exercises,
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _finish();
      }
    });
  }

  void _answer(String answer) {
    if (_finished) return;
    final ex = _exercises[_current];
    final correct = answer == ex.correctAnswer;

    setState(() {
      _lastCorrect = correct;
      if (correct) {
        _combo++;
        if (_combo > _maxCombo) _maxCombo = _combo;
        final bonus = _combo >= 3 ? 20 : 10; // bonus combo x3
        _score += bonus;
        _lastFeedback = _combo >= 3
            ? 'COMBO x$_combo ! +$bonus pts 🔥'
            : AppConstants.encouragements[DateTime.now().millisecond %
                AppConstants.encouragements.length];
      } else {
        _combo = 0;
        _lastFeedback = AppConstants.tryAgainMessages[
            DateTime.now().millisecond % AppConstants.tryAgainMessages.length];
      }
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_current < _exercises.length - 1) {
        setState(() {
          _current++;
          _lastFeedback = null;
        });
      } else {
        _finish();
      }
    });
  }

  void _finish() {
    _timer?.cancel();
    _session.score = _score;
    _session.stars = _session.computeStars();
    _session.completed = true;
    _session.timeSeconds = 60 - _timeLeft;

    context.read<GameService>().completeSession(_session);
    context.read<ProgressService>().addPoints(widget.subject, _score);

    if (_session.stars >= 2) _confetti.play();
    setState(() => _finished = true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.color.withOpacity(0.15),
        title: Text(widget.skillLabel),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            _timer?.cancel();
            Navigator.pop(context);
          },
        ),
        actions: [
          if (!_finished)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(Icons.timer,
                      color: _timeLeft <= 10 ? Colors.red : widget.color),
                  const SizedBox(width: 4),
                  Text('$_timeLeft s',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _timeLeft <= 10 ? Colors.red : AppTheme.textDark,
                      )),
                ],
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_finished) _buildResults() else _buildGame(),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              colors: [widget.color, Colors.yellow, Colors.pink, Colors.green],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGame() {
    if (_exercises.isEmpty)
      return const Center(child: Text('Pas d’exercice disponible.'));
    final ex = _exercises[_current];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Timer + progression
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_current + 1) / _exercises.length,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    color: widget.color,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Combo badge
              if (_combo >= 2)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('🔥 Combo x$_combo',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.deepOrange)),
                ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
            ],
          ),
          const SizedBox(height: 6),
          Text('${_current + 1}/${_exercises.length} • ⭐ $_score pts',
              style: const TextStyle(
                  color: AppTheme.textGrey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          // Feedback
          if (_lastFeedback != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _lastCorrect == true
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(_lastFeedback!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: _lastCorrect == true
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  )),
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(duration: 300.ms, curve: Curves.elasticOut),
          // Question
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Text(ex.question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark)),
          )
              .animate(key: ValueKey(_current))
              .fadeIn(duration: 250.ms)
              .slideY(begin: 0.1),
          const SizedBox(height: 20),
          // Options
          ...ex.options.asMap().entries.map((e) {
            return GestureDetector(
              onTap: () => _answer(e.value),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: widget.color.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3)),
                  ],
                ),
                child: Text(e.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            )
                .animate(delay: Duration(milliseconds: 60 * e.key))
                .fadeIn()
                .slideX(begin: 0.1);
          }),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final stars = _session.stars;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(['', '🤤', '🌟', '🏆'][stars.clamp(0, 3)],
                style: const TextStyle(fontSize: 90)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  3,
                  (s) => Icon(
                        s < stars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: s < stars ? Colors.amber : Colors.grey.shade300,
                        size: 48,
                      )),
            ),
            const SizedBox(height: 12),
            Text(
              stars == 3
                  ? 'Parfait Emilie ! Tu maîttrises ce chapitre !'
                  : stars == 2
                      ? 'Très bien ! Encore un peu de pratique 💪'
                      : stars == 1
                          ? 'Bien essayé ! Réessaie pour progresser !'
                          : 'Continue à t’entraîner ! Tu vas y arriver ! 🌈',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text('Score : $_score pts ⭐  |  Combo max : x$_maxCombo 🔥',
                style: const TextStyle(color: AppTheme.textGrey)),
            const SizedBox(height: 8),
            Text('+${stars * 20 + _score} XP gagnés !',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: widget.color)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _current = 0;
                  _score = 0;
                  _combo = 0;
                  _timeLeft = 60;
                  _finished = false;
                  _lastFeedback = null;
                  _exercises.shuffle();
                  _session = GameSession(
                    worldId: widget.worldId,
                    skillId: widget.skillId,
                    gameType: GameType.arcade,
                    exercises: _exercises,
                  );
                });
                _startTimer();
              },
              style: ElevatedButton.styleFrom(backgroundColor: widget.color),
              child: const Text('🔄 Rejouer',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Retour à la carte'),
            ),
          ],
        ),
      ),
    );
  }
}
