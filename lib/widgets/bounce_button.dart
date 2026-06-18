import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Bouton avec effet bounce + retour haptique + animations
/// Compatible neurodivergences : grande zone de tap (min 64px), feedback immédiat
class BounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final Color? shadowColor;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double minHeight;
  final bool showRipple;
  final String? badge; // Badge optionnel (ex: "NEW", "3")

  const BounceButton({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.shadowColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
    this.minHeight = 64,
    this.showRipple = true,
    this.badge,
  });

  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn,
          reverseCurve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
    _ctrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    _ctrl.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = widget.color ?? Theme.of(context).colorScheme.primary;
    
    Widget content = Stack(
      clipBehavior: Clip.none,
      children: [
        // Bouton principal
        GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: ScaleTransition(
            scale: _scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              constraints: BoxConstraints(minHeight: widget.minHeight),
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.onTap == null 
                    ? bg.withOpacity(0.5) 
                    : _isPressed 
                        ? bg.withOpacity(0.85)
                        : bg,
                borderRadius: widget.borderRadius,
                boxShadow: widget.onTap == null
                    ? []
                    : [
                        BoxShadow(
                          color: (widget.shadowColor ?? bg).withOpacity(_isPressed ? 0.3 : 0.45),
                          blurRadius: _isPressed ? 8 : 14,
                          offset: Offset(0, _isPressed ? 3 : 6),
                        ),
                      ],
              ),
              alignment: Alignment.center,
              child: widget.child,
            ),
          ),
        ),
        
        // Badge optionnel
        if (widget.badge != null)
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1), duration: 500.ms),
          ),
      ],
    );

    // Effet ripple
    if (widget.showRipple && widget.onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: null, // Géré par le GestureDetector
          borderRadius: widget.borderRadius,
          splashColor: Colors.white.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.1),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Bouton carte avec animation hover/tap
class AnimatedCardButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final double elevation;

  const AnimatedCardButton({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.elevation = 4,
  });

  @override
  State<AnimatedCardButton> createState() => _AnimatedCardButtonState();
}

class _AnimatedCardButtonState extends State<AnimatedCardButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? const Color(0xFF4FC3F7);
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(_isPressed ? 0.1 : 0.2),
              blurRadius: _isPressed ? 4 : 8,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        child: widget.child,
      ),
    )
        .animate(target: _isPressed ? 1 : 0)
        .shake(duration: 200.ms, hz: 2);
  }
}
