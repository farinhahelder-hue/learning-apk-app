import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum MascotType { seal, squirrel, jellyfish }

class Mascot {
  final MascotType type;
  final String name;
  final String greeting;
  final Color color;
  final String emoji;

  const Mascot({
    required this.type,
    required this.name,
    required this.greeting,
    required this.color,
    required this.emoji,
  });

  static const Mascot seal = Mascot(
    type: MascotType.seal,
    name: 'Bubulle',
    greeting: 'Kikikiki ! Je suis Bubulle le phoque ! 🦭',
    color: Color(0xFF6BB9F0),
    emoji: '🦭',
  );

  static const Mascot squirrel = Mascot(
    type: MascotType.squirrel,
    name: 'Noisette',
    greeting: "Bonsoir ! Je suis Noisette l'ecureuil nocturne ! 🐿️",
    color: Color(0xFFD4956A),
    emoji: '🐿️',
  );

  static const Mascot jellyfish = Mascot(
    type: MascotType.jellyfish,
    name: 'Floflo',
    greeting: 'Wouah ! Je suis Floflo la meduse dansante ! 🎐',
    color: Color(0xFFB966D9),
    emoji: '🎐',
  );

  static List<Mascot> get all => [seal, squirrel, jellyfish];

  static Mascot forSubject(String subject) {
    switch (subject) {
      case 'math':
        return jellyfish;
      case 'french':
        return seal;
      case 'science':
        return squirrel;
      default:
        return all.first;
    }
  }
}

class MascotWidget extends StatelessWidget {
  final Mascot mascot;
  final double size;
  final bool showGreeting;
  final bool animate;

  const MascotWidget({
    super.key,
    required this.mascot,
    this.size = 80,
    this.showGreeting = false,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = _buildMascot();

    if (animate) {
      content = content
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .moveY(begin: 0, end: -8, duration: 1.seconds, curve: Curves.easeInOut);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        content,
        if (showGreeting) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: mascot.color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              mascot.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMascot() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: mascot.color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: mascot.color, width: 3),
      ),
      child: Center(
        child: Text(
          mascot.emoji,
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }
}
