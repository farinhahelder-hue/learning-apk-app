import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Barre de progression animée pour les exercices
/// Usage :
///   AnimatedProgressBar(progress: 0.7, color: Colors.blue)
class AnimatedProgressBar extends StatelessWidget {
  final double progress; // 0.0 à 1.0
  final Color color;
  final Color backgroundColor;
  final double height;
  final Duration duration;
  final bool showPercentage;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.color = const Color(0xFF4FC3F7),
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.height = 16,
    this.duration = const Duration(milliseconds: 500),
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Barre de progression
              AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutCubic,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: clampedProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.8)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(height / 2),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .shimmer(
                        duration: 1500.ms,
                        color: Colors.white.withOpacity(0.3),
                      ),
                ),
              ),
              // Particules brillantes
              if (clampedProgress > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: height,
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  )
                      .animate(
                        onPlay: (c) => c.repeat(reverse: true),
                      )
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1.2, 1.2),
                        duration: 800.ms,
                      )
                      .fade(begin: 0.5, end: 1.0, duration: 800.ms),
                ),
            ],
          ),
        ),
        if (showPercentage)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${(clampedProgress * 100).round()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
      ],
    );
  }
}

/// Badge animé pour les étoiles/succès
class AnimatedBadge extends StatelessWidget {
  final int stars; // 0 à 3
  final bool animate;

  const AnimatedBadge({
    super.key,
    required this.stars,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final earned = index < stars;
        Widget star = Text(
          earned ? '⭐' : '☆',
          style: TextStyle(
            fontSize: 40,
            color: earned ? Colors.amber : Colors.grey.shade300,
          ),
        );

        if (animate && earned) {
          return star
              .animate(delay: (index * 200).ms)
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.elasticOut,
              )
              .rotate(
                begin: -0.5,
                end: 0,
                duration: 400.ms,
                curve: Curves.easeOut,
              );
        }

        return star;
      }),
    );
  }
}

/// Indicateur de série (streak) animé
class StreakIndicator extends StatelessWidget {
  final int streak;
  final int target;

  const StreakIndicator({
    super.key,
    required this.streak,
    this.target = 3,
  });

  @override
  Widget build(BuildContext context) {
    final achieved = streak >= target;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: achieved ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: achieved ? Colors.amber : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🔥',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Text(
            '$streak / $target',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: achieved ? Colors.amber.shade700 : Colors.grey,
            ),
          ),
        ],
      ),
    )
        .animate(target: achieved ? 1 : 0)
        .shake(duration: 500.ms, hz: 2)
        .scale(begin: 1.0, end: 1.1, duration: 200.ms)
        .then()
        .scale(begin: 1.1, end: 1.0, duration: 200.ms);
  }
}