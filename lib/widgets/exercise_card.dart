import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/exercise.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onCorrect,
    required this.onWrong,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  String? _selected;
  bool? _isCorrect;

  void _checkAnswer(String answer) {
    if (_isCorrect != null) return;
    setState(() {
      _selected = answer;
      _isCorrect = answer == widget.exercise.correctAnswer;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (_isCorrect == true) widget.onCorrect();
      else widget.onWrong();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Question
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Text(
            widget.exercise.question,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textDark),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        // Feedback
        if (_isCorrect != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: _isCorrect! ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _isCorrect!
                  ? AppConstants.encouragements[DateTime.now().millisecond % AppConstants.encouragements.length]
                  : AppConstants.tryAgainMessages[DateTime.now().millisecond % AppConstants.tryAgainMessages.length],
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: _isCorrect! ? Colors.green.shade700 : Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
        // Choix QCM
        ...widget.exercise.options.asMap().entries.map((entry) {
          final option = entry.value;
          Color bg = Colors.white;
          Color fg = AppTheme.textDark;
          if (_selected == option) {
            bg = _isCorrect! ? const Color(0xFF81C784) : const Color(0xFFEF9A9A);
            fg = Colors.white;
          } else if (_isCorrect == false && option == widget.exercise.correctAnswer) {
            bg = const Color(0xFF81C784); fg = Colors.white;
          }
          return GestureDetector(
            onTap: () => _checkAnswer(option),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: bg == Colors.white ? Colors.grey.withOpacity(0.2) : bg),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: Text(option,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: fg),
                  textAlign: TextAlign.center),
            ),
          ).animate(delay: Duration(milliseconds: 100 * entry.key)).fadeIn().slideX(begin: 0.1);
        }),
      ],
    );
  }
}
