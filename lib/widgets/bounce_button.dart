import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bouton avec effet bounce + retour haptique
/// Compatible neurodivergences : grande zone de tap (min 64px), feedback immédiat
class BounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final Color? shadowColor;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double minHeight;

  const BounceButton({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.shadowColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
    this.minHeight = 64,
  });

  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

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
    _ctrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final Color bg = widget.color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          constraints: BoxConstraints(minHeight: widget.minHeight),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.onTap == null ? bg.withOpacity(0.5) : bg,
            borderRadius: widget.borderRadius,
            boxShadow: widget.onTap == null
                ? []
                : [
                    BoxShadow(
                      color: (widget.shadowColor ?? bg).withOpacity(0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}
