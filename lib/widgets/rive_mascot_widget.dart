import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rive/rive.dart';
import '../models/mascot.dart';

/// Widget mascotte animée via Rive
/// Lit un fichier .riv par mascotte et contrôle les états via StateMachine
/// Fallback automatique vers MascotWidget (emoji) si le .riv n'existe pas
class RiveMascotWidget extends StatefulWidget {
  final Mascot mascot;
  final MascotMood mood;
  final double size;
  final bool showSpeechBubble;
  final String? speechText;

  const RiveMascotWidget({
    super.key,
    required this.mascot,
    this.mood = MascotMood.idle,
    this.size = 120,
    this.showSpeechBubble = false,
    this.speechText,
  });

  @override
  State<RiveMascotWidget> createState() => _RiveMascotWidgetState();
}

class _RiveMascotWidgetState extends State<RiveMascotWidget> {
  Artboard? _artboard;
  StateMachineController? _controller;

  // Inputs exposés par la state machine Rive
  SMITrigger? _triggerHappy;    // bonne réponse
  SMITrigger? _triggerWrong;    // mauvaise réponse (Monika = pipipipi)
  SMITrigger? _triggerCelebrate;// score parfait
  SMIBool?    _inputThinking;   // timer en cours
  SMIBool?    _inputSleepy;     // mode repos long
  bool _riveLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRive();
  }

  Future<void> _loadRive() async {
    // Chemin : assets/rive/<mascot_id>.riv
    final path = 'assets/rive/${widget.mascot.id}.riv';
    try {
      final data = await rootBundle.load(path);
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard.instance();

      // Cherche la state machine nommée 'MascotMachine'
      final ctrl = StateMachineController.fromArtboard(
        artboard,
        'MascotMachine',
      );

      if (ctrl != null) {
        artboard.addController(ctrl);
        _controller    = ctrl;
        _triggerHappy    = ctrl.findInput<bool>('success')    as SMITrigger?;
        _triggerWrong    = ctrl.findInput<bool>('error')      as SMITrigger?;
        _triggerCelebrate= ctrl.findInput<bool>('celebrate')  as SMITrigger?;
        _inputThinking   = ctrl.findInput<bool>('thinking')   as SMIBool?;
        _inputSleepy     = ctrl.findInput<bool>('sleepy')     as SMIBool?;
      }

      if (mounted) {
        setState(() {
          _artboard   = artboard;
          _riveLoaded = true;
        });
      }
    } catch (_) {
      // Fichier .riv absent → fallback émoji (MascotWidget classique)
      if (mounted) setState(() => _riveLoaded = false);
    }
  }

  @override
  void didUpdateWidget(RiveMascotWidget old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood) _applyMood(widget.mood);
  }

  void _applyMood(MascotMood mood) {
    if (_controller == null) return;
    // Reset booleans
    _inputThinking?.value = false;
    _inputSleepy?.value   = false;

    switch (mood) {
      case MascotMood.happy:
        _triggerHappy?.fire();
        break;
      case MascotMood.wrong:
        _triggerWrong?.fire();
        break;
      case MascotMood.celebrate:
        _triggerCelebrate?.fire();
        break;
      case MascotMood.thinking:
        _inputThinking?.value = true;
        break;
      case MascotMood.sleepy:
        _inputSleepy?.value = true;
        break;
      case MascotMood.idle:
      case MascotMood.encourage:
        break; // idle est l'état par défaut dans la state machine
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bulle de dialogue
        if (widget.showSpeechBubble && widget.speechText != null)
          _SpeechBubble(
            text: widget.speechText!,
            color: widget.mascot.color,
          ),
        const SizedBox(height: 8),

        // Corps : Rive si chargé, sinon fallback émoji avec animations
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: _riveLoaded && _artboard != null
              ? Rive(artboard: _artboard!, fit: BoxFit.contain)
              : _AnimatedEmojiMascot(mascot: widget.mascot, mood: widget.mood, size: widget.size),
        ),

        const SizedBox(height: 4),
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
}

/// Fallback émoji animé quand le .riv n'est pas encore créé
/// Animations: idle (respiration + clignement), success (saut), error (secousse), celebrate (danse)
class _AnimatedEmojiMascot extends StatelessWidget {
  final Mascot mascot;
  final MascotMood mood;
  final double size;

  const _AnimatedEmojiMascot({
    required this.mascot,
    required this.mood,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    Widget emoji = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: mascot.color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: mascot.color.withOpacity(0.4), width: 3),
        boxShadow: [
          BoxShadow(
            color: mascot.color.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(mascot.emoji, style: TextStyle(fontSize: size * 0.52)),
    );

    // Applique l'animation selon le mood
    switch (mood) {
      case MascotMood.happy:
        // Saut de joie + étoiles
        return emoji
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -15, duration: 200.ms)
            .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.15, 1.15), duration: 200.ms)
            .then()
            .scale(begin: const Offset(1.15, 1.15), end: const Offset(1.0, 1.0), duration: 200.ms)
            .shake(duration: 300.ms, hz: 4);

      case MascotMood.wrong:
        // Petite secousse + expression triste
        return emoji
            .animate()
            .shake(duration: 400.ms, hz: 3, delay: 100.ms)
            .scale(begin: const Offset(1.0, 1.0), end: const Offset(0.9, 0.9), duration: 100.ms)
            .then()
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 200.ms);

      case MascotMood.celebrate:
        // Danse / rotation
        return emoji
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .rotate(begin: -0.05, end: 0.05, duration: 150.ms)
            .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.2, 1.2), duration: 200.ms)
            .then()
            .scale(begin: const Offset(1.2, 1.2), end: const Offset(1.0, 1.0), duration: 200.ms)
            .rotate(begin: 0.05, end: -0.05, duration: 150.ms);

      case MascotMood.thinking:
        // Tête penchée
        return emoji
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .rotate(begin: 0, end: 0.08, duration: 800.ms)
            .moveY(begin: 0, end: -3, duration: 1000.ms);

      case MascotMood.sleepy:
        // Respiration lente
        return emoji
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), duration: 2000.ms)
            .fade(begin: 0.7, end: 1.0, duration: 1500.ms);

      case MascotMood.encourage:
      case MascotMood.idle:
      default:
        // Respiration douce + clignement occasionnel
        return emoji
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: 1500.ms)
            .moveY(begin: 0, end: -5, duration: 2000.ms)
            .then(delay: 3000.ms)
            .scale(begin: const Offset(1.05, 1.05), end: const Offset(0.98, 0.98), duration: 100.ms)
            .then()
            .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), duration: 100.ms);
    }
  }
}

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
          topLeft: Radius.circular(18), topRight: Radius.circular(18),
          bottomLeft: Radius.circular(4), bottomRight: Radius.circular(18),
        ),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Nunito', fontSize: 15,
          fontWeight: FontWeight.w700,
          color: color.withOpacity(0.85), height: 1.4,
        ),
      ),
    );
  }
}
