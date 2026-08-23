import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/exercise.dart';
import '../../services/audio_service.dart';
import '../../services/game_service.dart';
import '../../services/progress_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/curriculum.dart';
import '../../utils/shuffled_choices.dart';

/// Mode "sans fin" : une question à la fois, tirée du programme du niveau
/// choisi (CE1 ou CE2, jamais mélangés). Le streak remplace le chrono —
/// une erreur remet juste le compteur à zéro, jamais de message négatif.
class QuestionRainScreen extends StatefulWidget {
  const QuestionRainScreen({super.key});

  @override
  State<QuestionRainScreen> createState() => _QuestionRainScreenState();
}

class _QuestionRainScreenState extends State<QuestionRainScreen> {
  /// Sel de mélange des propositions, tiré une fois par écran.
  final int _salt = Shuffled.newSalt();

  late final String _level;
  late List<Exercise> _pool;
  int _index = 0;
  int _streak = 0;
  int _bestStreak = 0;
  String? _selected;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _level = context.read<GameService>().gradeLevel;
    _pool = Curriculum.exercisesForLevel(_level).where((e) => e.type == 'qcm').toList()
      ..shuffle();
  }

  void _onAnswer(String answer) {
    if (_isCorrect != null || _pool.isEmpty) return;
    final ex = _pool[_index];
    final correct = answer == ex.correctAnswer;
    final audio = context.read<AudioService>();

    setState(() {
      _selected = answer;
      _isCorrect = correct;
      if (correct) {
        _streak++;
        if (_streak > _bestStreak) _bestStreak = _streak;
      } else {
        _streak = 0;
      }
    });

    if (correct) {
      audio.onCorrectAnswer(isCombo: _streak >= 3);
      context.read<ProgressService>().addPoints('game', 5);
    } else {
      audio.onWrongAnswer();
    }

    Future.delayed(const Duration(milliseconds: 850), () {
      if (!mounted) return;
      setState(() {
        _index++;
        if (_index >= _pool.length) {
          _pool.shuffle();
          _index = 0;
        }
        _selected = null;
        _isCorrect = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🌧️ Pluie de Questions · $_level'),
        backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _pool.isEmpty ? _buildEmpty() : _buildGame(),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('🚧 Pas encore assez de questions pour ce niveau.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildGame() {
    final ex = _pool[_index];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('🔥 Série : $_streak',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.deepOrange)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('🏆 Record : $_bestStreak',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryPurple)),
              ),
            ],
          ),
          const SizedBox(height: 28),
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
}
