import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// Widget confettis réutilisable.
/// Usage :
///   final key = GlobalKey<ConfettiOverlayState>();
///   ConfettiOverlay(key: key)
///   key.currentState?.burst();  // déclenche les confettis
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => ConfettiOverlayState();
}

class ConfettiOverlayState extends State<ConfettiOverlay> {
  late ConfettiController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Déclencher une explosion de confettis
  void burst() => _ctrl.play();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _ctrl,
        blastDirection: pi / 2, // vers le bas
        blastDirectionality: BlastDirectionality.explosive,
        emissionFrequency: 0.08,
        numberOfParticles: 22,
        gravity: 0.25,
        shouldLoop: false,
        strokeWidth: 1.5,
        strokeColor: Colors.white,
        colors: const [
          Color(0xFF4FC3F7), // bleu
          Color(0xFFFF80AB), // rose
          Color(0xFFFFD54F), // jaune
          Color(0xFF81C784), // vert
          Color(0xFFCE93D8), // violet
          Color(0xFFFFB74D), // orange
        ],
        createParticlePath: (size) {
          // Particules en forme d'étoile 🌟
          final path = Path();
          final double w = size.width;
          final double h = size.height;
          path
            ..moveTo(w * 0.5, 0)
            ..lineTo(w * 0.61, h * 0.35)
            ..lineTo(w, h * 0.35)
            ..lineTo(w * 0.68, h * 0.57)
            ..lineTo(w * 0.79, h)
            ..lineTo(w * 0.5, h * 0.75)
            ..lineTo(w * 0.21, h)
            ..lineTo(w * 0.32, h * 0.57)
            ..lineTo(0, h * 0.35)
            ..lineTo(w * 0.39, h * 0.35)
            ..close();
          return path;
        },
      ),
    );
  }
}
