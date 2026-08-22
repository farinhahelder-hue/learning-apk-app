import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../services/accessibility_settings_service.dart';
import '../services/tts_service.dart';
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
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Lecture automatique de la consigne, si le réglage est activé.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<AccessibilitySettingsService>().autoReadEnabled) {
        _speakQuestion();
      }
    });
  }

  /// Lit la consigne à voix haute, à la vitesse choisie dans les réglages.
  void _speakQuestion() {
    final access = context.read<AccessibilitySettingsService>();
    final tts = context.read<TtsService>();
    tts.setSpeechRate(access.voiceRate);
    tts.speak(widget.exercise.question);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _checkAnswer(String answer) {
    if (_isCorrect != null) return;
    final correct = answer.toLowerCase().trim() == widget.exercise.correctAnswer.toLowerCase().trim();
    setState(() {
      _selected = answer;
      _isCorrect = correct;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (correct) widget.onCorrect();
      else widget.onWrong();
    });
  }

  void _submitText() {
    _checkAnswer(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final calm = context.watch<AccessibilitySettingsService>().calmModeEnabled;
    // Si c'est un exercice d'ecriture ou de completion
    if (widget.exercise.type == 'writing' || widget.exercise.type == 'complete') {
      return _buildWritingExercise(calm);
    }

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
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.exercise.question,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: _speakQuestion,
                    icon: const Icon(Icons.volume_up_rounded),
                    tooltip: 'Écouter la consigne',
                    color: AppTheme.primaryBlue,
                  ),
                ],
              ),
              if (widget.exercise.hint != null) ...[
                const SizedBox(height: 8),
                Text(
                  '💡 ${widget.exercise.hint}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Champ de texte pour ecrire
        if (widget.exercise.type == 'writing' || widget.exercise.type == 'complete') ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF6BB9F0), width: 2),
            ),
            child: Column(
              children: [
                Text(
                  widget.exercise.type == 'complete' ? 'Complete le mot' : 'Ecris ta reponse',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                if (widget.exercise.displayWord != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.exercise.displayWord!,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Ta reponse...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF6BB9F0), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF6BB9F0), width: 3),
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  autofocus: true,
                  onSubmitted: (_) => _submitText(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BB9F0),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Valider ✓', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
        ] else ...[
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
            ).animate().fadeIn(duration: calm ? 200.ms : 100.ms).scale(
                duration: 400.ms, curve: calm ? Curves.easeOut : Curves.elasticOut),
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
            ).animate(delay: Duration(milliseconds: calm ? 0 : 100 * entry.key))
                .fadeIn(duration: calm ? 150.ms : 300.ms)
                .slideX(begin: calm ? 0 : 0.1);
          }),
        ],
      ],
    );
  }

  Widget _buildWritingExercise(bool calm) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6BB9F0), width: 3),
      ),
      child: Column(
        children: [
          // Mascot emoji
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF6BB9F0),
              shape: BoxShape.circle,
            ),
            child: const Text('🦭', style: TextStyle(fontSize: 50)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.exercise.question,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: _speakQuestion,
                icon: const Icon(Icons.volume_up_rounded),
                tooltip: 'Écouter la consigne',
                color: const Color(0xFF6BB9F0),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (widget.exercise.displayWord != null) ...[
            Text(
              widget.exercise.displayWord!,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 6),
            ),
            const SizedBox(height: 8),
            Text('Complete avec les bonnes lettres', style: TextStyle(color: Colors.grey.shade600)),
          ] else ...[
            Text('Ecris le mot :', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Ta reponse...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFF6BB9F0), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFF6BB9F0), width: 3),
              ),
            ),
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitText,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6BB9F0),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: const Text('Valider ✓', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: calm ? 200.ms : 100.ms)
        .scale(begin: calm ? const Offset(1, 1) : const Offset(0.9, 0.9));
  }
}
