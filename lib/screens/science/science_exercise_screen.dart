import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../data/science_exercises.dart';
import '../../models/exercise.dart';
import '../../services/progress_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/exercise_card.dart';

class ScienceExerciseScreen extends StatefulWidget {
  final String category;
  final String title;
  const ScienceExerciseScreen({super.key, required this.category, required this.title});

  @override
  State<ScienceExerciseScreen> createState() => _ScienceExerciseScreenState();
}

class _ScienceExerciseScreenState extends State<ScienceExerciseScreen> {
  late List<Exercise> _exercises;
  int _current = 0, _score = 0, _wrong = 0;
  bool _finished = false;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _exercises = ScienceExercises.getByCategory(widget.category);
    _exercises.shuffle();
    if (_exercises.length > 10) _exercises = _exercises.sublist(0, 10);
  }

  @override
  void dispose() { _confetti.dispose(); super.dispose(); }

  void _onCorrect() {
    setState(() => _score++);
    if (_current < _exercises.length - 1)
      Future.delayed(const Duration(milliseconds: 300), () => setState(() => _current++));
    else _finish();
  }

  void _onWrong() {
    setState(() => _wrong++);
    if (_current < _exercises.length - 1)
      Future.delayed(const Duration(milliseconds: 1500), () => setState(() => _current++));
    else _finish();
  }

  void _finish() {
    context.read<ProgressService>().addPoints('science', _score * 10);
    if (_score == _exercises.length) _confetti.play();
    setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppTheme.scienceColor.withOpacity(0.15),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context)),
        actions: [Center(child: Padding(padding: const EdgeInsets.only(right: 16),
            child: Text('⭐ ${_score * 10} pts', style: const TextStyle(fontWeight: FontWeight.w700))))],
      ),
      body: Stack(
        children: [
          if (_finished) _buildResults() else _buildExercise(),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                colors: const [Colors.green, Colors.yellow, Colors.blue, Colors.orange]),
          ),
        ],
      ),
    );
  }

  Widget _buildExercise() {
    if (_exercises.isEmpty) return const Center(child: Text('Aucun exercice disponible.'));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_current + 1) / _exercises.length,
            backgroundColor: Colors.grey.shade200,
            color: AppTheme.scienceColor, minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          Text('Question ${_current + 1} / ${_exercises.length}',
              style: const TextStyle(color: AppTheme.textGrey)),
          const SizedBox(height: 24),
          ExerciseCard(key: ValueKey(_current), exercise: _exercises[_current],
              onCorrect: _onCorrect, onWrong: _onWrong),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final pct = _score / _exercises.length;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(pct == 1 ? '🏆' : pct >= 0.7 ? '🌟' : '💪', style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text(pct == 1 ? 'Parfait Emilie !' : pct >= 0.7 ? 'Très bien !' : 'Continue à pratiquer !',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text('$_score / ${_exercises.length} bonnes réponses',
                style: const TextStyle(fontSize: 18, color: AppTheme.textGrey)),
            Text('+${_score * 10} points ⭐',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.scienceColor)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => setState(() {
                _current = 0; _score = 0; _wrong = 0; _finished = false; _exercises.shuffle();
              }),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.scienceColor),
              child: const Text('Rejouer ! 🔄', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Retour au menu')),
          ],
        ),
      ),
    );
  }
}
