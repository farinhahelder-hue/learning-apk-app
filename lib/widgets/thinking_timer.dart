import 'dart:async';
import 'package:flutter/material.dart';

/// Minuteur visuel : un cercle qui se vide, sans aucun son.
///
/// Il n'est affiché que si « Minuteur de réflexion » est activé dans les
/// réglages — désactivé par défaut, parce qu'une contrainte de temps ne
/// convient pas à tout le monde.
///
/// **Trois règles de fonctionnement**, apprises en corrigeant des bugs
/// bien réels :
///
/// - [start] annule toujours le décompte précédent. Sans ça, deux appels
///   laissaient tourner deux `Timer.periodic` en même temps et le compte
///   à rebours descendait deux fois plus vite.
/// - [reset] **relance** le décompte. Il se contentait de l'arrêter, si
///   bien que le minuteur ne fonctionnait qu'à la première question :
///   l'écran appelle `reset()` à chaque nouvelle question, et le
///   décompte restait figé sur 30 pour toutes les suivantes.
/// - [onEnd] n'est appelé qu'une fois par décompte.
class ThinkingTimer extends StatefulWidget {
  /// Durée totale, en secondes.
  final int seconds;

  /// Appelé une seule fois, quand le temps est écoulé.
  final VoidCallback? onEnd;

  final double size;

  /// Démarre seul à l'affichage. Les changements de cette valeur sont
  /// pris en compte après coup (voir [didUpdateWidget]).
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

  /// Empêche [onEnd] de partir deux fois pour un même décompte.
  bool _ended = false;

  bool get isRunning => _ticker?.isActive ?? false;

  /// Durée sûre : une durée nulle ou négative diviserait par zéro dans
  /// le calcul de couleur.
  int get _total => widget.seconds > 0 ? widget.seconds : 1;

  @override
  void initState() {
    super.initState();
    _remaining = _total;
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: _total),
    );
    _progress = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.linear),
    );
    if (widget.autoStart) start();
  }

  @override
  void didUpdateWidget(ThinkingTimer old) {
    super.didUpdateWidget(old);

    // L'écran garde le même minuteur d'une question à l'autre (même
    // GlobalKey), donc l'état est réutilisé et initState ne repasse
    // jamais. Sans ce bloc, changer `seconds` ou `autoStart` n'avait
    // aucun effet.
    if (widget.seconds != old.seconds) {
      _ctrl.duration = Duration(seconds: _total);
      reset();
      return;
    }
    if (widget.autoStart && !old.autoStart && !isRunning) {
      start();
    } else if (!widget.autoStart && old.autoStart && isRunning) {
      stop();
    }
  }

  /// (Re)démarre le décompte depuis le début.
  void start() {
    // Toujours annuler l'ancien : deux décomptes simultanés font
    // descendre le compteur deux fois plus vite.
    _ticker?.cancel();
    _ended = false;

    if (mounted) {
      setState(() => _remaining = _total);
    } else {
      _remaining = _total;
    }

    _ctrl.duration = Duration(seconds: _total);
    _ctrl.forward(from: 0);

    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      // Le compteur ne descend jamais sous zéro, même si un décompte
      // oublié tournait encore.
      setState(() => _remaining = _remaining > 0 ? _remaining - 1 : 0);
      if (_remaining <= 0) {
        t.cancel();
        if (!_ended) {
          _ended = true;
          widget.onEnd?.call();
        }
      }
    });
  }

  /// Fige le décompte là où il en est.
  void stop() {
    _ticker?.cancel();
    _ticker = null;
    if (_ctrl.isAnimating) _ctrl.stop();
  }

  /// Repart de la durée complète — c'est ce qu'attend un écran qui passe
  /// à la question suivante.
  void reset() => start();

  /// Remet à la durée complète sans repartir.
  void resetAndHold() {
    stop();
    _ended = false;
    if (mounted) {
      setState(() => _remaining = _total);
    } else {
      _remaining = _total;
    }
    _ctrl.reset();
  }

  Color get _timerColor {
    final ratio = _remaining / _total;
    if (ratio > 0.6) return const Color(0xFF4CAF50);
    if (ratio > 0.3) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
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
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: _progress.value,
                  strokeWidth: 6,
                  backgroundColor: _timerColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(_timerColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
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
