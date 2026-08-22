import 'package:flutter/material.dart';

/// Bulle animée qui grossit et rétrécit au rythme d'une respiration guidée
/// (inspire 4s / bloque 2s / expire 4s). Purement visuel, sans son, pour un
/// ancrage sensoriel doux — pensé pour un enfant TDAH/autiste en surcharge.
class BreathingBubble extends StatefulWidget {
  final Color color;
  final double size;

  const BreathingBubble({super.key, required this.color, this.size = 140});

  @override
  State<BreathingBubble> createState() => _BreathingBubbleState();
}

class _BreathingBubbleState extends State<BreathingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const _inhale = Duration(seconds: 4);
  static const _hold = Duration(seconds: 2);
  static const _exhale = Duration(seconds: 4);
  static final _totalMs =
      (_inhale + _hold + _exhale).inMilliseconds.toDouble();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _inhale + _hold + _exhale)
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double get _elapsedMs => _ctrl.value * _totalMs;

  String _phaseLabel() {
    if (_elapsedMs < _inhale.inMilliseconds) return 'Inspire... 🌬️';
    if (_elapsedMs < _inhale.inMilliseconds + _hold.inMilliseconds) return 'Bloque... ✋';
    return 'Expire... 😮‍💨';
  }

  double _scale() {
    final inhaleMs = _inhale.inMilliseconds;
    final holdMs = _hold.inMilliseconds;
    if (_elapsedMs < inhaleMs) {
      return 0.6 + 0.4 * (_elapsedMs / inhaleMs);
    } else if (_elapsedMs < inhaleMs + holdMs) {
      return 1.0;
    } else {
      final exhaleElapsed = _elapsedMs - inhaleMs - holdMs;
      final exhaleMs = _totalMs - inhaleMs - holdMs;
      return 1.0 - 0.4 * (exhaleElapsed / exhaleMs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: _scale(),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.35),
                  border: Border.all(color: widget.color, width: 3),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _phaseLabel(),
              style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      },
    );
  }
}
