import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/adaptive_engine.dart';
import '../services/game_service.dart';
import '../utils/app_theme.dart';

// 🤖 Stella - coach virtuel bienveillant d'Emilie
class CoachScreen extends StatelessWidget {
  final String message;
  final double? successRate;
  final VoidCallback onContinue;
  final bool showTip;

  const CoachScreen({
    super.key,
    required this.message,
    required this.onContinue,
    this.successRate,
    this.showTip = false,
  });

  static const List<Map<String, String>> _tips = [
    {'emoji': '📚', 'tip': 'Lis la question à voix haute ! Ça aide vraiment.'},
    {
      'emoji': '🍓',
      'tip': 'Pour mémoriser une table, chante-la comme une chanson !'
    },
    {'emoji': '✏️', 'tip': 'Tu peux compter sur tes doigts, c’est très bien !'},
    {
      'emoji': '💧',
      'tip': 'Boire de l’eau aide le cerveau à mieux travailler.'
    },
    {
      'emoji': '😴',
      'tip': 'Bien dormir la nuit aide à mémoriser ce qu’on a appris !'
    },
    {
      'emoji': '😊',
      'tip': 'Sourire quand on apprend, ça rend tout plus facile !'
    },
    {
      'emoji': '🔊',
      'tip': 'Répète les mots à voix haute pour mieux les retenir.'
    },
    {
      'emoji': '🌟',
      'tip': 'Chaque petite victoire compte ! Tu progresses chaque jour.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final tip =
        showTip ? _tips[DateTime.now().millisecond % _tips.length] : null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.homeGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Stella l'amie coach
                const Text('🧑\u200d🏫', style: TextStyle(fontSize: 90))
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 8),
                const Text('Stella, ta coach',
                    style: TextStyle(
                        color: AppTheme.textGrey, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.07), blurRadius: 16)
                    ],
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                        fontSize: 17, height: 1.5, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                // Barre de score si disponible
                if (successRate != null) ...[
                  const SizedBox(height: 20),
                  _ScoreBar(rate: successRate!),
                ],

                // Conseil du jour
                if (tip != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryYellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: AppTheme.primaryYellow.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        Text(tip['emoji']!,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip['tip']!,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 400.ms).fadeIn(),
                ],

                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    minimumSize: const Size(200, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('🚀 Continuer l’aventure !',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final double rate;
  const _ScoreBar({required this.rate});

  @override
  Widget build(BuildContext context) {
    final color = rate >= 0.8
        ? Colors.green
        : rate >= 0.6
            ? Colors.orange
            : Colors.red;
    return Column(
      children: [
        Text('Taux de réussite : ${(rate * 100).round()}%',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: color, fontSize: 15)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: rate,
            minHeight: 14,
            backgroundColor: Colors.grey.shade200,
            color: color,
          ),
        ),
      ],
    );
  }
}
