import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Timer visuel "bulle" façon Duolingo
/// Cercle qui se vide progressivement, change de couleur (vert→orange→rouge)
/// Compatible neurodivergences : visuel uniquement, pas de son angoissant
class ThinkingTimer extends StatefulWidget {
  final int seconds; // durée totale
  final VoidCallback? onEnd; // appelé quand temps écoulé
  final double size;
  final bool autoStart;

  const ThinkingTimer({
    super.key,
    this.seconds = 30,
    this.onEnd,
    this.size = 72,
    this.autoStart = true,
  });

  @override
  State<ThinkingTimer> createState() => ThinkingTimerState();
}

class ThinkingTimerState extends State<ThinkingTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;
  Timer? _ticker;
  int _remaining = 0;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    );
    _progress = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.linear),
    );
    if (widget.autoStart) start();
  }

  void start() {
    _running = true;
    _ctrl.forward(from: 0);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _remaining--);
      if (_remaining <= 0) {
        t.cancel();
        _running = false;
        widget.onEnd?.call();
      }
    });
  }

  void stop() {
    _ticker?.cancel();
    _ctrl.stop();
    _running = false;
  }

  void reset() {
    stop();
    setState(() => _remaining = widget.seconds);
    _ctrl.reset();
  }

  Color get _timerColor {
    final ratio = _remaining / widget.seconds;
    if (ratio > 0.6) return const Color(0xFF4CAF50); // vert
    if (ratio > 0.3) return const Color(0xFFFF9800); // orange
    return const Color(0xFFF44336); // rouge
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (_, __) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Cercle de fond
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: _progress.value,
                  strokeWidth: 6,
                  backgroundColor: _timerColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(_timerColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Chiffre restant
              Text(
                '$_remaining',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: widget.size * 0.38,
                  fontWeight: FontWeight.w900,
                  color: _timerColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
