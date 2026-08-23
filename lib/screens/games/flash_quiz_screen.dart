import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/exercise.dart';
import '../../services/audio_service.dart';
import '../../services/game_service.dart';
import '../../services/progress_service.dart';
import '../../services/accessibility_settings_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/curriculum.dart';
import '../../widgets/confetti_overlay.dart';
import '../../utils/shuffled_choices.dart';

/// Manche courte et cadrée de 10 questions du niveau choisi (CE1 ou CE2,
/// jamais mélangés), avec un résultat en étoiles à la fin.
class FlashQuizScreen extends StatefulWidget {
  const FlashQuizScreen({super.key});

  @override
  State<FlashQuizScreen> createState() => _FlashQuizScreenState();
}

class _FlashQuizScreenState extends State<FlashQuizScreen> {
  /// Sel de mélange des propositions, tiré une fois par écran.
  final int _salt = Shuffled.newSalt();

  static const _roundLength = 10;

  late final String _level;
  late List<Exercise> _questions;
  int _index = 0;
  int _score = 0;
  String? _selected;
  bool? _isCorrect;
  bool _finished = false;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  @override
  void initState() {
    super.initState();
    _level = context.read<GameService>().gradeLevel;
    final pool = Curriculum.exercisesForLevel(_level).where((e) => e.type == 'qcm').toList()
      ..shuffle();
    _questions = pool.length > _roundLength ? pool.sublist(0, _roundLength) : pool;
  }

  void _onAnswer(String answer) {
    if (_isCorrect != null || _questions.isEmpty) return;
    final ex = _questions[_index];
    final correct = answer == ex.correctAnswer;
    final audio = context.read<AudioService>();

    setState(() {
      _selected = answer;
      _isCorrect = correct;
      if (correct) _score++;
    });

    if (correct) {
      audio.onCorrectAnswer();
    } else {
      audio.onWrongAnswer();
    }

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_index < _questions.length - 1) {
        setState(() {
          _index++;
          _selected = null;
          _isCorrect = null;
        });
      } else {
        _finishRound();
      }
    });
  }

  void _finishRound() {
    final calm = context.read<AccessibilitySettingsService>().calmModeEnabled;
    final stars = _stars();
    context.read<ProgressService>().addPoints('game', stars * 15);
    context.read<AudioService>().onPerfect();
    if (!calm) _confettiKey.currentState?.burst(ConfettiType.celebrate);
    setState(() => _finished = true);
  }

  int _stars() {
    if (_questions.isEmpty) return 0;
    final pct = _score / _questions.length;
    if (pct >= 1.0) return 3;
    if (pct >= 0.7) return 2;
    if (pct >= 0.4) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('⚡ Quiz Éclair · $_level'),
        backgroundColor: AppTheme.primaryYellow.withOpacity(0.2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (_questions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('🚧 Pas encore assez de questions pour ce niveau.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            )
          else if (_finished)
            _buildResults()
          else
            _buildQuiz(),
          ConfettiOverlay(key: _confettiKey),
        ],
      ),
    );
  }

  Widget _buildQuiz() {
    final ex = _questions[_index];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_index + 1) / _questions.length,
            backgroundColor: Colors.grey.shade200,
            color: const Color(0xFFFFA000),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          Text('Question ${_index + 1} / ${_questions.length}',
              style: const TextStyle(color: AppTheme.textGrey)),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Text(ex.question,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textDark))
                .animate(key: ValueKey(_index)).fadeIn(duration: 250.ms).slideY(begin: 0.1),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: Shuffled.of(ex.options,
                      salt: _salt, index: ex.question.hashCode)
                  .map((option) {
                Color bg = Colors.white;
                Color border = Colors.grey.shade200;
                Color fg = AppTheme.textDark;
                if (_selected != null) {
                  if (option == ex.correctAnswer) {
                    bg = const Color(0xFFE8F5E9); border = const Color(0xFF4CAF50); fg = const Color(0xFF2E7D32);
                  } else if (option == _selected) {
                    bg = const Color(0xFFF5F5F5); border = Colors.grey.shade300;
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _onAnswer(option),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border, width: 2),
                      ),
                      child: Text(option, textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: fg)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final stars = _stars();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(stars == 3 ? '🏆' : stars >= 1 ? '🌟' : '💪', style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (s) => Icon(
                s < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                color: s < stars ? Colors.amber : Colors.grey.shade300,
                size: 44,
              )),
            ),
            const SizedBox(height: 12),
            Text('$_score / ${_questions.length} bonnes réponses',
                style: const TextStyle(fontSize: 18, color: AppTheme.textGrey)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => setState(() {
                _index = 0; _score = 0; _finished = false; _selected = null; _isCorrect = null;
                _questions.shuffle();
              }),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFA000)),
              child: const Text('🔄 Rejouer', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Retour aux mini-jeux'),
            ),
          ],
        ),
      ),
    );
  }
}
