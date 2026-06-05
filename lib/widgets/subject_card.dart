import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Carte matière avec effet bounce au tap (feedback haptique + visuel)
/// Accessible neurodivergences : grande zone de tap, contraste élevé
class SubjectCard extends StatefulWidget {
  final String title;
  final String emoji;
  final String subtitle;
  final LinearGradient gradient;
  final int points;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.subtitle,
    required this.gradient,
    required this.points,
    required this.onTap,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() async {
    HapticFeedback.lightImpact();
    await _ctrl.forward();
    await _ctrl.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final double pct = (widget.points / 300).clamp(0.0, 1.0);
    return GestureDetector(
      onTap: _handleTap,
      onTapDown: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withOpacity(0.45),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Emoji avec fond blanc semi-transparent pour mieux ressortir
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(widget.emoji,
                    style: const TextStyle(fontSize: 36)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: Colors.white.withOpacity(0.90),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Barre de progression avec coins arrondis
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 10,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${widget.points} pts',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
