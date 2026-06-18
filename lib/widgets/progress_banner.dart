import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../utils/app_theme.dart';

class ProgressBanner extends StatelessWidget {
  final UserProgress progress;
  const ProgressBanner({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
              emoji: '⭐', value: '${progress.totalPoints}', label: 'Points'),
          _Divider(),
          _StatItem(
              emoji: '🏅',
              value: '${progress.earnedBadges.length}',
              label: 'Badges'),
          _Divider(),
          _StatItem(
              emoji: '🔥', value: '${progress.streakDays}j', label: 'Série'),
          _Divider(),
          _StatItem(
              emoji: '🎯',
              value: 'Niv.${progress.currentLevel}',
              label: 'Niveau'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String emoji, value, label;
  const _StatItem(
      {required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppTheme.textDark)),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
        ],
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.2));
}
