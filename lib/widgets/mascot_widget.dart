import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/mascot.dart';

/// Widget mascotte animé façon Duolingo
/// Réagit selon MascotMood avec animations différentes
class MascotWidget extends StatefulWidget {
  final Mascot mascot;
  final MascotMood mood;
  final double size;
  final bool showSpeechBubble;
  final String? speechText;

  const MascotWidget({
    super.key,
    required this.mascot,
    this.mood = MascotMood.idle,
    this.size = 120,
    this.showSpeechBubble = false,
    this.speechText,
  });

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with TickerProviderStateMixin {
  late AnimationController _idleCtrl; // respiration idle
  late AnimationController _happyCtrl; // saut joyeux
  late AnimationController _wrongCtrl; // secousse erreur
  late AnimationController _thinkCtrl; // balancement pensée
  late AnimationController _blinkCtrl; // clignement yeux

  @override
  void initState() {
    super.initState();

    // Respiration douce en idle
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Saut bonne réponse
    _happyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Secousse mauvaise réponse (Monika pipipipi)
    _wrongCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Balancement pensée
    _thinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Clignement yeux toutes les 4s
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _startBlinking();
  }

  void _startBlinking() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 4000));
      if (!mounted) break;
      await _blinkCtrl.forward();
      await _blinkCtrl.reverse();
    }
  }

  @override
  void didUpdateWidget(MascotWidget old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood) {
      _triggerMoodAnimation();
    }
  }

  void _triggerMoodAnimation() {
    switch (widget.mood) {
      case MascotMood.happy:
      case MascotMood.celebrate:
        _happyCtrl.forward().then((_) => _happyCtrl.reverse());
        break;
      case MascotMood.wrong:
        _wrongCtrl.forward().then((_) => _wrongCtrl.reverse());
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    _happyCtrl.dispose();
    _wrongCtrl.dispose();
    _thinkCtrl.dispose();
    _blinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bulle de dialogue
        if (widget.showSpeechBubble && widget.speechText != null)
          _SpeechBubble(text: widget.speechText!, color: widget.mascot.color)
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.2),

        const SizedBox(height: 8),

        // Corps de la mascotte
        _buildMascotBody(),

        const SizedBox(height: 4),

        // Nom
        Text(
          widget.mascot.name,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: widget.mascot.color,
          ),
        ),
      ],
    );
  }

  Widget _buildMascotBody() {
    Widget mascot = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.mascot.color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.mascot.color.withOpacity(0.4),
          width: 3,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        widget.mascot.emoji,
        style: TextStyle(fontSize: widget.size * 0.52),
      ),
    );

    // Applique l'animation selon le mood
    switch (widget.mood) {
      case MascotMood.idle:
        return AnimatedBuilder(
          animation: _idleCtrl,
          builder: (_, child) => Transform.scale(
            scale: 1.0 + (_idleCtrl.value * 0.04), // respiration 0-4%
            child: child,
          ),
          child: mascot,
        );

      case MascotMood.happy:
      case MascotMood.celebrate:
        return mascot
            .animate(onPlay: (c) => c.repeat(count: 3))
            .moveY(begin: 0, end: -20, duration: 300.ms, curve: Curves.easeOut)
            .then()
            .moveY(
                begin: -20, end: 0, duration: 300.ms, curve: Curves.bounceOut)
            .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.15, 1.15),
                duration: 200.ms);

      case MascotMood.wrong:
        // Pipipipi de Monika : secousse rapide + rouge
        return mascot
            .animate(onPlay: (c) => c.repeat(count: 4))
            .shake(hz: 8, offset: const Offset(6, 0), duration: 500.ms)
            .tint(color: Colors.red.withOpacity(0.3), duration: 200.ms);

      case MascotMood.thinking:
        return AnimatedBuilder(
          animation: _thinkCtrl,
          builder: (_, child) => Transform.rotate(
            angle: (_thinkCtrl.value - 0.5) * 0.15, // ±8°
            child: child,
          ),
          child: mascot,
        );

      case MascotMood.encourage:
        return mascot
            .animate()
            .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                curve: Curves.elasticOut,
                duration: 800.ms)
            .fadeIn();

      case MascotMood.sleepy:
        return mascot
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .tint(color: Colors.indigo.withOpacity(0.2))
            .moveY(begin: 0, end: 3, duration: 2000.ms);
    }
  }
}

/// Bulle de dialogue façon BD
class _SpeechBubble extends StatelessWidget {
  final String text;
  final Color color;

  const _SpeechBubble({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(18),
        ),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: color.withOpacity(0.85),
          height: 1.4,
        ),
      ),
    );
  }
}
