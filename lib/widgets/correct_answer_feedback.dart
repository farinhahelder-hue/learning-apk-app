import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'confetti_overlay.dart';

/// Widget de feedback visuel complet pour bonne réponse :
/// confettis + message animé + vibration
/// Usage : CorrectAnswerFeedback.show(context)
class CorrectAnswerFeedback extends StatelessWidget {
  final GlobalKey<ConfettiOverlayState> confettiKey;

  const CorrectAnswerFeedback({super.key, required this.confettiKey});

  /// Affiche un overlay de félicitation et déclenche confettis + haptique
  static void trigger({
    required GlobalKey<ConfettiOverlayState> confettiKey,
    required BuildContext context,
    String message = 'Bravo ! 🌟',
  }) {
    // Vibration haptique forte (satisfaction)
    HapticFeedback.heavyImpact();
    // Confettis
    confettiKey.currentState?.burst();
    // Snackbar animé cute
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Message flottant centré
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Text(
                '🎉 Bravo Emilie !',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            )
                .animate()
                .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    curve: Curves.elasticOut,
                    duration: 600.ms)
                .fadeIn(duration: 200.ms),
          ),
          // Confettis
          ConfettiOverlay(key: confettiKey),
        ],
      ),
    );
  }
}
