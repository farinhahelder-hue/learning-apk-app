import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// Widget confettis réutilisable avec plusieurs modes.
/// Usage :
///   final key = GlobalKey<ConfettiOverlayState>();
///   ConfettiOverlay(key: key)
///   key.currentState?.burst(ConfettiType.success);  // différentes animations
enum ConfettiType {
  success, // Confettis rapide pour bonne réponse
  celebrate, // Explosion massive pour score parfait
  star, // Étoiles dorées pour badge
  rainbow, // Arc-en-ciel pour fin de niveau
}

/// Widget confettis réutilisable.
/// Usage :
///   final key = GlobalKey<ConfettiOverlayState>();
///   ConfettiOverlay(key: key)
///   key.currentState?.burst();  // déclenche les confettis
class ConfettiOverlay extends StatefulWidget {
  final bool alignTop;

  const ConfettiOverlay({
    super.key,
    this.alignTop = true,
  });

  @override
  State<ConfettiOverlay> createState() => ConfettiOverlayState();
}

class ConfettiOverlayState extends State<ConfettiOverlay> {
  late ConfettiController _ctrl;
  ConfettiType _lastType = ConfettiType.success;

  static const List<Color> _colors = [
    Color(0xFF4FC3F7), // bleu
    Color(0xFFFF80AB), // rose
    Color(0xFFFFD54F), // jaune
    Color(0xFF81C784), // vert
    Color(0xFFCE93D8), // violet
    Color(0xFFFFB74D), // orange
  ];

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
  void burst([ConfettiType type = ConfettiType.success]) {
    _lastType = type;
    _ctrl.play();
  }

  int _getParticleCount(ConfettiType type) {
    switch (type) {
      case ConfettiType.success:
        return 15;
      case ConfettiType.celebrate:
        return 50;
      case ConfettiType.star:
        return 20;
      case ConfettiType.rainbow:
        return 40;
    }
  }

  double _getGravity(ConfettiType type) {
    switch (type) {
      case ConfettiType.success:
        return 0.25;
      case ConfettiType.celebrate:
        return 0.15;
      case ConfettiType.star:
        return 0.3;
      case ConfettiType.rainbow:
        return 0.1;
    }
  }

  double _getEmissionFrequency(ConfettiType type) {
    switch (type) {
      case ConfettiType.success:
        return 0.08;
      case ConfettiType.celebrate:
        return 0.05;
      case ConfettiType.star:
        return 0.1;
      case ConfettiType.rainbow:
        return 0.03;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignTop ? Alignment.topCenter : Alignment.center,
      child: ConfettiWidget(
        confettiController: _ctrl,
        blastDirection: pi / 2,
        blastDirectionality: BlastDirectionality.explosive,
        emissionFrequency: _getEmissionFrequency(_lastType),
        numberOfParticles: _getParticleCount(_lastType),
        gravity: _getGravity(_lastType),
        shouldLoop: false,
        strokeWidth: 1.5,
        strokeColor: Colors.white,
        colors: _colors,
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
